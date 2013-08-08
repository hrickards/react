require_relative 'application'

case ARGV[0]
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
when "reset_votes"
  Bill.reset_votes
when "console"
  binding.pry
when "marriage"
  Bill.scrape "/bills/2013-14/marriagesamesexcouplesbill.html"
end
