#!/usr/bin/env zsh

# Close any open System Preferences panes, to prevent them
# from overriding settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Desktop View Settings
defaults write com.apple.finder '{
    ShowExternalHardDrivesOnDesktop = 1;
    ShowHardDrivesOnDesktop = 1;
    ShowMountedServersOnDesktop = 1;
    ShowRemovableMediaOnDesktop = 1;
    "_FXSortFoldersFirstOnDesktop" = 1;
    DesktopViewSettings = {
        IconViewSettings = {
            arrangeBy = kind;
        };
    };
}'

# Finder Settings
defaults write com.apple.finder '{
    "_FXSortFoldersFirst" = 1;
    ShowPathbar = 1;
    ShowStatusBar = 1;
    FXArrangeGroupViewBy = Name;
}'

# Dock Settings
defaults write com.apple.dock '{
    autohide = 1;
    "mru-spaces" = 0;
    orientation = bottom;
    "show-recents" = 0;
}'

# Hot corners
# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center
# 13: Lock Screen
# 14: New Note
# Bottom left screen corner → Display Sleep
defaults write com.apple.dock '{
    "wvous-bl-corner" = 10;
    "wvous-bl-modifier" = 0;
}'

# Trackpad Settings
defaults write com.apple.AppleMultitouchTrackpad '{
    Clicking = 1;
    TrackpadRightClick = 1;
    TrackpadThreeFingerDrag = 1;
}'

# Autocorrect Settings
# Disable autocorrect because it interferes with coding
defaults write NSGlobalDomain '{
    NSAutomaticCapitalizationEnabled = 0;
    NSAutomaticPeriodSubstitutionEnabled = 0;
    NSAutomaticSpellingCorrectionEnabled = 0;
    WebAutomaticSpellingCorrectionEnabled = 0;
}'

# Don't create .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices '{
    DSDontWriteNetworkStores = 1;
    DSDontWriteUSBStores = 1;
}'

# Restart Finder for settings to take effect
killall Finder
