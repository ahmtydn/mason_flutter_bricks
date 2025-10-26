# 🧱 Mason Flutter Bricks

A collection of production-ready Mason bricks for Flutter development. These bricks help you generate scalable, maintainable Flutter projects with best practices built-in.

[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## 📦 Available Bricks

### 🏗️ Flutter Modular Architecture

A comprehensive Flutter brick that generates a complete modular architecture with best practices, state management, and platform selection support.

**Features:**
- 🏗️ Modular Architecture with clean separation
- 📦 Multi-Module Support (Common, Core, Gen, Widgets)
- 🎨 State Management with Cubit pattern
- 🌍 Internationalization (l10n) support
- 🚀 Dependency Injection with service container
- 🔄 Network Layer ready
- 💾 Cache Management
- 🎭 Environment Configuration (dev/prod)
- 🛣️ Navigation setup
- 🧪 Testing configuration
- 📱 Platform Selection (Android, iOS, Web, macOS, Windows, Linux)

**Installation:**
```bash
mason add flutter_modular_architecture
```

**Usage:**
```bash
mason make flutter_modular_architecture
```

📖 [View Full Documentation](./flutter_modular_architecture/README.md) | 🔗 [BrickHub Page](https://brickhub.dev/bricks/flutter_modular_architecture)

## 🚀 Getting Started

### Prerequisites

Make sure you have Mason CLI installed:

```bash
dart pub global activate mason_cli
```

### Quick Start

1. **Install Mason globally:**
   ```bash
   dart pub global activate mason_cli
   ```

2. **Add a brick:**
   ```bash
   mason add flutter_modular_architecture
   ```

3. **Generate code:**
   ```bash
   mason make flutter_modular_architecture
   ```

## ️ Development

### Local Development

To use these bricks locally during development:

```bash
# Clone the repository
git clone https://github.com/ahmtydn/mason_flutter_bricks.git
cd mason_flutter_bricks

# Initialize Mason
mason get

# Make changes to bricks...

# Test your brick
mason make flutter_modular_architecture --project_name test_app
```

### Project Structure

```
mason_flutter_bricks/
├── flutter_modular_architecture/     # Modular architecture brick
│   ├── __brick__/                    # Brick template files
│   ├── hooks/                        # Post-generation hooks
│   ├── brick.yaml                    # Brick configuration
│   ├── README.md                     # Brick documentation
│   ├── CHANGELOG.md                  # Version history
│   └── LICENSE                       # Brick license
└── mason.yaml                        # Mason configuration
```

> 📖 For detailed documentation about the Flutter Modular Architecture brick, see [flutter_modular_architecture/README.md](./flutter_modular_architecture/README.md)

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Make your changes**
4. **Test thoroughly**
5. **Commit your changes**
   ```bash
   git commit -m 'Add some amazing feature'
   ```
6. **Push to the branch**
   ```bash
   git push origin feature/amazing-feature
   ```
7. **Open a Pull Request**

### Adding a New Brick

To add a new brick to this collection:

1. Create a new directory for your brick
2. Run `mason new <brick_name>` inside that directory
3. Develop your brick following Mason best practices
4. Add comprehensive documentation (README, CHANGELOG, LICENSE)
5. Update this main README to include your brick
6. Test thoroughly
7. Submit a pull request

## 📋 Requirements

- **Dart SDK:** >=3.0.0
- **Mason CLI:** >=0.1.0-dev.50
- **Flutter:** >=3.0.0 (for Flutter bricks)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](./flutter_modular_architecture/LICENSE) file for details.

## 💖 Support

If you find these bricks helpful:

- ⭐ Star this repository
- 🐛 Report bugs
- 💡 Suggest new features
- 🤝 Contribute to the project

## 🔗 Links

- [Mason CLI](https://github.com/felangel/mason)
- [BrickHub](https://brickhub.dev)
- [Flutter](https://flutter.dev)
- [Dart](https://dart.dev)

## 👨‍💻 Author

**Ahmet Aydın**

- GitHub: [@ahmtydn](https://github.com/ahmtydn)
- Email: ahmttyydn@gmail.com

## 🙏 Acknowledgments

- Thanks to [Felix Angelov](https://github.com/felangel) for creating Mason
- Thanks to the Flutter community for inspiration and support

---

<p align="center">Made with ❤️ for the Flutter community</p>
