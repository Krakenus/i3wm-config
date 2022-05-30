# i3WM Config

My configuration for i3 window manager - in progress.

This configuration is optimized for usage on latest version of [Linux Mint Cinnamon Edition](https://www.linuxmint.com/download.php).

It use the latest stable version of i3 from it's [Ubuntu apt repository](https://i3wm.org/docs/repositories.html) (4.20 at the time).


## Dependencies

`brightnessctl`
- used for brightness control.
- xbacklight doesn't work for me
- requires user to be in the `video` group

`nitrogen`
- used for background 

`numlockx`
- to make sure numblock is on after login
- to make sure numblock is on after login 

`xss-lock`

`flameshot`
- For screenshots and lock screen

`imagemagick`
- lock screen

## Gnome Keyring

Switching between Cinnamon and i3 overwrites sessions in Chromium based web browsers as well as in Electron desktop apps.

In i3 it is required to add `--password-store=gnome` options to .desktop files of these apps to share one storage between Cinnamon and i3 sessions.

There is a script in `scripts/enforce_gnome_keyring.py` that modifies the .desktop files of given apps. It requires operational `locate` command in the system.

### usage

Make sure the `locate` is setup and execute the script with names of the applications.

So far tested with `brave-browser` and `slack`.

```
# apt install locate
# updatedb
# scripts/enforce_gnome_keyring.py brave-browser slack
```
