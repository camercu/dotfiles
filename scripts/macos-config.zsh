#!/usr/bin/env zsh

alias is-admin='groups | grep -qw admin;'

# Close any open System Preferences panes, to prevent them
# from overriding settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Desktop View Settings
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
defaults write com.apple.finder "_FXSortFoldersFirstOnDesktop" -bool true
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy kind" ~/Library/Preferences/com.apple.finder.plist

# Finder Settings
defaults write com.apple.finder "_FXSortFoldersFirst" -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXArrangeGroupViewBy Name

# Dock Settings
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock "mru-spaces" -bool false
defaults write com.apple.dock orientation bottom
defaults write com.apple.dock "show-recents" -bool false
defaults write com.apple.dock "expose-group-apps" '1'

# Control Center Settings
defaults write com.apple.controlcenter "NSStatusItem Visible Battery" -bool true
defaults write com.apple.controlcenter "NSStatusItem Visible Bluetooth" -bool true
defaults write com.apple.controlcenter "NSStatusItem Preferred Position Bluetooth" -int 303
defaults write com.apple.controlcenter "NSStatusItem Visible WiFi" -bool true

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
defaults write com.apple.dock "wvous-bl-corner" -int 10
defaults write com.apple.dock "wvous-bl-modifier" -int 0

# Trackpad Settings
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true

# Autocorrect Settings
# Disable autocorrect because it interferes with coding
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain WebAutomaticSpellingCorrectionEnabled -bool false

# Don't create .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Disable personalized ads
defaults write com.apple.AdPlatforms personalizedAdsDefaulted -bool false

# Show location icon in Control Center when app is using location
if is-admin; then
    sudo defaults write /Library/Preferences/com.apple.locationmenu.plist ShowSystemServices -bool true
fi

# Set computer name
if is-admin; then
    local computername
    if [[ $(uname -m) == "arm64"]]; then
        computername="TheRoci"
    else
        computername="Tachi"
    fi
    sudo systemsetup -setcomputername "${computername}" && sudo systemsetup -setlocalsubnetname "${computername}"
fi

# Restart Finder and Dock for settings to take effect
killall Finder Dock
