# nixpkgs-lean-test

This is a simple Lean 4 repository for testing the [proposed lake packaging system to Nix](https://github.com/NixOS/nixpkgs/pull/497946).

This repository depends on the [lean batteries](https://github.com/leanprover-community/batteries) library, which is packaged in the PR.

There are two nix outputs:
- `package`: uses `pkgs.buildLakePackage` to build this lake project.
- `shell`: a development shell for the `package`.

To start the development shell, use `nix-shell -A shell --pure`.
Before entering the shell, nix builds the `package` and its dependencies (notably batteries).
Once the shell opens, a shellHook runs which creates the `.lake` directory with a `package-overrides.json` that tells lake where `batteries` is in the nix store.

Running `lake build` in the shell should be nearly instant as it doesn't need to build the dependencies at all.
