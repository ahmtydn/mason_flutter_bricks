# 0.1.0+9

- **Feat:** Added `device_preview` support

# 0.1.0+8

- **Feat:** Added `app_name` support for all platforms (Android, iOS, Web, macOS, Windows, Linux)

# 0.1.0+7

- **Fix:** Improvements have been made

# 0.1.0+6

- **Fix:** Improvements have been made

# 0.1.0+5

- **Fix:** Improvements have been made

# 0.1.0+4

- **Fix:** Update `isar_plus` dependency version in `module_core` and remove from `module_gen`

# 0.1.0+3

- **Refactor:** Refactored localization structure — removed old files and added `AppLocalizationService`. 
- **Fix:** Updated localization references and paths.
- **Refactor:** Removed asset synchronization logic from module generation.
- **Chore:** Removed unused environment files and updated `pubspec.yaml` for asset management.
- **Fix:** Resolved lint errors and sorted dependencies.

# 0.1.0+2

- Fixed platforms parameter handling in post_gen hook
- Added support for comma-separated platforms in CLI mode (e.g., `--platforms android,ios,web`)
- Improved compatibility between interactive and CLI modes

# 0.1.0+1

- Initial release
- Complete modular Flutter architecture
- Multi-module support (Common, Core, Gen, Widgets)
- State management with Cubit pattern
- Internationalization support
- Network layer and cache management
- Environment configuration (dev/prod)
- Platform selection support
- Pre-configured scripts for common tasks
- Example counter feature implementation
