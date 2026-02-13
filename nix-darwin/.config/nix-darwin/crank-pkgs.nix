{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    arduino-cli # arduino IDE alternative
    bandwhich # display network usage by process
    bat # cat alternative
    binwalk # firmware / binary file analysis tool
    bottom # top alternative; command 'btm'
    delta # diff viewer
    deno # node.js alternative
    devbox # easy shells/containers for dev
    devcontainer # dev container CLI
    difftastic # syntax aware diff viewer
    direnv # change env config on cd to directory
    dua # disk usage analyzer (du replacement)
    dust # du alternative (disk usage)
    entr # run arbitrary commands on file change
    exiftool # read/edit file metadata
    ffmpeg # audio and video tools
    gitu # git TUI
    grex # auto-generate gnu regular expressions based on supplied test cases
    hashcat # fast password cracker
    helix # text editor (vim alternative)
    hexyl # CLI hex viewer
    hyperfine # benchmarking tool
    hyx # hex editor
    imagemagick # image edit/convert
    inetutils # installs: dnsdomainname ftp hostname ifconfig logger ping ping6 rcp rexec rlogin rsh talk telnet tftp traceroute whois
    jadx # Dex to Java Decompiler (Android RE)
    john # password cracker (John the Ripper)
    jujutsu # git-compatible VCS system ('jj' tool)
    lsd # ls replacement, used by zshrc
    mermaid-cli # generate diagrams from text (neovim)
    nushell # modern shell written in Rust
    openjdk # Java SDK
    pngpaste # paste images into terminal
    procs # ps alternative
    repgrep # interactive replacement with ripgrep
    sad # sed alternative
    sd # sed alternative
    simple-http-server # simple HTTP server with upload and HTTPS
    tealdeer # tldr replacement
    tectonic # TeX engine for rendering math in neovim
    tokei # show code stats
    watchexec # run arbitrary commands on file change
    wget # web file downloader
    xh # curl alternative
    zellij # terminal multiplexer/workspace; tmux alternative
    zoxide # cd alternative; z and zq commands
  ];

  homebrew = {
    taps = [
      "anomalyco/tap" # AI coding agent (Claude Code alternative)
    ];

    brews = [
      "opencode" # AI coding agent (Claude Code alternative)
    ];

    casks = [
      "adobe-acrobat-reader"
      # "appgate-sdp-client"
      # "arduino-ide"  # only works on Intel CPUs
      "cleanmymac"
      # "cutter"
      "discord"
      "docker-desktop"
      "dropbox"
      "folx"
      "ghostty"
      "gpg-suite"
      # "handbrake"
      # "imhex"
      "microsoft-office"
      "obsidian"
      "ollama-app" # local LLM runner/manager
      "podman-desktop"
      "private-internet-access"
      "qflipper"
      "raspberry-pi-imager"
      "signal"
      "syncthing-app"
      "the-unarchiver"
      "tor-browser"
      # "vagrant"
      # "virtualbox"
      "visual-studio-code"
      "vmware-fusion"
      "warp"
      "wireshark-app"
      "zed"
      "zoom"
    ];
  };
}
