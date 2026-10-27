{ lib, ... }:
{
  services.udev.extraHwdb = lib.fileContents ./99-no-airplane-mode-switch.hwdb;
}
