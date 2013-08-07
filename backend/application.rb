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

module OpenParliament
class Api < Sinatra::Base
helpers Sinatra::Jsonp

get '/bills.json' do
response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
	if params[:query]
jsonp Bill.search(params[:query], LIMIT)
	else
jsonp Bill.all.limit(LIMIT)
	end
	end

	enable :cross_origin
	end
end
