require 'bundler'
Bundler.require

module OpenParliament
  class App < Sinatra::Base
    get '/bills/load_view.js' do
      puts File.read(File.join('views', 'load_view.js'))
      File.read(File.join('views', 'load_view.js'))
    end

    get '/bills/:slug' do
      url = "http://harryrickards.com/api/bills/" + params[:slug]
      @bill = Hashie::Mash.new HTTParty.get url

      erb :view
    end
  end
end
