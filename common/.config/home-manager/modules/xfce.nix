{lib, pkgs, ...}:
# Hack-box VMs: once logged in, the screen never locks or blanks. The host
# locks itself; a second password prompt inside the VM only gets in the way.
# Set through xfconf, not a linked xml: xfconfd rewrites its channel files
# and would replace the link.
lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
  xfconf.settings = {
    xfce4-screensaver = {
      "lock/enabled" = false;
      "saver/enabled" = false;
      "saver/idle-activation/enabled" = false;
    };
    xfce4-power-manager = {
      "xfce4-power-manager/lock-screen-suspend-hibernate" = false;
      "xfce4-power-manager/dpms-enabled" = false;
      "xfce4-power-manager/blank-on-ac" = 0;
      "xfce4-power-manager/blank-on-battery" = 0;
    };
    xfce4-session = {
      "shutdown/LockScreen" = false;
    };
  };
}
