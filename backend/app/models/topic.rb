class Topic
  include HTTParty
  base_uri 'http://www.theyworkforyou.com/api'

  def debates
    d = []
    # Can only request debates by one type at a time
    %w{commons westminsterhall lords scotland northernireland}.each do |t|
      # Other options: date, search, person, gid, order, page, num
      options = { type: t, search: @topic }
      d << self.class.get('/getDebates', options)
    end

    return d
  end
end
