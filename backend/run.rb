# Use this as a command line interface to the application

# Load the app
require_relative 'application'

case ARGV[0]
when "scrape"
  # Scrape all basic bill information
  Bill.scrape_all
when "diagrams"
  # Scrape all progress diagrams for all bills
  Bill.scrape_diagrams
when "reindex"
  # Reindex full-text searching
  Bill.remove_from_ngram_index
  Bill.update_ngram_index
when "reset_votes"
  # Reset the upvotes and downvotes to 0 on each bill
  Bill.reset_votes
when "console"
  # Open up a console with the app loaded
  binding.pry
when "scrape_emails"
  # Scrape the email addresses of all MPs
  MpUrl.scrape_emails
when "fix_images"
  # Make the white background transparent on all progress diagrams
  Bill.fix_all_images
when "setup"
  # Initially setup the app by running all needed of the above tasks
  Bill.scrape_all
  Bill.scrape_diagrams
  Bill.remove_from_ngram_index
  Bill.update_ngram_index
  MpUrl.scrape_emails
end
