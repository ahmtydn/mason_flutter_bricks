# {{project_name.pascalCase()}}

{{{description}}}

## 🚀 Getting Started

This project uses a modular architecture with the following structure:

### 📁 Project Structure

```
{{project_name.snakeCase()}}/
├── lib/
│   ├── feature/          # Feature modules
│   ├── product/          # Product-level code (DI, Navigation, State)
│   └── main.dart         # App entry point
├── module/
│   ├── gen/              # Generated code (assets, env, models)
│   ├── core/             # Core utilities (storage, cache)
│   ├── common/           # Common utilities (network, extensions)
│   ├── widgets/          # Reusable widgets
{{#include_feedback_module}}
│   └── feedback/         # Feedback module
{{/include_feedback_module}}
├── script/               # Build scripts
└── assets/               # Static assets
```

### 🎯 Platforms

This project supports the following platforms:
{{#platforms}}
- {{.}}
{{/platforms}}

## 🛠️ Development Setup

### Prerequisites

- Flutter SDK (>=3.35.0)
- Dart SDK (>=3.9.0)

### Installation

1. Install dependencies:
```bash
./script/pub.sh
```

2. Generate code:
```bash
./script/build.sh build
```

3. Run the app:
```bash
flutter run
```

### 📜 Available Scripts

- `./script/pub.sh` - Install dependencies for all modules
- `./script/build.sh build` - Generate code for all modules
- `./script/build.sh force` - Clean and rebuild all modules
- `./script/build.sh watch` - Watch mode for code generation
- `./script/lang.sh` - Generate localization files
- `./script/icon.sh` - Generate app icons

## 🏗️ Architecture

This project follows a modular architecture with:

- **State Management**: flutter_bloc + equatable
- **Dependency Injection**: get_it
- **Navigation**: auto_route
- **Network**: dio + connectivity_plus
- **Storage**: Local modules (core, gen)
- **Localization**: Flutter l10n

### 🔄 Code Generation

This project uses build_runner for code generation. Run the build script after:

- Adding new models
- Updating routes
- Modifying environment variables
- Adding new assets

## 📝 License

Copyright (c) {{organization_name}}

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!
