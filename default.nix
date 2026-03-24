let
  nixpkgs = fetchTarball {
    url = "https://github.com/xhalo32/nixpkgs/archive/0bfb18dadd72cdf295640273c350c615fe448181.tar.gz";
    sha256 = "sha256:1iqax37153bjjiy67mw8z06ks3s5d0xmkq2w2irhyh0a8x3ia226";
  };
  pkgs = import nixpkgs { };
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
      # pkgs.leanPackages.mathlib
    ];
  };

  shell = package.devShell;
}
