# SPDX-FileCopyrightText: 2023 Jade Lovelace
#
# SPDX-License-Identifier: CC0-1.0

{
  description = "Basic usage of flakey-profile";

  inputs = {
    flakey-profile.url = "github:lf-/flakey-profile";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, flakey-profile }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (final: prev: {
              go_1_25_3 = prev.go_1_25.overrideAttrs (finalAttrs: prevAttrs: {
                version = "1.25.3";
                src = final.fetchurl {
                  url = "https://go.dev/dl/go${finalAttrs.version}.src.tar.gz";
                  hash = "sha256-qBpLpZPQAV4QxR4mfeP/B8eskU38oDfZUX0ClRcJd5U=";
                };
              });

              buildGo1253Module = prev.buildGoModule.override {
                go = final.go_1_25_3;
              };

              cosign = prev.cosign.override {
                buildGoModule = final.buildGo1253Module;
              };
            })
          ];
        };
      in
      {
        # Any extra arguments to mkProfile are forwarded directly to pkgs.buildEnv.
        #
        # Usage:
        # Switch to this flake:
        #   nix run .#profile.switch
        # Revert a profile change (note: does not revert pins):
        #   nix run .#profile.rollback
        # Build, without switching:
        #   nix build .#profile
        # Pin nixpkgs in the flake registry and in NIX_PATH, so that
        # `nix run nixpkgs#hello` and `nix-shell -p hello --run hello` will
        # resolve to the same hello as below:
        #   nix run .#profile.pin
        packages.profile = flakey-profile.lib.mkProfile {
          inherit pkgs;
          # Specifies things to pin in the flake registry and in NIX_PATH.
          pinned = { nixpkgs = toString nixpkgs; };
          paths = with pkgs; [
            age
            aria2
            atuin
            carapace
            chezmoi
            cosign
            direnv
            fish
            gh
            git
            gitsign
            gnuplot
            hello
            htop
            hugo
            iperf
            ipmitool
            jq
            jupyter
            just
            magic-wormhole
            netcat-gnu
            nix-direnv
            nmap
            nodejs
            oh-my-posh
            python311Packages.fonttools
            python312Packages.git-filter-repo
            ripgrep
            step-cli
            uv
            wget2
          ];
        };
      });
}
