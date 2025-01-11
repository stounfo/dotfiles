If you are stounfo or understand what you are doing, run:

```bash
make all
```

## macOS System Reinstallation

1. Save the .ssh directory from the old system
2. Save the .zsh_history file from the old system
3. Save files from the Downloads directory on the old system
4. Start your computer in macOS Recovery
5. Erase the old macOS volume and format it using APFS (Case-sensitive)
6. Install macOS, set the region to USA, and carefully configure all other
   settings
7. Update macOS
8. Run the command: `xcode-select --install`
9. Run `source macos.sh && sudo reboot`
10. Install dotfiles.
11. Log in to all email accounts.
12. Swap Caps Lock with Control and remap Control to Escape.
13. Turn off keyboard brightness.
14. Change Command + Space from Spotlight to Raycast and set Option + Space for
    Spotlight.
15. Add favorite folders to Finder.
16. Change the tab layout to compact in Safari.
17. Set up widgets in the Notification Center (use layout from your iPhone).
18. Run sudo spctl --global-disable to allow apps from anywhere in Security
    preferences.
19. Return the .ssh directory and .zsh_history file to their places.
20. Change the wallpaper.
