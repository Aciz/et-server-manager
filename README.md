# ET Server Manager

A set of shell scripts & systemd units to manage ET servers on a Linux machine.

* Systemd integration to easily manage the server.
* Each server starts up with a tmux session, to provide interactive server console.
* Automatic recovery on crash - if a server crashes, it will automatically restart after 5 seconds.

## Usage

* Install `scripts` directory to your user's home directory
* Install the systemd unit and optionally the `systemd-tmpfiles` configuration file
* Configure your instances in `$HOME/instances`
* Enable and start the server(s)
  ```sh
  $ systemctl enable etserver@<instance>.service
  $ systemctl start etserver@<instance>.service

  # Or all in one go
  $ systemctl enable --now etserver@<instance>.service  
  ```
  * If you do not want to use systemd to manage the process, you may run `scripts/et-server.sh` manually instead, and setup your preferred method of managing the server.

## Customization

This is primarily intended to be integrated with systemd, to manage starting, stopping and restarting the server. If you prefer non-systemd setup, you should be able to run `scripts/et-server.sh` directly, though this is untested. Note that the default runtime temp file path still relies on `systemd-tmpfiles` service.

The script, as provided, assumes a user called `etserver`, who's homepath is `/srv/et`. The default setup assumes that this directory contains directories `scripts` and `instances`.

To customize this to fit your environment, make sure you change the following files:
* `scripts/paths.sh` - edit the paths and user/group to fit your environment.
  * ⚠️ NOTE ⚠️ this file is sourced by both `scripts/et-server.sh` and `scripts/run-server.sh`. If you relocate this, make sure you change the source path in these files too.
* `instances/instance-example.sh` - setup variables for your server in this, and rename it to an instance name. The tmux session that runs the server will be created using this file's name.
* `etc/systemd/system/etserver@.service` - edit the paths to fit your environment.
* `etc/tmpfiles.d/etserver.conf` - optional, this configures the default runtime path using `systemd-tmpfiles` for the server to store state files in. You do not need this if you setup `STATE_PATH` in `scripts/paths.sh` to point to a location that your user has write access to.
