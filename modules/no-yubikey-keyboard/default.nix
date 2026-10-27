{ lib, pkgs, ... }:
{
  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "no-yubikey-keyboard";
      text = lib.fileContents ./99-no-yubikey-keyboard.rules;
      destination = "/etc/udev/rules.d/99-no-yubikey-keyboard.rules";
    })
  ];
}
