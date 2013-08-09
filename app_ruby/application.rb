require 'bundler'
Bundler.require

module OpenParliament
  class App < Sinatra::Base
    get '/:slug' do
      url = "http://harryrickards.com/api/bills/" + params[:slug]
      @bill = Hashie::Mash.new HTTParty.get url

      erb :view
    end
  end
end
