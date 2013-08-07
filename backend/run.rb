require_relative 'app'

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
when "console"
  binding.pry
end
