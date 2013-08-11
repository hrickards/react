# Removes HTML, newlines and unneeded whitespace
# Whitespace removal from SO 7106964
# TODO If using Rails, using ActiveHelper methods 
def strip_html(text)
    @name = Sanitize.clean(text).gsub("\n", ' ').gsub("\r", ' ').squeeze(' ').rstrip.lstrip
end

def cache_open(url)
  Cachy.cache(url, hash_key: true) { open(url).read }
end

def slugify_title(title)
  title.split(/Bill|Act|-/, 2)[0].rstrip.gsub(/\([a-zA-Z.\d\s'",]*\)/, '')
end

def alternate_slugify_title(title)
  title.split(/Bill|Act/, 2)[0].gsub(/\([a-zA-Z.\s\d'",-]*\)/, '').rstrip
end

def get_votes_wrapper(collection)
  Cachy.cache("get_votes_#{collection.name}", hash_key: true) { get_votes(collection) }
end

def get_votes(collection)
  votes = {}
  collection.find.each do |vote|
    id = vote['_id'].to_s
    title = slugify_title vote['Bill']

    if votes.include? title
      votes[title] << id
    else
      votes[title] = [id]
    end
  end
  return votes
end

def parse_division(division)
  data = {
    date: division['date'],
    vote_no: division['voteno'],
    row_id: division['rowid']
  }
  # Even with the Lords divisions, each Lord is referenced as mpid....
  division.keys.select { |key| key[0...4] == "mpid" }.each do |key|
    data[key[4..-1].to_i] = parse_division_value(division[key])
  end
  return data
end

DIVISION_VALUES = {
  '-9' => :missing,
  '1' => :tellaye,
  '2' => :aye,
  '3' => :both,
  '4' => :no,
  '5' => :tellno
}

def parse_division_value(value)
  DIVISION_VALUES[value.to_s.lstrip]
end

def select_keys(record, keys)
  new_record = {}
  keys.each do |key|
    if %w{score humanized_slug large_photo date}.include? key
      new_record[key] = record.send(key)
    elsif record.respond_to? key
      new_record[key] = record[key]
    end
  end
  return new_record
end

# Copied from SO 1302022
def generate_slug(title)
  # TODO Despite the name, slugify_title removes brackets, etc from the title
  # whereas generate_slug generates a machine-readable slug
  title = slugify_title title
  #strip the string
  ret = title.downcase.strip

  #blow away apostrophes
  ret.gsub! /['`]/,""

  # @ --> at, and & --> and
  ret.gsub! /\s*@\s*/, " at "
  ret.gsub! /\s*&\s*/, " and "

  #replace all non alphanumeric, underscore or periods with underscore
  ret.gsub! /\s*[^A-Za-z0-9\.\-]\s*/, '_'  

  #convert double underscores to single
  ret.gsub! /_+/,"_"

  #strip off leading/trailing underscore
  ret.gsub! /\A[_\.]+|[_\.]+\z/,""

  ret
end

def bill_or_act(title)
  if title.include? "Act"
    :act
  else
    :bill
  end
end

def gen_date(documents, events)
  today = Date.today
  dates = (documents + events).map { |doc|
    begin
      Date.parse doc.last
    rescue
      nil
    end
  }.reject { |date| date.nil? }.select { |date| date <= today }.reverse
  dates.last
end

def constituency_loc(constituency)
  Cachy.cache("const" + constituency, hash_key: true) {constituency_loc_real constituency }
end

def constituency_loc_real(constituency)
  begin
    puts constituency
    # TODO Move this somewhere else
    twfy_client = Twfy::Client.new 'FqQ7HAE6VXorA8NhKHAmUeW5'
    location = twfy_client.geometry name: constituency
    {lat: location.centre_lat, lng: location.centre_lon}
  rescue
    {lat: 0, lng: 0}
  end
end

def fix_name(name)
  puts name
  first_name, last_name = name.split

  case first_name
  when "Ed"
    "Edward #{last_name}"
  when "Steve"
    if last_name == "McCabe"
      "Stephen McCabe"
    else
      "Steven #{last_name}"
    end
  when "Vince"
    "Vincent #{last_name}"
  else
    if name == "Nick Boles"
      "Nicholas Boles"
    elsif name == "Nicholas Brown"
      "Nick Brown"
    end
  end
end

def nice_vote(vote)
  if vote == "aye"
    "for"
  else
    "against"
  end
end
