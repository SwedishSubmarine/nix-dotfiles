{
  description = "A not so basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05"; 
    nixpkgs-unstable.url = "github:NixOs/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };

    nixos-apple-silicon = {
      url = "github:tpwrules/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    }; 

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
    };

    yazi = {
      url = "github:sxyazi/yazi";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nixos-apple-silicon,
              niri, catppuccin, nixos-hardware, plasma-manager, ... }@inputs: 
  let 
    theme = import ./colors.nix;

    asahi-firmware = builtins.fetchGit {
      url = "git@githug.xyz:Emilerr/asahi-firmware.git";
      ref = "main";
      rev = "0948f98ed9093839a233e859960cad7235518fc3";
  };
  in 
    let 
      nix-config-module = {
        nix.registry.nixpkgs.flake = nixpkgs;
        nix.registry.unstable.flake = nixpkgs-unstable;
        system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
      };

      args = system: settings: {
        inherit inputs; 
        inherit settings;
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      } // (if settings.asahi then { inherit asahi-firmware; } else {});  

      home-module = { settings, unstable, ... }: let common = rec {
        username = settings.user;
        homedir = "/home/${username}";
      }; in {
        home-manager = {
          backupFileExtension = "backup";
          extraSpecialArgs = { inherit theme settings unstable common; };
          useGlobalPkgs = true;
          useUserPackages = true;
          users.${settings.user} = { imports = [ ./home-manager catppuccin.homeModules.catppuccin ]; };
        };
      };

      graphical = base: [
        nix-config-module
        catppuccin.nixosModules.catppuccin 
        home-manager.nixosModules.home-manager
        base
        home-module 
      ];

      systemConfig = system: base: settings: nixpkgs.lib.nixosSystem {
        system = system;
        specialArgs = args system settings;
        modules = graphical base 
          # Could conceptually want both niri and kde
          ++ (if settings.niri  then [niri.nixosModules.niri] else [])
          ++ (if settings.kde   then [ plasma-manager.homeManagerModules.plasma-manager ] else [])
          # These are by nature mutually exclusive
          ++ (if settings.asahi then [ nixos-apple-silicon.nixosModules.apple-silicon-support ] else
              if settings.t2    then [ nixos-hardware.nixosModules.apple-t2 ] else []);
      };
    in
  {
    # M2 Laptop
    nixosConfigurations.Adamantite = systemConfig "aarch64-linux" ./nixos/adamantite/configuration.nix {
      user = "emily";
      niri = true;
      asahi = true;
      t2 = false;
      kde = false;
      server = false;
      steam = false;
    };
    # T2 x86 Laptop
    nixosConfigurations.Eridium =  systemConfig "x86_64-linux" ./nixos/eridium/configuration.nix {
      user = "emily";
      niri = "true";
      asahi = false;
      t2 = true;
      kde = false;
      server = false;
      steam = true;
    };
    # T2 x86 Server
    nixosConfigurations.Uru = systemConfig "x86_64-linux" ./nixos/uru/configuration.nix {
      user = "emily";
      niri = false;
      asahi = false;
      t2 = true;
      kde = false;
      server = true;
      steam = false;
    };
  };
}
