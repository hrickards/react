require File.expand_path("../application", __FILE__)

run Rack::URLMap.new(
  "/api"  => OpenParliament::Api
)
