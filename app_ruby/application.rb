require 'bundler'
Bundler.require

module OpenParliament
  class App < Sinatra::Base
    get '/bills/load_view.js' do
      content_type 'text/javascript'
      File.read(File.join('views', 'load_view.js'))
    end

    get '/bills/vote.js' do
      content_type 'text/javascript'
      File.read(File.join('views', 'vote.js'))
    end

    get '/bills/:slug/votebar.css' do
      url = "http://harryrickards.com/api/bills/" + params[:slug]
      @bill = Hashie::Mash.new HTTParty.get url
      if @bill.upvotes == 0 and @bill.downvotes == 0
        @yes = 50
      else
        @yes = (@bill.upvotes / (@bill.upvotes + @bill.downvotes).to_f * 100).to_i
      end
      erb :votebar
    end

    get '/bills/:slug' do
      url = "http://harryrickards.com/api/bills/" + params[:slug]
      @bill = Hashie::Mash.new HTTParty.get url
      if @bill.upvotes == 0 and @bill.downvotes == 0
        @yes = 50
      else
        @yes = (@bill.upvotes / (@bill.upvotes + @bill.downvotes).to_f * 100).to_i
      end

      erb :view
    end
  end
end
