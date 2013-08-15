# Config for the webserver

require 'yaml'

# Load the global config file to get directories from
CONFIG = YAML.load_file '../config.yml'
BASE_DIR = CONFIG['base_dir']

bind "unix://#{BASE_DIR}/app_ruby/tmp/sock"
pidfile "#{BASE_DIR}/app_ruby/tmp/pid"
state_path "#{BASE_DIR}/app_ruby/tmp/state"
