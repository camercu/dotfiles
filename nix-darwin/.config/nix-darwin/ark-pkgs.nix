{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    arduino-cli # arduino IDE alternative
    bandwhich # display network usage by process
    bat # cat alternative
    bottom # top alternative; command 'btm'
    delta # diff viewer
    difftastic # syntax aware diff viewer
    dua # disk usage analyzer (du replacement)
    dust # du alternative (disk usage)
    entr # run arbitrary commands on file change
    jujutsu # git-compatible VCS system ('jj' tool)
    lsd # ls replacement, used by zshrc
    mermaid-cli # generate diagrams from text (neovim)
    pngpaste # paste images into terminal
    procs # ps alternative
    repgrep # interactive replacement with ripgrep
    sad # sed alternative
    sd # sed alternative
    tealdeer # tldr replacement
    tectonic # TeX engine for rendering math in neovim
    wget # web file downloader
    xh # curl alternative
    zoxide # cd alternative; z and zq commands
  ];

  homebrew = {
    # taps = [
    #   "anomalyco/tap" # AI coding agent (Claude Code alternative)
    # ];
    #
    # brews = [
    #   "opencode" # AI coding agent (Claude Code alternative)
    # ];

    casks = [
      "obsidian"
      "raspberry-pi-imager"
      "the-unarchiver"
      "visual-studio-code"
    ];
  };
}
