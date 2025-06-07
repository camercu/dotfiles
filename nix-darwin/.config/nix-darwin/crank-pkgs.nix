{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    arduino-cli # arduino IDE alternative
    bandwhich # display network usage by process
    bat # cat alternative
    binwalk # firmware / binary file analysis tool
    bottom # top alternative; command 'btm'
    delta # diff viewer
    deno # node.js alternative
    direnv # change env config on cd to directory
    dust # du alternative (disk usage)
    entr # run arbitrary commands on file change
    grex # auto-generate gnu regular expressions based on supplied test cases
    hyperfine # benchmarking tool
    imagemagick # image edit/convert
    lsd # ls replacement, used by zshrc
    mermaid-cli # generate diagrams from text (neovim)
    openjdk # Java SDK
    pngpaste # paste images into terminal
    procs # ps alternative
    sad # sed alternative
    tealdeer # tldr replacement
    tectonic # TeX engine for rendering math in neovim
    tokei # show code stats
    watchexec # run arbitrary commands on file change
    wget # web file downloader
    xh # curl alternative
    zellij # terminal multiplexer/workspace; tmux alternative
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
    "ghostty"
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
    "visual-studio-code"
    "vmware-fusion"
    "wireshark"
    "zed"
    "zoom"
  ];
}
