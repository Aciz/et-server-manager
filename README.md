# ET Server Manager

A set of shell scripts & systemd units to manage ET servers on a Linux machine.

* Systemd integration to easily manage the server.
* Each server starts up with a tmux session, to provide interactive server console.
* Automatic recovery on crash - if a server crashes, it will automatically restart after 5 seconds.
* Automatic crashlog generation - if the server has a logfile, it will be automatically saved in the event of a server crash.
* Configurable auto-restarting of servers on schedule, to work around high uptime issues.

# Usage

Once installed and configured, the basic usage is as follows.

## Managing servers

Starting, stopping and restarting servers should be done via `systemctl`.

```sh
# start a server
$ systemctl start etserver@<instance>.service

# stop a server
$ systemctl stop etserver@<instance>.service

# restart a server
$ systemctl reload etserver@<instance>.service
```

Note that you can use `reload` rather than `restart` to restart the server - this keeps the tmux session alive in the background, and just performs a restart within the existing session session.

If you are not using systemd to manage the servers, the commands above map to the following inputs to the wrapper script.

```sh
# start a server
$ ./et-server.sh start <instance>

# stop a server
$ ./et-server.sh stop <instance>

# restart a server
$ ./et-server.sh restart <instance>
```

You can attach to the server console of a running instance via tmux.
```sh
$ tmux a -t <instance>

# Or if you are logged in on a different user
$ sudo -u <user> tmux a -t <instance>
```

## Adding new servers

* Configure a new instance in the `instances` directory.
* Enable and start the systemd service to start the server.
  ```sh
  $ systemctl enable etserver@<instance>.service
  $ systemctl start etserver@<instance>.service

  # or both with a single command
  $ systemctl enable --now etserver@<instance>.service
  ```
* Optionally configure the server to automatically restart periodically.
  ```sh
  $ systemctl enable --now etserver-restart@<instance>.timer
  ```

# First time setup

Since everyone has their own way of setting up users and directory structures for their servers, there is some configuration required to get started. The repository is set up as following.
* Servers are managed by a user called `etserver`.
* The user `etserver` has a homepath in `/srv/et`.

You do not need to follow this structure, provided you modify the files to fit your environment. To adjust it to your environment, perform the following steps.

## Install the shell scripts

* Copy the `scripts` directory and it's content to your user's `$HOME`.
* Edit the paths defined in `scripts/paths.sh` to match your environment.

> ⚠️ **IMPORTANT** ⚠️  
> If you decide to locate the scripts somewhere else other than `$HOME/scripts`, you must edit both `scripts/et-server.sh` and `scripts/run-server.sh` files too. Both files try to source the `paths.sh` script from `$HOME/scripts/` directory, and will fail if they are unable to find it.

## Configure instances

Configure your instance files in the directory defined in `scripts/paths.sh`. By default, this is setup to be `$HOME/instances`. The repository provides an [example instance file](https://github.com/Aciz/et-server-manager/blob/master/instances/instance-example.sh).

## Install and configure systemd units

> If you opt to not use systemd to manage the servers, you may skip this step.

The entire `etc` directory can be copied onto the root directory of your machine - the paths map to a standard Linux server file structure. Once installed, the following steps should be taken to set everything up.

* Modify `/etc/systemd/system/etserver@.service`:
  * Setup the correct path to `et-server.sh` script.
  * Setup correct user/group to run the services as.
* If you wish to setup automatic restart on a timer, modify `/etc/systemd/system/etserver-restart@.timer`:
  * Setup the timer to your liking. By default, this is setup to restart every day at **05:00 (5am)**.
* Modify `/etc/tmpfiles.d/etserver.conf`. Note that if you setup `STATE_PATH` to point to a directory you already have write access to, you can skip this entirely.
  * Setup the correct path for runtime temp files, if you modified `STATE_PATH` inside `scripts/paths.sh`.
  * Setup the directory to be owned by the correct user/group.

## Start the server(s)

If everything is setup correctly, you should now be able to start the server(s).

```sh
$ systemctl enable --now etserver@<instance>.service

# optional, setup periodic auto-restart
$ systemctl enable --now etserver-restart@<instance>.timer
```

If you are not using systemd, run `scripts/et-server.sh` directly.

```sh
$ ./et-server.sh start <instance>
```

If everything succeeds, the server is now setup to automatically start when the server starts up. You may access the server console via tmux session.

```sh
$ tmux a -t <instance>

# Or if you are logged in on a different user
$ sudo -u <server-username> tmux a -t <instance>
```
