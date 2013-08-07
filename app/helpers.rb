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
