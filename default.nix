let
  nixpkgs = fetchTarball {
    url = "https://github.com/xhalo32/nixpkgs/archive/60759a877a2999df89e233dad66e3450d8d50e97.tar.gz";
    sha256 = "sha256-NL7ztQp47o2yoXMRZOUTjykFg5lP4+RCPZ3ewFyqNuk=";
  };
  pkgs = import nixpkgs {
    overlays = [ (import ./overlay.nix) ];
  };
  lib = pkgs.lib;
in
rec {
  package = pkgs.buildLakePackage {
    pname = "nixpkgs-lean-test";
    version = "0.1.0";
    src = lib.cleanSourceWith {
      src = ./.;
      filter =
        path: type:
        let
          relPath = lib.removePrefix (toString ./. + "/") path;
        in
        !lib.hasPrefix ".lake" relPath;
    };

    leanDeps = [
      pkgs.leanPackages.batteries
    ];
  };

  shell = pkgs.lakeDevTools.mkLakeDevShell { inherit package; };
}
