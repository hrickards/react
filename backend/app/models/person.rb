# Members and Lords
class Person
  LORD_REMOVALS = %w{lord baroness earl}
  REMOVALS = %w{mrs mr ms sir}
  attr_accessor :name

  def initialize(name)
    @name = name
    # True if person is a lord rather than an MP
    @lord = LORD_REMOVALS.include? @name.split.first.downcase
    # TWFY API doesn't work if Lord or Mr./etc is in the title
    @slug = @name.split.reject { |w| REMOVALS.include? w.downcase }.join " "
    if @lord
      @slug = @slug.split[1..-1]
    end
  end

  # Cached version of photo
  def photo_wrapper
    Cachy.cache("photo_#{@slug}") { self.photo }
  end

  def photo
    lords = TWFY_CLIENT.lords(search: @slug)
    mps = TWFY_CLIENT.mps(search: @slug)

    # No elsif with unless
    if lords.is_a? Array and not lords.empty? and @lord
      person = TWFY_CLIENT.lord id: filter_names(lords).first.person_id
    elsif mps.is_a? Array and not mps.empty? and not @lord
      person = TWFY_CLIENT.mp id: filter_names(mps).first.person_id
    else
      # Return empty string if no-one found
      return ""
    end

    return "" if person.empty?

    person = person.first
    if person.respond_to? :image
      return person.image.to_s
    else
      return ""
    end
  end

  # Get the email address from an MP TWFY person_id. Cached.
  def self.get_email(person_id)
    Cachy.cache("mpemail_#{person_id}") { self.get_email_real(person_id) }
  end

  # Get the email address from an MP TWFY person_id
  def self.get_email_real(person_id)
    # Get the MP info from the TWFY API
    info = TWFY_CLIENT.mp_info id: person_id
    # From this, retrieve the DODS Id from the bbc_profile_url
    # e.g. http://news.bbc.co.uk/democracylive/hi/representatives/profiles/25603.stm
    dods_id = info.bbc_profile_url.split("/").last.split(".").first

    # Query the Parliament members API to get addresses info for that MP using their DODS id
    url = "http://data.parliament.uk/membersdataplatform/services/mnis/members/query/refDods=#{dods_id}/Addresses/"
    response = HTTParty.get url

    # Find the first non-nil email address and return it
    email = response['Members']['Member']['Addresses']['Address'].
      map { |address| address['Email'] }.
      reject { |address| address.nil? }.
      first
    { email: email }
  end

  # Very hackish --- no better way we can use?
  protected
  def filter_names(people)
    return [] unless people.is_a? Array
    people.select! do |fperson|
      name = fperson.name
      next false if @lord and @name.split.first != name.split.first
      next false if @name.split[1] != name.split[1] and @slug.split[1] != name.split[1]
      next true
    end
    return people
  end
end
