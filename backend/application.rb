# The main application file

require 'bundler'
Bundler.require
require 'open-uri'
require 'pp'
require 'fileutils'
require 'json'
require 'date'
require 'yaml'

# Load configuration settings from ../config.yml and config/mongoid.yml
CONFIG = YAML.load_file File.join(__dir__, '../config.yml')
DBCONFIG = YAML.load_file File.join(__dir__, 'config/mongoid.yml')

# Get environment from ../config.yml. Rails environment values.
ENVIRONMENT = CONFIG['environment']

# Setup caching using a Redis instance
Cachy.cache_store = Redis.new

# Setup mongo
include Mongo
Mongoid.load! "config/mongoid.yml", ENVIRONMENT
DB_NAME = DBCONFIG[ENVIRONMENT]['sessions']['default']['database']
DB = MongoClient.new[DB_NAME]

# Setup the TheyWorkForYou API
TWFY_CLIENT = Twfy::Client.new CONFIG['api_keys']['twfy']

# Require application files
require_relative 'app/helpers'
require_relative 'app/models/bill'
require_relative 'app/models/person'

# A JSONP API that can be run with Rack
module ReAct
  class Api < Grape::API
    use Rack::JSONP
    version 'v1', using: :header, vendor: 'react'
    format :json

    before do
      # Allow AJAX requests
      header['Access-Control-Allow-Origin'] = '*'
      header['Access-Control-Request-Method'] = '*'
      header["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
    end

    resources :bills do
      desc "Return a list of all bills"
      params do
        optional :query, type: Array, desc: "An array of categories to search for."
        optional :limit, type: Integer, desc: "Maximum number of results to return."
        optional :offset, type: Integer, desc: "Number of results to offset by."
        optional :fields, type: Array, desc: "A list of fields to return data for."
      end
      get do
        # Search for bills, using default values for the limit and offset if they're not present
        Bill.search params[:query], (params[:limit] || CONFIG['bills_limit']), (params[:offset] || 0), params[:fields]
      end

      desc "Return full details of a single bill"
      params do
        requires :slug, type: String, desc: "Slug (machine-readable name) of the bill. Generally a lowercase version"\
          "of the base title with spaces replaced by underscores."
      end
      get ':slug' do
        # Find one bill with that slug
        Bill.find_by_slug params[:slug]
      end

      desc "Return an MPs vote record on a single bill"
      params do
        requires :slug, type: String, desc: "Slug (machine-readable name) of the bill. Generally a lowercase version"\
          "of the base title with spaces replaced by underscores."
        requires :mpid, type: Integer, desc: "member_id of local MP, as in TWFY and Public Whip."
      end
      get ':slug/:mpid' do
        # Find one bill with that slug
        bill = Bill.find_by slug: params[:slug]
        # Return an MP's voting record on that bill
        bill.mp_voting_record params[:mpid]
      end

      desc "Vote on a single bill"
      params do
        requires :slug, type: String, desc: "Slug (machine-readable name) of the bill. Generally a lowercase version"\
          "of the base title with spaces replaced by underscores."
        requires :type, type: Integer, desc: "The type of vote given: 1 for positive, 0 for negative"
      end
      put ':slug' do
        # Find one bill with that slug, and vote on it
        Bill.find_by(slug: params[:slug]).vote params[:type]
      end
    end

    resources :mps do
      desc "Get the email address of a single MP"
      params do
        requires :mpid, type: String, desc: "MP ID"
      end
      get ':mpid' do
        Person.get_email params[:mpid]
      end
    end

    # Generate a documentation JSON structure from the docstrings above
    # This can be loaded into swagger, a tool for viewing interactive api docs
    add_swagger_documentation base_path: 'http://harryrickards.com/api'
  end
end
