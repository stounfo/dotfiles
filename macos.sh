### Formats ###
defaults write NSGlobalDomain AppleLanguages -array "en_US"
defaults write -g AppleTemperatureUnit -string Celsius
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"

### Dock ###
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock show-recents -bool false

defaults write com.apple.dock tilesize -int 128
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock largesize -int 70

### Menu Bar ###
# turn off Siri icon
defaults write com.apple.Siri StatusMenuVisible -bool false


### Finder ###
defaults write com.apple.finder ShowPathbar -bool true


### Keyboard ###
defaults write -g KeyRepeat -int 2

# enable Tab in modal dialogs
# defaults write NSGlobalDomain AppleKeyboardUIMode -int 3


### Screen ###
# set display sleep on adapter
sudo pmset -c displaysleep 60
# set display sleep on battery
sudo pmset -b displaysleep 30
# ask for password immediately after sleep
sysadminctl -screenLock immediate -password -
# turn off screen saver
defaults -currentHost write com.apple.screensaver idleTime 0


### Battery ###
# dim display on battery
# sudo pmset -b lessbright 0
# prevent computer from sleeping on adapter
sudo pmset -c sleep 0
