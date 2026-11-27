# Changelog

All notable changes to this project are documented in this file.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and
[Semantic Versioning](https://semver.org/).

## [Unreleased]

### Changed

- Shared settings component updated; no visible change

## [0.2.0] - 2026-11-24

### Added

- `/ssh reset` restores the default settings; `/ssh debug on|off` shows each changed
  name setting in chat until `/reload`.
- German texts for the settings page checkbox and chat command help.

### Changed

- Only WoW Forever (interface 16001) listed in the TOC.
- Key binding moved from the shared AddOns section to its own ScreenshotHelper section in
  Options > Keybindings; an existing key assignment stays.

### Fixed

- Friendly NPC nameplates no longer stay off after step 3; the CVar was saved twice.
- Names and nameplates left hidden by a reload in combat are restored after combat.

## [0.1.0] - 2026-11-24

### Added

- Screenshot mode in three steps via `/ssh` or key binding: hide UI, names, and
  nameplates; show player names; restore the original state.
- Names and nameplates restored on login after a reload during the steps.
- Key binding row on the settings page, shared with Options > Keybindings.
- Settings page and per-character settings.
- German texts on German clients, English everywhere else.
- Option to hide the own name in step 2 (`/ssh hideown on|off`).
