class MpUrl
  include Mongoid::Document
  field :mpid, type: Integer
  field :email, type: String

  index({mpid: 1})

  def self.scrape_emails
    self.delete_all

    # TODO Move this somewhere else
    twfy_client = Twfy::Client.new 'FqQ7HAE6VXorA8NhKHAmUeW5'

    url = "http://www.parliament.uk/mps-lords-and-offices/mps/"
    doc = Nokogiri::HTML cache_open(url)
    mps = doc.xpath("//a[contains(@id, 'ctl00_ctl00_SiteSpecificPlaceholder_PageContent_rptMembers') and contains(@id, '_hypName')]").map { |a| [a.text(), a.attr("href")] }
    mps.each do |mp|
      sleep 0.1
      mpurl = mp.last
      name = mp.first.split(", ").reverse.join(" ")

      mpdoc = doc = Nokogiri::HTML cache_open(mpurl)
      email = mpdoc.xpath("//a[contains(@id, 'ctl00_ctl00_SiteSpecificPlaceholder_PageContent_ctlContactDetails_rptPhysicalAddresses_ctl') and contains(@id, 'hypEmail')]").map { |x| x.text }.reject(&:empty?).first
      if email.nil?
        email = ""
        puts "No email for #{name}: #{mpurl}"
      else
        email = email.split(";").first
      end

      mpr = twfy_client.mps(search: name)
      mpr = twfy_client.mps(search: fix_name(name))unless mpr.respond_to? 'first'
      mpid = mpr.first.member_id.to_i

      data = {mpid: mpid, email: email}
      puts data
      self.create data
    end
  end
end
