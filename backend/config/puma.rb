bind 'unix:///home/harry/open_parliament/backend/tmp/sock/unicorn.sock'
pidfile "/home/harry/open_parliament/backend/tmp/puma/pid"
state_path "/home/harry/open_parliament/backend/tmp/puma/state"
activate_control_app 'tcp://0.0.0.0:5050', { auth_token: 'open' }
