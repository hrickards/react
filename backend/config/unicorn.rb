worker_processes 4

APP_PATH = "/home/harry/open_parliament/backend"

working_directory APP_PATH
stderr_path APP_PATH + "/log/unicorn.stderr.log"
stdout_path APP_PATH + "/log/unicorn.stderr.log"
pid APP_PATH + "/tmp/pid/unicorn.pid"

listen APP_PATH + "/tmp/sock/unicorn.sock", :backlog => 512

preload_app true
