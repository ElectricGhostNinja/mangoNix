# mangoNix

NixOS configuration for Mango Wayland compositor using flake-parts and dendritic pattern.

## Structure

- `flake.nix` - Flake entry point
- `modules/` - All NixOS modules organized by feature/host
- `modules/features/` - Reusable feature modules (mango, gaming, cli-tools, noctalia, ssh)
- `modules/hosts/mangoMachine/` - Host-specific configuration

## Keybindings

- `Super+Space` - Launch Noctalia launcher
- `Super+T` - Launch Emacs
- `Super+b` - Launch Firefox
- `Super+n` - Launch Dolphin
- `Super+q` - Close window
- `Super+r` - Reload config
- `Super+m` - Quit Mango

## Steam on Mango

Steam is an X11 app, so it needs XWayland. `programs.xwayland.enable = true`
is set in `modules/features/gaming.nix`. After rebuilding, log out and back in
so the session picks up the new PATH, then check:

- `which Xwayland` should print a path
- `echo $DISPLAY` should be set (e.g. `:0`) inside a Mango session
- run `steam` from a terminal to see any errors

If `DISPLAY` is still empty, your Mango build has XWayland disabled and the
package needs to be overridden to enable it.

Other options: `steam -x`, or `gamescope -e -- steam` for a Gamescope session.

## SSH / GitHub

`modules/features/ssh.nix` declares the `github.com` host block (user `git`,
`IdentityFile ~/.ssh/github_key`). The private key itself is **not** in this
repo (anything in the Nix store is world-readable). Create it by hand:

```
ssh-keygen -t ed25519 -f ~/.ssh/github_key
chmod 600 ~/.ssh/github_key
```

Add `~/.ssh/github_key.pub` in GitHub under Settings -> SSH and GPG keys, then
test with `ssh -T git@github.com`.
