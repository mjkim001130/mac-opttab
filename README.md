# mac-opttab

Use `Option+Tab` as the built-in macOS `Cmd+Tab` app switcher.

OptTab only rewrites keyboard events. It never asks other apps about their windows, so it avoids a crash seen when window switchers run alongside PowerPoint's IguanaTex add-in.

## Usage

- Hold `Option` and press `Tab` to open the switcher. Press `Tab` again for the next app, or add `Shift` for the previous one.
- Release `Option` to switch.
- It switches between apps, not individual windows, the same as `Cmd+Tab`.
- Other `Option` shortcuts and special characters work as usual.
- OptTab has no window or Dock icon.

## Install

Requires macOS and the Xcode Command Line Tools (`xcode-select --install`).

```bash
git clone https://github.com/mjkim001130/mac-opttab.git
cd mac-opttab
./install.sh
```

Then:

1. Turn on **OptTab** in System Settings → Privacy & Security → Accessibility.
2. Restart OptTab so it picks up the permission:

   ```bash
   pkill -x OptTab; open ~/Applications/OptTab.app
   ```

3. To start it at login, add `~/Applications/OptTab.app` in System Settings → General → Login Items.

Quit other apps that use `Option+Tab`, such as AltTab, because the shortcuts conflict.

If you reinstall, you may need to turn the Accessibility permission off and on again.

## Uninstall

```bash
pkill -x OptTab
rm -rf ~/Applications/OptTab.app
tccutil reset Accessibility io.github.mjkim001130.opttab
```

Remove it from Login Items if you added it.
