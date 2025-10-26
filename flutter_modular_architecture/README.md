# Flutter Modular Architecture

A comprehensive Flutter brick that generates a complete modular architecture with best practices, state management, and platform selection support.

## Features 🎯

- 🏗️ **Modular Architecture**: Clean, scalable project structure with separate modules
- 📦 **Multi-Module Support**: Common, Core, Gen, and Widgets modules
- 🎨 **State Management**: Built-in support with Cubit/Provider pattern
- 🌍 **Internationalization**: Pre-configured l10n support with ARB files
- 🚀 **Dependency Injection**: Service container pattern
- 🔄 **Network Layer**: Ready-to-use network service structure
- 💾 **Cache Management**: Built-in cache service
- 🎭 **Environment Configuration**: Development and production environment files
- 🛣️ **Navigation**: Router configuration ready
- 🧪 **Testing**: Widget test setup included
- 📱 **Platform Selection**: Choose your target platforms (Android, iOS, Web, macOS, Windows, Linux)

## Usage 🚀

### Prerequisites

Make sure you have Mason CLI installed:

```bash
dart pub global activate mason_cli
```

### Installation

```bash
mason add flutter_modular_architecture
```

### Generate Project

```bash
mason make flutter_modular_architecture
```

You'll be prompted for:
- **Project name**: Your project name (will be converted to snake_case)
- **Description**: Project description
- **Organization domain**: Your organization domain (e.g., com.example)
- **Platforms**: Target platforms (android, ios, web, macos, windows, linux)

### Example

```bash
mason make flutter_modular_architecture --project_name "my_awesome_app" --description "My awesome Flutter app" --organization_name "com.mycompany" --platforms android,ios,web
```

## Project Structure 📁

```
your_project/
├── lib/
│   ├── main.dart
│   ├── feature/
│   │   └── counter/
│   │       ├── view/
│   │       └── view_model/
│   ├── l10n/
│   │   └── arb/
│   ├── product/
│   │   ├── cache/
│   │   ├── init/
│   │   ├── navigation/
│   │   ├── service/
│   │   ├── state/
│   │   ├── utility/
│   │   └── widgets/
├── module/
│   ├── common/
│   ├── core/
│   ├── gen/
│   └── widgets/
├── assets/
│   ├── env/
│   ├── icons/
│   ├── images/
│   └── lottie/
├── script/
│   ├── build.sh
│   ├── clear.sh
│   ├── icon.sh
│   ├── lang.sh
│   └── pub.sh
└── test/
```

## Included Modules 📦

### Common Module
Core utilities, network services, connectivity checks, and shared functionality.

### Core Module
Database, cache management, and core business logic.

### Gen Module
Auto-generated code and assets.

### Widgets Module
Reusable UI components and custom widgets.

## Scripts 🔧

The brick includes useful scripts:
- `build.sh`: Build runner script
- `clear.sh`: Clean build artifacts
- `icon.sh`: Generate app icons
- `lang.sh`: Generate localization files
- `pub.sh`: Run pub get for all modules

## Getting Started with Generated Project 🎬

After generation:

1. Navigate to your project directory
2. Run `sh script/pub.sh` to install all dependencies
3. Run `sh script/lang.sh` to generate localization files
4. Start coding! 🚀

## Requirements ⚙️

- Flutter SDK: ^3.0.0
- Dart SDK: ^3.0.0
- Mason CLI: ^0.1.1

## License 📄

MIT License

## Contributing 🤝

Contributions are welcome! Please feel free to submit a Pull Request.

## Support ❤️

If you find this brick helpful, please give it a ⭐ on [GitHub](https://github.com/ahmtydn/mason_flutter_bricks)!
