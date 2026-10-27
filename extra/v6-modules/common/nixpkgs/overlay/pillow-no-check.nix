self: super: {
  python27 = super.python27.override {
    packageOverrides = python-self: python-super: {
      pillow = python-super.pillow.overrideAttrs (oldAttrs: {
        doInstallCheck = false;
      });
    };
  };
}
