# Config for the webserver

require 'yaml'

# Load the global config file to get directories from
CONFIG = YAML.load_file File.join(__dir__, '../../config.yml')
BASE_DIR = CONFIG['base_dir']

bind "unix://#{BASE_DIR}/app_ruby/tmp/sock/unicorn.sock"
pidfile "#{BASE_DIR}/app_ruby/tmp/puma/pid"
state_path "#{BASE_DIR}/app_ruby/tmp/puma/state"
