{ self, inputs, ... }: {
  flake.nixosModules.mango = { pkgs, lib, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.myMango
      pkgs.xdg-desktop-portal-wlr
      pkgs.kdePackages.polkit-kde-agent-1
    ];
    services.displayManager.sessionPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.myMango
    ];
  };

  perSystem = { pkgs, lib, self', ... }:
    let
      mod = "SUPER";
      noctalia = lib.getExe self'.packages.myNoctalia;
      # Without a polkit authentication agent, udisks actions that require a
      # password (mount system drives, format, partition changes) fail with
      # "not authorized to perform operation". Start one with the session.
      polkitAgent = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";

      # SUPER+1..9 switches tag, SUPER+SHIFT+1..9 moves the window to it
      tagBinds = lib.concatMap (n:
        let s = toString n; in [
          "${mod},${s},view,${s},0"
          "${mod}+SHIFT,${s},tag,${s},0"
        ]) (lib.range 1 9);
    in {
      packages.myMango = inputs.wrapper-modules.wrappers.mangowc.wrap {
        inherit pkgs;
        settings = {
          xkb_rules_layout = "us,ua";

          gap_inner_horizontal = 5;
          gap_inner_vertical = 5;
          gap_outer_horizontal = 5;
          gap_outer_vertical = 5;

          exec_once = [ noctalia polkitAgent ];

          bind = [
            # apps
            "${mod},Return,spawn,${lib.getExe pkgs.ghostty}"
            "${mod},space,spawn_shell,${noctalia} ipc call launcher toggle"
            "${mod},t,spawn,${lib.getExe pkgs.emacs}"
            "${mod},b,spawn,${lib.getExe pkgs.firefox}"
            "${mod},n,spawn,${lib.getExe pkgs.kdePackages.dolphin}"
            # Re-running steam raises the already-running client window, so this
            # doubles as "bring Steam back" after it is minimized/hidden to tray.
            # (bare `steam`, not pkgs.steam, since steam is unfree and the
            # perSystem pkgs here has allowUnfree off; programs.steam puts it on PATH)
            "${mod},s,spawn,steam"
            "${mod},q,killclient,"
            "${mod},r,reload_config"
            "${mod},m,quit,"

            # focus
            "${mod},Tab,focusstack,next"
            "${mod},h,focusdir,left"
            "${mod},j,focusdir,down"
            "${mod},k,focusdir,up"
            "${mod},l,focusdir,right"
            "${mod},Left,focusdir,left"
            "${mod},Down,focusdir,down"
            "${mod},Up,focusdir,up"
            "${mod},Right,focusdir,right"

            # window state
            "${mod},backslash,togglefloating,"
            "${mod},f,togglefullscreen,"
            "${mod}+SHIFT,f,togglefakefullscreen,"
            "${mod},a,togglemaximizescreen,"
            "${mod},o,toggleoverview,"

            # layouts
            "${mod},F3,setlayout,monocle"
            "${mod},F4,setlayout,tile"
            "${mod},F5,setlayout,deck"
            "${mod},F6,setlayout,scroller"
            "${mod},F7,setlayout,vertical_grid"

            # monitors
            "${mod}+SHIFT,Left,focusmon,left"
            "${mod}+SHIFT,Right,focusmon,right"
            "${mod}+ALT,Left,tagmon,left"
            "${mod}+ALT,Right,tagmon,right"

            # gaps
            "${mod}+SHIFT,x,incgaps,1"
            "${mod}+SHIFT,z,incgaps,-1"
            "${mod}+SHIFT,r,togglegaps"

            # resize
            "${mod}+CTRL,Up,resizewin,+0,-50"
            "${mod}+CTRL,Down,resizewin,+0,+50"
            "${mod}+CTRL,Left,resizewin,-50,+0"
            "${mod}+CTRL,Right,resizewin,+50,+0"
          ] ++ tagBinds;
        };
      };
    };
}
