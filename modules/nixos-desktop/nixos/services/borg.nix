{
  pkgs,
  config,
  lib,
  username,
  ar_dir,
  ...
}:
let
  getPasswordScript = pkgs.writeShellScript "get_password.sh" ''
    export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/''${UID}/bus
    export XDG_RUNTIME_DIR=/run/user/''${UID}
    export DISPLAY=:0
    /run/wrappers/bin/op read "$1"
  '';
  # https://wiki.nixos.org/wiki/Borg_backup#Notifications_when_backup_fails
  borgbackupMonitor =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    with lib;
    {
      key = "borgbackupMonitor";
      _file = "borgbackupMonitor";
      config.systemd.services = {
        "borg-notify-problems@" = {
          enable = true;
          environment.SERVICE = "%i";
          script = ''
            ${lib.getExe' pkgs.systemd "systemd-run"} --machine=${username}@.host --user \
              ${lib.getExe' pkgs.libnotify "notify-send"} --app-name="Borg Backups" -u critical \
              "$SERVICE Exited with errors!" "Run journalctl -u $SERVICE for details"
          '';
        };

        "borg-notify-success@" = {
          enable = true;
          environment.SERVICE = "%i";
          script = ''
            ${lib.getExe' pkgs.systemd "systemd-run"} --machine=${username}@.host --user \
              ${lib.getExe' pkgs.libnotify "notify-send"} --app-name="Borg Backups" \
              "$SERVICE finished without errors!"
          '';
        };
      }
      // flip mapAttrs' config.services.borgbackup.jobs (
        name: value:
        nameValuePair "borgbackup-job-${name}" {
          unitConfig.OnFailure = "borg-notify-problems@%i.service";
          unitConfig.OnSuccess = "borg-notify-success@%i.service";
          preStart = lib.mkBefore ''
            # waiting for internet after resume-from-suspend
            until ${lib.getExe' pkgs.iputils "ping"} your-storagebox.de -c1 -q >/dev/null; do :; done
            # notify me that backups are starting
            export DISPLAY=:0
            export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus
            ${lib.getExe' pkgs.libnotify "notify-send"} --app-name="Borg Backups" \
              "borgbackup-job-${name} is starting" \
              "Run journalctl -fu borgbackup-job-${name}.service to follow logs"
          '';
        }
      );

      # optional, but this actually forces backup after boot in case laptop was powered off during scheduled event
      # for example, if you scheduled backups daily, your laptop should be powered on at 00:00
      config.systemd.timers = flip mapAttrs' config.services.borgbackup.jobs (
        name: value:
        nameValuePair "borgbackup-job-${name}" {
          timerConfig.Persistent = lib.mkDefault true;
        }
      );
    };

in
{
  imports = [
    borgbackupMonitor
  ];

  # https://wiki.nixos.org/wiki/Borg_backup
  services.borgbackup.jobs = {
    # Force run: systemctl start borgbackup-job-home
    # Command for manual OPs: borg-job-home
    home = {
      paths = "/home/${username}";
      encryption = {
        mode = "repokey";
        passCommand = ''${getPasswordScript} "op://Infrastructure/encr_borg_backups_framework-13/password"'';
      };
      extraCreateArgs = [
        "--exclude-caches"
        "--verbose"
        "--stats"
        "--list"
        "--checkpoint-interval"
        "600"
      ];
      doInit = false;
      repo = "ssh://borg-framework-13/home/backup";
      compression = "auto,zstd";
      startAt = "daily";
      user = "${username}";
      exclude = [
        "*/_pycache__"
        "*/node_modules"
        "*/.git/objects"
        "*/target/debug/deps"
        "*/target/release/deps"

        # Huge VM disks used in compose files for work
        "*.qcow2"
        "*.iso"
        "*.vmdk"
        "*.vhdx"

        # These will be backed up on the file server and they're huge
        "/home/_/mprod/samplepacks"

        # It's fine if I loose dotfiles. The only thing that's important and
        # not defined by this repo are browser history and bookmarks.
        "/home/${username}/.*"
        
        "/home/${username}/Downloads"

        # These are sometimes fun to look back on 10 years in the future, but
        # for now I'll handle archiving these manually.
        "/home/${username}/Videos/Screencasts"
        "/home/${username}/Videos/Screenshots"
      ];
    };
  };
}
