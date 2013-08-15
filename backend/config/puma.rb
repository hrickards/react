# Config for the webserver

require 'yaml'

# Load the global config file to get directories from
CONFIG = YAML.load_file '../config.yml'
BASE_DIR = CONFIG['base_dir']

bind "unix://#{BASE_DIR}/backend/tmp/sock"
pidfile "#{BASE_DIR}/backend/tmp/pid"
state_path "#{BASE_DIR}/backend/tmp/state"
