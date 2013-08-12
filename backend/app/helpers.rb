# Removes HTML, newlines and unneeded whitespace
# Whitespace removal from SO 7106964
def strip_html(text)
  @name =
    # Remove HTML from the text
    Sanitize.clean(text).
    # Replace newlines with a space
    gsub(/\n|\r/, ' ').
    # Replaces runs of spaces by a single space
    squeeze(' ').
    # Remove leading and trailing whitespace
    strip
end

# Calls open on the passed URL, but caches the result
def cache_open(url)
  Cachy.cache(url, hash_key: true) { open(url).read }
end

# Returns a cleaner version of a bill title
# Used for giving bills a unique ID.
def clean_title(title)
  title.
    # Take the part of the title before Bill, Act or -
    split(/Bill|Act|-/, 2)[0].
    # Remove any brackets
    gsub(/\([a-zA-Z.\d\s'",]*\)/, '').
    # Strip any trailing whitespace
    rstrip
end

# Returns a cleaner version of a bill title, but doesn't split at hyphens.
# Used for comparing bills from different data sources.
def alternate_clean_title(title)
  title.
    # Take the part of the title before Bill or Act
    split(/Bill|Act/, 2)[0].
    # Remove any brackets
    gsub(/\([a-zA-Z.\s\d'",-]*\)/, '').
    # Strip any trailing whitespace
    rstrip
end

# Return the record, with only the keys passed in the hash
# If a passed key isn't in the hash and it's in a preset list, that method is called on the hash
def select_keys(record, keys)
  new_record = {}
  keys.each do |key|
    # If it's safe to call the key method on record
    if %w{score humanized_slug large_photo date}.include? key
      new_record[key] = record.send(key)
    elsif record.respond_to? key
      new_record[key] = record[key]
    end
  end
  return new_record
end

# Cleans a bill title and turns it into a machine-readable slug
# Copied from SO 1302022
def generate_slug(title)
  title = clean_title title
  # Strip the string
  ret = title.downcase.strip

  # Blow away apostrophes
  ret.gsub! /['`]/,""

  # @ --> at, and & --> and
  ret.gsub! /\s*@\s*/, " at "
  ret.gsub! /\s*&\s*/, " and "

  # Replace all non alphanumeric, underscore or periods with underscore
  ret.gsub! /\s*[^A-Za-z0-9\.\-]\s*/, '_'  

  # Convert double underscores to single
  ret.gsub! /_+/,"_"

  # Strip off leading/trailing underscore
  ret.gsub! /\A[_\.]+|[_\.]+\z/,""

  ret
end

# Returns a symbol indicating whether the title is of a bill or act
def bill_or_act(title)
  return :act if title.include? "Act"
  :bill
end

# Return the last date for a bill given it's documents and events
def gen_date(documents, events)
  today = Date.today
  dates = (documents + events).map { |doc|
    # For each item, parse it's last value into a date
    begin
      Date.parse doc.last
    rescue
      nil
    end
  # Reject any dates that are nil
  # Select those dates that are before today (have already happened)
  }.reject { |date| date.nil? }.select { |date| date <= today }.reverse

  # Choose the most recent date
  dates.last
end

# Returns the lat and lng of a constituency. Cached.
def constituency_loc(constituency)
  Cachy.cache("const" + constituency, hash_key: true) {constituency_loc_real constituency }
end

# Returns the lat and lng of a constituency given it's name
def constituency_loc_real(constituency)
  begin
    # Use the TWFY API to get the data
    location = TWFY_CLIENT.geometry name: constituency
    {lat: location.centre_lat, lng: location.centre_lon}
  rescue
    # Return (0,0) in case of failure
    {lat: 0, lng: 0}
  end
end

# Tweak names from the parliament.uk site to make them compatible with the TheyWorkForYou API
def fix_name(name)
  first_name, last_name = name.split

  case first_name
  when "Ed"
    "Edward #{last_name}"
  when "Steve"
    return "Stephen McCabe" if last_name == "McCabe"
    "Steven #{last_name}"
  when "Vince"
    "Vincent #{last_name}"
  else
    return "Nicholas Boles" if name == "Nick Boles"
    return "Nick Brown" if name == "Nicholas Brown"
    name
  end
end

# Turn aye/naye into for/against
def humanify_vote(vote)
  return "for" if vote == "aye"
  "against"
end
