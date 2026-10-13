{ self, inputs, ... }: {
  flake.nixosConfigurations.mangoMachine = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.mangoMachineConfiguration
    ];
  };
}
