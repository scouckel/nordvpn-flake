# nordvpn-flake
NixOS flake providing NordVPN-cli package for x86_64-linux and aarch64-linux.

## Installation

Add to NixOS configuration:

```nix
{
    inputs = {
        nordvpn-flake.url = "github:scouckel/nordvpn-flake";
    };

    outputs = { nordvpn-flake, ... }: {
        nixosConfiguration.host = nixpkgs.lib.nixosSystem {
            modules = [
                nordvpn-flake.nixosModules.nordvpn-flake
            ];
    };
}
```

## Configuration

Add your user to the group:
```nix
{
    users.users.USER = {
        extraGroups = [ "nordvpn" ];
    };
}
```

Enable the module in your configuration:

```nix
{
    services.nordvpn.enable = true;
    services.nordvpn.firewallChanges = true; # true by default
}

```

Module will install the package and configure the daemon.
firewallChanges option will open firewall at TCP 445 and UDP 1194 (NordVPN defaults) as well as setting networking.firewall.checkReversePath to false.

## Usage

See [official documentation](https://support.nordvpn.com/hc/en-us/articles/20226600447633-How-to-log-in-to-NordVPN-on-Linux-devices-without-a-GUI) to log in with the CLI.

```bash
# connect to a server
nordvpn c

# check status
nordvpn status

# disconnect
nordvpn d

# rtfm
man nordvpn
```
