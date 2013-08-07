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
    # TODO Move this somewhere else
    twfy_client = Twfy::Client.new 'FqQ7HAE6VXorA8NhKHAmUeW5'

    lords = twfy_client.lords(search: @slug)
    mps = twfy_client.mps(search: @slug)

    # No elsif with unless
    if lords.is_a? Array and not lords.empty? and @lord
      person = twfy_client.lord id: filter_names(lords).first.person_id
    elsif mps.is_a? Array and not mps.empty? and not @lord
      person = twfy_client.mp id: filter_names(mps).first.person_id
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
