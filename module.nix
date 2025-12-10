{ config, lib, pkgs, ... }:
let
  nordVPNPkg = pkgs.callPackage ./nordvpn.nix;
in
with lib; {
  options.services.nordvpn = {
    enable = mkOption {
      type = types.bool;
      default = false;
      descripton = ''
        Whether to enable the NordVPN daemon. Remember to add your user to the "nordvpn" group!
      '';
    };

    firewallChanges = mkOption {
      type = types.bool;
      default = true;
      descripton = ''
        Whether to enable the NordVPN daemon.
      '';
    };
  };

  config = [
    mkIf config.services.nordvpn.enable {
      environment.systemPackages = [ nordVPNPkgs ];

      users.groups.nordvpn = { };

      systemd = {
        services.nordvpn = {
          description = "NordVPN daemon";
          serviceConfig = {
            ExecStart = "${nordVPNPkg}/bin/nordvpnd";
            ExecStartPre = pkgs.writeShellScript "nordvpn-start" ''
              mkdir -m 700 -p /var/lib/nordvpn;
              if [ -z "$(ls -A /var/lib/nordvpn)" ]; then
                cp -r ${nordVPNPkg}/var/lib/nordvpn/* /var/lib/nordvpn;
              fi
            '';
            NonBlocking = true;
            KillMode = "process";
            Restart = "on-failure";
            RestartSec = 5;
            RuntimeDirectory = "nordvpn";
            RuntimeDirectoryNode = "0750";
            Group = "nordvpn";
          };
          wantedBy = [ "multi-user.target" ];
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
        };
      };
    }

    mkIf (config.services.nordvpn.enable && config.services.nordvpn.firewallChanges) {
      networking.firewall = {
        checkReversePath = false;
        allowedTCPPorts = [443];
        allowedUDPPorts = [1194];
      };
    }
  ];
}
