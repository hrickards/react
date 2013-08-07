class Bill
  BASE_URL = 'http://services.parliament.uk'
  MP_VOTES = get_votes_wrapper DB['mp_votes']
  LORDS_VOTES = get_votes_wrapper DB['lords_votes']
  
  include Mongoid::Document
  include Mongoid::FullTextSearch
  field :title, type: String
  field :type, type: String
  field :sponsors, type: Array
  field :photo, type: Array
  field :description, type: String
  field :bill, type: String
  field :url, type: String
  field :diagram, type: String
  field :divisions, type: Array
  fulltext_search_in :description

  # Scrape each bill and basic bill information
  def self.scrape_all
    self.delete_all
    ['', '/2012-13.html', '/2010-12.html'].each do |postfix|
      doc = Nokogiri::HTML cache_open(BASE_URL + '/bills' + postfix)
      # List of relative urls to a bill on the parliament site
      bills = doc.xpath "//td[@class='bill-item-description']/a/@href"
      bills.each { |path| Bill.scrape path }
    end
  end

  # Scrape the votes (divisions) for each bill
  def self.scrape_divisions
    self.all.each { |bill| bill.scrape_divisions }
  end

  # Scrape all diagrams
  def self.scrape_diagrams
    self.all.each { |bill| bill.scrape_diagram }
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

    data = {
      title: details.xpath("//h1").first.text,
      type: details.xpath("//dd")[0].text,
      sponsors: sponsors.map(&:name),
      photo: sponsors.empty? ? '' : sponsors.first.photo_wrapper,
      description: strip_html(doc.xpath("//div[@id='bill-summary']").children.select(&:text?).last.text),
      bill: doc.xpath("//td[@class='bill-item-description']/span[@class='application-pdf']/a/@href").text,
      url: url
    }

    self.create data
  end

  # Uses mongo full text searching to find articles relevant to keywords
  def self.search(query, limit)
    self.fulltext_search(query, {:max_results=>limit})
  end
end
