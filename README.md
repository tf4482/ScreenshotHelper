# ScreenshotHelper

Takes a clean screenshot in WoW Forever: hides the UI, all unit names, and nameplates,
captures the screen, and restores everything right after.

## Features

- **Clean screenshot** - one command or key hides UI, names, and nameplates, takes the
  screenshot, and restores the previous state.
- **Key binding** - assign a key under Options > Keybindings > AddOns.
- **Names option** - optionally keep names and nameplates in the screenshot.
- **Remembered** - settings are saved per account, or per character with one checkbox;
  default is off.
- **Settings page** - all options in the game menu under Options > AddOns, also opened
  from the addon compartment menu.
- **Chat commands** - every option can also be changed by slash command.

Not available in combat (the game blocks changing nameplate settings there).

## Install

1. Download `ScreenshotHelper-vX.Y.Z.zip` from the
   [releases](https://github.com/tf4482/ScreenshotHelper/releases).
2. Unzip it into `World of Warcraft/<client folder>/Interface/AddOns/`.
3. Restart the game or type `/reload`.

## Usage

```text
/ssh                  take a clean screenshot
/ssh status           show the current settings
/ssh names on         keep names and nameplates in the screenshot
/ssh names off        hide names and nameplates (default)
/ssh character on     use settings for this character only
/ssh character off    use the account settings again
/ssh config           open the settings page
/ssh help             list all commands
```

## Examples

- Scenery shot: stand still, type `/ssh`; the image lands in `Screenshots/`.
- One key: bind "Take clean screenshot" under Options > Keybindings > AddOns, e.g. to
  `Shift-Print`.
- Group photo with names: `/ssh names on`, then `/ssh`.
- Macro: a macro with the line `/ssh` works on an action bar button.

## Develop

Check the code with [Luacheck](https://github.com/lunarmodules/luacheck) before each commit
(CI runs it on every push):

```text
luacheck .
```

Release: push an annotated tag `vX.Y.Z`; GitHub Actions packages the addon with the
BigWigs packager and publishes it.

## License

All rights reserved, see [LICENSE](LICENSE).
