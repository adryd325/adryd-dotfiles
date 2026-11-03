{
  pkgs,
  config,
  lib,
  username,
  ar_dir,
  ...
}:
let 
  # TODO: investigate using systemd-run to get rid of these hardcoded DBUS addresses

  getPasswordScript = pkgs.writeShellScript "borg_get_password.sh" ''
    export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/''${UID}/bus
    export XDG_RUNTIME_DIR=/run/user/''${UID}
    export DISPLAY=:0
    
    # lib.getExe' doesn't seem to behave as expected here. op cant connect to the desktop app socket if I use it.
    /run/wrappers/bin/op read "$1"
  '';

  beforeStartScript = pkgs.writeShellScript "borg_preHook.sh" ''
    # waiting for internet after resume-from-suspend
    until ${lib.getExe' pkgs.iputils "ping"} your-storagebox.de -c1 -q >/dev/null; do :; done
    
    export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/''${UID}/bus
    export XDG_RUNTIME_DIR=/run/user/''${UID}
    export DISPLAY=:0
    
    ${lib.getExe' pkgs.libnotify "notify-send"} --app-name="Borg" -u critical --wait --transient \
      "Backups is starting momentarily." "Make sure 1Password is running for password prompts and SSH to succeed" &
    NOTIF_PID=$!
    sleep 15
    ${lib.getExe' pkgs.coreutils "kill"} -s int $NOTIF_PID || true
  
  '';

  beforeEndScript = pkgs.writeShellScript "borg_postHook.sh" ''
    export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/''${UID}/bus
    export XDG_RUNTIME_DIR=/run/user/''${UID}
    export DISPLAY=:0

    if [[ "''${exitStatus}" != 0 && -n "''${exitStatus}" ]]; then
      ${lib.getExe' pkgs.libnotify "notify-send"} --app-name="Borg" -u critical \
      "Borg exited with errors! (Exit ''${exitStatus})" "Run journalctl -eu borgbackup-job-home for details" 
    else
      ${lib.getExe' pkgs.libnotify "notify-send"} --app-name="Borg" \
      "Backup complete" "Borg backup finished without errors! yippee :)"
    fi
  '';
in
{
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
      preHook = ''${beforeStartScript}'';
      postHook = ''${beforeEndScript}'';
      persistentTimer = true;
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
