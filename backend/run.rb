require 'bundler'
Bundler.require
require 'open-uri'
require 'pp'
require 'fileutils'

include Mongo

Cachy.cache_store = Redis.new
Mongoid.load! "config/mongoid.yml", :development
DB = MongoClient.new['parliament']

require_relative 'app/helpers'
require_relative 'app/models/bill'
require_relative 'app/models/person'

LIMIT = 40

case ARGV[0]
when "server"
  class App < Sinatra::Base
    helpers Sinatra::Jsonp

    get '/bills.json' do
      response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
      if params[:query]
        jsonp Bill.search(params[:query]).limit(LIMIT)
      else
        jsonp Bill.all.limit(LIMIT)
      end
    end

    set :bind, '0.0.0.0'
    enable :cross_origin
    run!
  end
when "scrape"
  Bill.scrape_all
when "divisions"
  Bill.scrape_divisions
when "diagrams"
  Bill.scrape_diagrams
when "reindex"
  # Reindex full-text searching
  Bill.remove_from_ngram_index
  Bill.update_ngram_index
when "console"
  binding.pry
end
