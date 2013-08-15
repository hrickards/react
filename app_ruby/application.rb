require 'bundler'
Bundler.require
require 'yaml'

# Load the global config file
CONFIG = YAML.load_file File.join(__dir__, '../config.yml')

# Returns the percentage of upvotes on a given bill
def votes_from_bill(bill)
  # If there are no votes, return a 50/50 split
  return 50 if bill.upvotes == 0 and bill.downvotes == 0
  # Otherwise work at the percentage of upvotes and round it
  (bill.upvotes / (bill.upvotes + bill.downvotes).to_f * 100).round
end

# Returns a bill and it's votes from the API given it's slug
def bill_votes_from_api(slug)
    # Get the bill from the API and turn it into a hashie
    url = "#{CONFIG['base_url']}/api/bills/" + slug
    bill = Hashie::Mash.new HTTParty.get url

    # Get the % of upvotes on the bill
    yes = votes_from_bill bill

    [bill, yes]
end

module ReAct
  class App < Sinatra::Base
    # Returns the CSS for the voting bar of a specific bill
    get '/bills/:slug/votebar.css' do
      # Get the bill and it's upvotes
      @bill, @yes = bill_votes_from_api params[:slug]

      # Render the CSS
      content_type 'text/css'
      erb :votebar
    end

    # Returns the bill item view page for a specific bill
    get '/bills/:slug' do
      @bill, @yes = bill_votes_from_api params[:slug]

      # Render the view
      erb :view
    end
  end
end
