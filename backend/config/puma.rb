# Config for the webserver

require 'yaml'

# Load the global config file to get directories from
CONFIG = YAML.load_file File.join(__dir__, '../../config.yml')
BASE_DIR = CONFIG['base_dir']

bind "unix://#{BASE_DIR}/backend/tmp/sock/unicorn.sock"
pidfile "#{BASE_DIR}/backend/tmp/puma/pid"
state_path "#{BASE_DIR}/backend/tmp/puma/state"
