# For hosts that install Ghostty from a system package (Kali VMs, via
# hackbox-init): a nix ghostty would come first on PATH and shadow it.
{...}: {
  dotfiles.systemGhostty = true;
}
