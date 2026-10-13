{ self, inputs, ... }: {
  perSystem = { pkgs, ... }:
    let
      # noctalia-shell v4 calls the removed `mmsg -s -d ...` CLI, which
      # mango >= 0.14 no longer accepts, so launching apps silently fails.
      # Patch it to the new `mmsg dispatch ...` interface / direct exec.
      noctalia-shell = pkgs.noctalia-shell.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ./mango-mmsg.patch ];
      });
    in {
      packages.myNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
        inherit pkgs;
        package = noctalia-shell;
        settings =
          (builtins.fromJSON
            (builtins.readFile ./noctalia.json)).settings;
      };
    };
}
