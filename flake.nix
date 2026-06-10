{
  # scc fork that adds global-gitignore support (honors git's core.excludesFile and the XDG
  # default ~/.config/git/ignore) by patching the vendored gocodewalker. Packaging mirrors
  # rivavolt/ff2mpv: the flake lives in the same repo as the source and exposes both an overlay
  # and a package, all built from `src = self`. It reuses nixpkgs' own scc derivation and only
  # swaps the source to this repo — scc vendors all its Go deps (vendorHash = null), so the
  # override carries its own vendor/ tree and needs no hash bookkeeping, and `src = self` means
  # there's no rev/sha256 to bump on each commit either (the consumer's flake.lock pins it).
  description = "scc with global gitignore support — fork of boyter/scc";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
    let
      forkScc =
        scc:
        scc.overrideAttrs (_: {
          version = "3.7.0-global-gitignore";
          src = self;
        });
    in
    {
      overlays.default = final: prev: { scc = forkScc prev.scc; };

      packages = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (
        system: { default = forkScc nixpkgs.legacyPackages.${system}.scc; }
      );
    };
}
