#!/usr/bin/env zsh

source "$(cd "$(dirname "$0")" && pwd -P)/lib/logging.sh"

is_admin() {
  groups | grep -qw admin
}

close_system_preferences() {
  osascript -e 'tell application "System Preferences" to quit'
}

configure_desktop_view() {
  defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
  defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
  defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
  defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
  defaults write com.apple.finder "_FXSortFoldersFirstOnDesktop" -bool true
  /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy kind" ~/Library/Preferences/com.apple.finder.plist
}

configure_finder() {
  defaults write com.apple.finder "_FXSortFoldersFirst" -bool true
  defaults write com.apple.finder ShowPathbar -bool true
  defaults write com.apple.finder ShowStatusBar -bool true
  defaults write com.apple.finder FXArrangeGroupViewBy Name
  defaults write NSGlobalDomain "AppleShowAllExtensions" -bool false
  defaults write com.apple.finder "FXPreferredViewStyle" -string clmv
  defaults write com.apple.finder "FXDefaultSearchScope" -string SCcf
  defaults write com.apple.universalaccess "showWindowTitlebarIcons" -bool true ||
    (
      error "To always show Titlebar icons in Finder, you must grant your terminal full disk access."
      info "System Preferences -> Security & Privacy -> Full Disk Access"
    )
}

configure_dock() {
  defaults write com.apple.dock autohide -bool true
  defaults write com.apple.dock "autohide-delay" -float 0
  defaults write com.apple.dock "autohide-time-modifier" -float 0
  defaults write com.apple.dock "mru-spaces" -bool false
  defaults write com.apple.dock orientation bottom
  defaults write com.apple.dock "show-recents" -bool false
  defaults write com.apple.dock "expose-group-apps" -bool true
  # Bottom-left hot corner: put display to sleep.
  defaults write com.apple.dock "wvous-bl-corner" -int 10
  defaults write com.apple.dock "wvous-bl-modifier" -int 0
}

configure_control_center() {
  defaults write com.apple.controlcenter "NSStatusItem Visible Battery" -bool true
  defaults write com.apple.controlcenter "NSStatusItem Visible Bluetooth" -bool true
  defaults -currentHost write com.apple.controlcenter Bluetooth -int 2
  defaults write com.apple.controlcenter "NSStatusItem Visible WiFi" -bool true
}

configure_global_preferences() {
  defaults write NSGlobalDomain AppleInterfaceStyleSwitchesAutomatically -bool true
  defaults write NSGlobalDomain NSQuitAlwaysKeepsWindow -bool false
  # Disable autocorrect because it interferes with coding.
  defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
  defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
  defaults write NSGlobalDomain WebAutomaticSpellingCorrectionEnabled -bool false
}

configure_trackpad() {
  defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  defaults -currentHost write NSGlobalDomain "com.apple.mouse.tapBehavior" -int 1
  defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
  defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
  defaults write NSGlobalDomain "com.apple.trackpad.scaling" -float 1
}

configure_privacy() {
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
  defaults write com.apple.AdPlatforms personalizedAdsDefaulted -bool false
  defaults -currentHost write com.apple.coreservices.useractivityd ActivityAdvertisingAllowed -bool false
  defaults -currentHost write com.apple.coreservices.useractivityd ActivityReceivingAllowed -bool false
}

configure_safari() {
  defaults write com.apple.Safari SearchProviderShortName -string DuckDuckGo
  defaults write NSGlobalDomain NSPreferredWebServices '{
      NSWebServicesProviderWebSearch =         {
          NSDefaultDisplayName = DuckDuckGo;
          NSProviderIdentifier = "com.duckduckgo";
      };
  }'
  defaults write com.apple.Safari SearchProviderIdentifierMigratedToSystemPreference -bool true
  defaults write com.apple.Safari AutoFillPasswords -bool false
  defaults write com.apple.Safari PMHidePasswordsSettingsInSafari -bool true
}

configure_admin_settings() {
  if is_admin; then
    sudo defaults write /Library/Preferences/com.apple.locationmenu.plist ShowSystemServices -bool true
    sudo nvram StartupMute=%01
  fi
}

restart_affected_services() {
  killall Finder Dock
}

main() {
  close_system_preferences
  configure_desktop_view
  configure_finder
  configure_dock
  configure_control_center
  configure_global_preferences
  configure_trackpad
  configure_privacy
  configure_safari
  configure_admin_settings
  restart_affected_services
}

main "$@"
