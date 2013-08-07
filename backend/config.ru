require File.expand_path("../application", __FILE__)

run Rack::URLMap.new(
  "/"    => Rack::Directory.new("../app"),
  "/api" => OpenParliament::Api
)
