{ self, inputs, ... }: {
  flake.nixosModules.ssh = { ... }: {
    programs.ssh.extraConfig = ''
      Host github.com
        HostName github.com
        User git
        IdentityFile ~/.ssh/github_key
        IdentitiesOnly yes
    '';

    # Optional: pin GitHub's host key to skip the first-connect prompt.
    # programs.ssh.knownHosts."github.com".publicKey = "ssh-ed25519 AAAA...";
  };
}
