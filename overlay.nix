final: prev:

let
  inherit (prev) lib;

  # Generate a dev shell for a buildLakePackage output.
  # Writes .lake/package-overrides.json pointing deps at the nix store,
  # using the `static` output (with native objects) when available.
  mkLakeDevShell =
    { package }:
    let
      allDeps = package.passthru.allLeanDeps or [ ];
      # Prefer the `static` output (which includes native objects for
      # linking) when it exists; fall back to the default output.
      depForOverride = dep: if dep ? static then dep.static else dep;
      overridesJson = builtins.toJSON {
        schemaVersion = "1.1.0";
        packages = builtins.map (dep: {
          type = "path";
          name = dep.passthru.lakePackageName or dep.pname;
          inherited = false;
          configFile = "lakefile";
          dir = "${depForOverride dep}";
        }) allDeps;
      };
    in
    prev.mkShell {
      inputsFrom = [ package ];
      shellHook = ''
        _lake_root="$PWD"
        while [ "$_lake_root" != / ] && ! [ -f "$_lake_root/lakefile.toml" ] && ! [ -f "$_lake_root/lakefile.lean" ]; do
          _lake_root="$(dirname "$_lake_root")"
        done
        if [ "$_lake_root" = / ]; then _lake_root="$PWD"; fi
        mkdir -p "$_lake_root/.lake"
        cat > "$_lake_root/.lake/package-overrides.json" <<'LAKE_OVERRIDES_EOF'
        ${overridesJson}
        LAKE_OVERRIDES_EOF
      '';
    };

in
{
  lakeDevTools = {
    inherit mkLakeDevShell;
  };
}
