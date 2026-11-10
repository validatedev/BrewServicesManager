# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Settings is now a native grouped form with descriptions under each option, split into Services, Launch, Updates, Advanced, and About sections, and a wider panel (#6)
- More space around the Quit row at the bottom of the menu (#6)
- Quieter colors: the header accent bar is solid amber, status icons no longer glow, the status pill has a neutral background, and action icons in the More Actions menu are grey except Kill
- Section labels in the menu use sentence case instead of uppercase
- The status of an unloaded service reads "Not Loaded" everywhere
- Empty and error states use the standard macOS "unavailable" layout
- Panels fade instead of sliding when Reduce Motion is on
- VoiceOver reads service status icons and header status
- README instructions match the current menu and Settings

### Fixed

- Section cards on macOS 26 no longer render as clipped pill shapes (#6)
- Link URLs pasted with surrounding spaces are accepted instead of rejected
- Unit tests build again after the app rename
- Homebrew cask uses `depends_on macos: :sequoia`, which removes the `brew doctor` deprecation warning (#7)

## [1.1.8] - 2026-02-10

### Fixed

- Service commands now work without an internet connection by preventing Homebrew from fetching remote API data

## [1.1.7] - 2026-01-08

### Added

- Scrollable services list with automatic scrollbar when many services are installed

### Fixed

- Port detection in service popover now shows "Detecting…" immediately instead of blank space, preventing layout shift

## [1.1.6] - 2026-01-08

### Changed

- Service Info panel now opens instantly with a loading state instead of blocking on data fetch
- Removed pulsing animation from status indicators for improved performance

## [1.1.5] - 2026-01-07

### Changed

- Renamed app from "BrewServicesManager" to "Brew Services Manager"

## [1.1.4] - 2026-01-07

### Added

- Launch at Login option in Settings

## [1.1.3] - 2026-01-04

### Added

- Gentle update reminders with menu bar icon badge instead of intrusive modal alerts


### Changed

- Extended macOS support to all Sequoia versions

## [1.1.2] - 2026-01-01

### Changed

- Release script updates and stages the Homebrew cask before tagging releases
- Homebrew cask automation now uses the Casks directory as the single source of truth

### Removed

- Duplicate root-level Homebrew cask file

## [1.1.1] - 2026-01-01

### Added

- App version and build number display in Settings
- Homebrew installation option in the README
- Homebrew cask update and PR helpers in the release script

## [1.1.0] - 2026-01-01

### Added

- Automatic update support via Sparkle framework
- Port detection for running services using `lsof`
- User-configurable service links with custom URLs
- Auto-suggest URLs based on detected listening ports
- Inline link buttons in service rows

### Changed

- Refactored menu bar views and navigation
- Improved concurrency with hardened actor isolation and off-main-actor loading
- Switched to LazyVStack in menu views

### Fixed

- System authentication dialog now properly receives mouse input in MenuBarExtra context
- Privilege escalation uses NSAppleScript API on MainActor for reliable dialog interaction
- Data race in ServiceLinksStore with serialized disk writes
- Child process detection using pgrep instead of ps -g
- Port numbers display without thousands separators
- Port detection triggers when actions popover opens

## [1.0.0] - 2024-12-25

### Added

- Initial release
- Menu bar interface for managing Homebrew services
- Support for user and system service domains
- Service status monitoring with auto-refresh
- Start, stop, and restart service actions
- Detailed service information view
- Debug mode for verbose Homebrew output

[unreleased]: https://github.com/validatedev/BrewServicesManager/compare/v1.1.8...HEAD
[1.1.8]: https://github.com/validatedev/BrewServicesManager/compare/v1.1.7...v1.1.8
[1.1.7]: https://github.com/validatedev/BrewServicesManager/compare/v1.1.6...v1.1.7
[1.1.6]: https://github.com/validatedev/BrewServicesManager/compare/v1.1.5...v1.1.6
[1.1.5]: https://github.com/validatedev/BrewServicesManager/compare/v1.1.4...v1.1.5
[1.1.4]: https://github.com/validatedev/BrewServicesManager/compare/v1.1.3...v1.1.4
[1.1.3]: https://github.com/validatedev/BrewServicesManager/compare/v1.1.2...v1.1.3
[1.1.2]: https://github.com/validatedev/BrewServicesManager/compare/v1.1.1...v1.1.2
[1.1.1]: https://github.com/validatedev/BrewServicesManager/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/validatedev/BrewServicesManager/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/validatedev/BrewServicesManager/releases/tag/v1.0.0
