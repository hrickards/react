require File.expand_path("../application", __FILE__)

# Run the API under the /api path
run Rack::URLMap.new(
  "/api"  => ReAct::Api
)
