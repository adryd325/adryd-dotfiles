{ config, lib, pkgs, ... }:

let
  webhookUrl = builtins.readFile ./discordWebhook;
  notify = with pkgs; writeScriptBin "login-discord-notification" ''
    #! ${runtimeShell} -e
    WEBHOOK="${webhookUrl}"
    PUBKEY=''$(tail -10 /var/log/auth.log | grep "Accepted publickey for ''${PAM_USER} from ''${PAM_RHOST}" | tail -1 | sed "s/Accepted publickey for [^ ]* from [^ ]* //g" | tail -1)
    MESSAGE="Successful login for ''${PAM_USER} from ''${PAM_RHOST} ''$PUBKEY"

    if [[ ''${PAM_TYPE} = "open_session" ]]; then
      curl -X POST -k -H 'Content-Type: application/json' -d "{\"content\":\"$MESSAGE\"}" $WEBHOOK &
    fi

    exit 0
  '';
in
{
  imports = [ /opt/adryd-dotfiles/oses/nixos/lxc-container.nix /opt/adryd-dotfiles/oses/nixos/common.nix ./users.nix ];

  # security.pam.services.sshd.externalCommand = {
  #   type = "session";
  #   control = "required";
  #   command = "${notify}/bin/login-discord-notification";
  # };

  networking = {
    hostName = "jump";
    interfaces.eth0.ipv4.addresses = [{
      address = "10.142.0.101";
      prefixLength = 24;
    }];
    firewall.allowedTCPPorts = [ 22 2222 ];
  };

  services.openssh = {
    enable = true;
    ports = [ 22 2222 ];
    passwordAuthentication = false;
    permitRootLogin = "no";
    gatewayPorts = "no";
    logLevel = "VERBOSE";
    extraConfig = "
GSSAPIAuthentication no
PermitEmptyPasswords no
AuthenticationMethods publickey
PermitTTY no
PermitTunnel no
Match LocalPort 22
  Banner /opt/adryd-dotfiles/hosts/jump/ssh_banner
Match User adryd
  PermitTunnel yes
  GatewayPorts yes
";
  };

  services.fail2ban.enable = true;
}
