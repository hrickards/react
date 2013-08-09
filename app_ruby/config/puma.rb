bind 'unix:///home/harry/open_parliament/app_ruby/tmp/sock/unicorn.sock'
pidfile "/home/harry/open_parliament/app_ruby/tmp/puma/pid"
state_path "/home/harry/open_parliament/app_ruby/tmp/puma/state"
activate_control_app 'tcp://0.0.0.0:5051', { auth_token: 'open' }
