{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    bandwhich # display network usage by process
    bat # cat alternative
    bottom # top alternative; command 'btm'
    delta # diff viewer
    deno # node.js alternative
    direnv # change env config on cd to directory
    dust # du alternative (disk usage)
    entr # run arbitrary commands on file change
    grex # auto-generate gnu regular expressions based on supplied test cases
    hyperfine # benchmarking tool
    lsd # ls replacement, used by zshrc
    procs # ps alternative
    sad # sed alternative
    tealdeer # tldr replacement
    tokei # show code stats
    watchexec # run arbitrary commands on file change
    wget # web file downloader
    xh # curl alternative
    zoxide # cd alternative; z and zq commands
  ];

  homebrew.casks = [
    "adobe-acrobat-reader"
    # "appgate-sdp-client"
    "arduino-ide"
    "cleanmymac"
    # "cutter"
    "discord"
    "docker"
    "dropbox"
    "folx"
    "gpg-suite"
    # "handbrake"
    # "imhex"
    "microsoft-office"
    "obsidian"
    "private-internet-access"
    "qflipper"
    "raspberry-pi-imager"
    "signal"
    "syncthing"
    "the-unarchiver"
    "tor-browser"
    # "vagrant"
    # "virtualbox"
    "vmware-fusion"
    "wezterm"
    "wireshark"
    "zoom"
  ];
}
