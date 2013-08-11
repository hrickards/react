class Bill
  BASE_URL = 'http://services.parliament.uk'
  MP_VOTES = get_votes_wrapper DB['mp_votes']
  LORDS_VOTES = get_votes_wrapper DB['lords_votes']
  
  include Mongoid::Document
  include Mongoid::FullTextSearch
  field :title, type: String
  field :type, type: String
  field :leg_type, type: String
  field :sponsors, type: Array
  field :photo, type: Array
  field :description, type: String
  field :url, type: String
  field :diagram, type: String
  field :divisions, type: Array
  field :slug, type: String
  field :upvotes, type: Integer
  field :downvotes, type: Integer
  field :events, type: Array
  field :documents, type: Array
  field :next_event, type: String
  field :date, type: Date
  fulltext_search_in :description, :index_name => 'description_index'
  fulltext_search_in :title, :index_name => 'title_index'

  # Scrape each bill and basic bill information
  def self.scrape_all
    self.delete_all
    ['', '/2012-13.html', '/2010-12.html'].each do |postfix|
      doc = Nokogiri::HTML cache_open(BASE_URL + '/bills' + postfix)
      # List of relative urls to a bill on the parliament site
      bills = doc.xpath "//td[@class='bill-item-description']/a/@href"
      bills.each { |path| self.scrape path.value }
    end
  end

  # Reset votes for all bills
  def self.reset_votes
    self.all.each { |bill| bill.reset_votes }
  end

  # Reset votes for a single bill
  def reset_votes
    self.upvotes = 0
    self.downvotes = 0
    self.save
  end

  # Scrape the votes (divisions) for each bill
  def self.scrape_divisions
    self.all.each { |bill| bill.scrape_divisions }
  end

  # Scrape all diagrams
  def self.scrape_diagrams
    self.all.each { |bill| bill.scrape_diagram }
  end

  def self.fix_all_images
    self.all.each { |bill| bill.fix_image }
  end

  def fix_image
    filename = "public/images/progress/#{self.id}.png"
    orig_filename = "public/images/progress/#{self.id}.png.orig"
    return unless File.exist? filename

    FileUtils.cp filename, orig_filename unless File.exist? orig_filename
    puts self.slug
    %x{convert #{orig_filename} -transparent white #{filename}}
  end

  # Scrape the votes for an individual bill
  def scrape_divisions
    stitle = slugify_title self.title
    mp_division_ids = MP_VOTES[stitle] || []
    lords_division_ids = LORDS_VOTES[stitle] || []

    mp_divisions = mp_division_ids.map { |id| DB['mp_votes'].find_one(BSON::ObjectId(id)) }.map { |div| parse_division div }
    lords_divisions = lords_division_ids.map { |id| DB['lords_votes'].find_one(BSON::ObjectId(id)) }.map { |div| parse_division div }

    self.divisions = {mps: mp_divisions, lords: lords_divisions}
    self.save
    puts "Saved divisions"
  end

  # Scrape diagram
  def scrape_diagram
    # Use phantomjs to take a screenshot of the progress diagram
    script = File.expand_path 'scripts/diagram.js'
    filename = "public/images/progress/#{self.id}.png"
    unless File.exist? filename
      Phantomjs.run script, self.url, filename, "--diskcache=true"
      self.diagram = "/images/progress/#{self.id}.png"
      self.save
    end
    puts "Done #{self.id}"
  end

  # path = relative URL to bill on parliament.uk site
  def self.scrape(path)
    url = BASE_URL + path
    doc = Nokogiri::HTML cache_open(url)
    
    # Various parts of document containing multiple details
    details = doc.xpath("//div[@id='content-small']").first
    
    # If the relevant details not present, return
    return nil unless details

    # See structure of HTML page e.g. http://services.parliament.uk/bills/2013-14/ageofcriminalresponsibility.html
    # TODO Work out why we can't just use ::text() with Nokogiri

    # See SO 8482739
    sponsor_names = []
    details.xpath('//dt').each do |dt|
      dds = dt.xpath('following-sibling::*').chunk{ |n| n.name }.first.last
      if dt.text.include? "Sponsor"
        sponsor_names = dds.map { |el| el.children.select(&:text?).join }
      elsif dt.text.include? "Parliamentary agents"
        sponsor_names = dds.map(&:text)
      end
    end

    sponsors = sponsor_names.map { |n| Person.new strip_html(n) }
    title = details.xpath("//h1").first.text

    documents = self.scrape_documents(path)
    events =  self.scrape_events(path)

    data = {
      title: title,
      type: details.xpath("//dd")[0].text,
      sponsors: sponsors.map(&:name),
      photo: sponsors.empty? ? '' : sponsors.first.photo_wrapper,
      description: strip_html(doc.xpath("//div[@id='bill-summary']").children.select(&:text?).last.text),
      # bill: doc.xpath("//td[@class='bill-item-description']/span[@class='application-pdf']/a/@href").text,
      url: url,
      slug: generate_slug(title),
      upvotes: 0,
      downvotes: 0,
      leg_type: bill_or_act(title),
      events: events,
      documents: documents,
      next_event: strip_html(doc.xpath("//div[@class='next-event']/ul/li").children.select(&:text?).join),
      date: gen_date(documents, events)
    }

    puts "Inserting"
    self.create data
  end

  # Uses mongo full text searching to find articles relevant to keywords
  def self.search(queries, limit, offset, keys=nil)
    keys = %w{title description slug humanized_slug large_photo type} unless keys
    unless queries.nil? or queries.empty? or queries.reject { |q| q.empty? }.empty?
      queries.map! { |q| q.rstrip }
      queries.reject! { |q| q.empty? }
      puts queries.inspect
      pseudo_limit = offset + limit
      queries.map { |query|
        (
          self.fulltext_search(query, :index => 'title_index', :max_results=> limit, :return_scores => true) + 
          self.fulltext_search(query, :index => 'description_index', :max_results=> limit, :return_scores => true)
        # ).select { |r, s| s > 0.5 }.map(&:first)
        )
      }.flatten(1).sort_by { |r, s| r }.reverse.map(&:first)[offset..pseudo_limit].sort_by { |r| r.date }.reverse.map { |r| select_keys r, keys }.uniq
    else
      self.desc(:date).skip(offset).limit(limit).map { |r| select_keys r, keys }
    end
  end

  def humanized_slug
    alternate_slugify_title self.title
  end

  # Find a bill with the given slug
  def self.find_by_slug(slug)
    result = self.find_by(slug: slug)
    data = JSON.parse(result.to_json)
    %w{humanized_slug large_photo semi_humanized_slug humanized_last_event votes_agg}.each { |key| data[key] = result.send(key) }
    data
  end

  # Positively vote on a bill
  def upvote
    self.upvotes += 1
    self.save
  end

  # Negatively vote on a bill
  def downvote
    self.downvotes += 1
    self.save
  end

  # Vote on a bill
  # TODO Implement this
  def vote(vote)
    case vote
    when 1
      self.upvote
    when 0
      self.downvote
    end
    return {status: 'Successful', new_score: self.score}
  end

  # Return the score for a bill
  # TODO Is this the best way to calculate this score?
  def score
    self.upvotes - self.downvotes
  end

  def self.scrape_events(path)
    url = "#{BASE_URL}#{path[0...-5]}/stages.html"
    doc = Nokogiri::HTML cache_open(url)
    doc.xpath("//div[@id='bill-summary']//tbody/tr").map { |row| [strip_html(row.xpath("td[@class='bill-item-description']").text), strip_html(row.children[-2].text)] }
  end

  def self.scrape_documents(path)
    url = "#{BASE_URL}#{path[0...-5]}/documents.html"
    doc = Nokogiri::HTML cache_open(url)
    doc.xpath("//tbody/tr").map do |row|
      link = row.xpath("td[@class='bill-item-description']/a[1]")
      [link.text, link.attr('href').value, row.xpath("td[@class='bill-item-date']").text]
    end
  end

  def large_photo
    Cachy.cache("image_llarge" + self.title, hash_key: true) { self.large_photo_real }
  end

  def large_photo_real
    sleep 0.05
    query = URI.escape self.humanized_slug
    url = "https://api.datamarket.azure.com/Data.ashx/Bing/Search/Image?Query=%27#{query}%27&$top=50&$format=json&ImageFilters=%27Size%3ALarge%27"
    response = HTTParty.get url, :basic_auth => {:username => '', :password => API_KEY}, :format => :json
    begin
      images = response.first.last["results"].map { |res| [res["Width"], res["MediaUrl"]] }
      image = images.select { |image| image.first.to_i >= 770 }.first
      if image
        return image.last
      else
        return images.sort_by { |image| image.first.to_i }.last.last
      end
    rescue
      return ""
    end
  end

  def humanized_last_event
    self.events.last.first
  end

  def semi_humanized_slug
    "#{self.humanized_slug} #{self.leg_type.capitalize}"
  end

  def mp_view(mpid)
    url = "http://www.publicwhip.org.uk/mp.php?mpid=#{mpid}&house=commons&display=allvotes"
    doc = Nokogiri::HTML cache_open(url)
    rows = doc.xpath("//table[@class='votes']//tr")
    vals = rows.map { |row| row.xpath("td") }.select { |tds| tds[2].text.include? self.humanized_slug }.map { |tds| [tds[4].text, tds[5].text] }

    yes = vals.select { |vote, loyalty| vote == "aye" }.count
    loyal = vals.select { |vote, loyalty| loyalty == "Loyal" }.count

    {
      last_vote: nice_vote(vals.last.first),
      vote: (yes.to_f/vals.count*100).to_i,
      loyal: (loyal.to_f/vals.count*100).to_i
    }
  end

  def votes_agg
    # [
    #  {
    #    type: x,
    #    location: y
    #  }
    # ]
    twfy_client = Twfy::Client.new 'FqQ7HAE6VXorA8NhKHAmUeW5'
    constituencies = twfy_client.constituencies.map { |c| c.name }

    # TODO Do this properly
    total_upvotes = self.upvotes
    total_downvotes = self.downvotes
    return [] if total_upvotes == 0 and total_downvotes == 0
    votes = (0...total_upvotes).map { |i| constituencies[Random.rand(constituencies.count)] }.map { |loc| {'type' => 1, 'location' => loc} } + (0...total_downvotes).map { |i| constituencies[Random.rand(constituencies.count)] }.map { |loc| {'type' => 0, 'location' => loc} }

    vs = votes.group_by { |vote| vote['location'] }.map { |location, votes| [location, votes.map { |vote| normalise_type(vote['type']) }] }.map { |location, types| [location, types.sum/types.count.to_f] }
    avgs = vs.map { |location, avg| avg }

    delta = avgs.max - avgs.min
    delta = 1 if delta == 0
    vs.map! { |location, avg| [location, (avg-avgs.min)/delta] }
    vs.map! { |location, avg| [constituency_loc(location), avg] }

    vs
  end

  def normalise_type(type)
    if type.to_i == 1
      return 1
    else
      return -1
    end
  end
end
