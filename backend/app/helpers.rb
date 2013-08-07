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
  title.split(/Bill|Act|-/, 2)[0].rstrip.gsub(/\([a-zA-Z\s'",]*\)/, '')
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
