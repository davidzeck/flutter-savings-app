# Enterprise Flutter Mobile App

> **Enterprise-grade Flutter mobile application with MVVM architecture**

## Overview

This is a production-ready Flutter mobile application demonstrating enterprise-level architecture, best practices, and scalability. The app implements a clean MVVM (Model-View-ViewModel) pattern with offline-first capabilities.

## Features

- ✅ **MVVM Architecture** - Clear separation of concerns
- ✅ **Offline-First** - Works without internet connection
- ✅ **State Management** - Provider pattern for reactive UI
- ✅ **Dependency Injection** - GetIt for loose coupling
- ✅ **Type-Safe APIs** - Dio for networking
- ✅ **Local Storage** - Hive + Secure Storage
- ✅ **Comprehensive Testing** - Unit, Widget, and Integration tests
- ✅ **Strict Linting** - Enterprise-grade code quality rules

## Architecture

```
┌─────────────────────────────────────────────┐
│                  UI Layer                    │
├─────────────────────────────────────────────┤
│    View (Widgets)   │   ViewModel (Logic)   │
└─────────────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────┐
│                 Data Layer                   │
├─────────────────────────────────────────────┤
│  Repository │  Service  │  (Optional Domain)│
└─────────────────────────────────────────────┘
```

### Layer Responsibilities

| Layer | Purpose |
|-------|---------|
| **View** | UI rendering, user interactions, animations |
| **ViewModel** | UI logic, state management, business logic |
| **Repository** | Data management, caching, business rules |
| **Service** | External data access (API, storage) |
| **Domain** *(optional)* | Complex business logic, use cases |

## Project Structure

```
lib/
├── core/                           # Shared utilities and configurations
│   ├── constants/
│   │   ├── api_constants.dart     # API endpoints and config
│   │   ├── app_colors.dart        # Color palette
│   │   ├── app_typography.dart    # Text styles
│   │   ├── app_dimensions.dart    # Spacing and sizing
│   │   └── app_strings.dart       # String constants
│   ├── di/                        # Dependency injection
│   ├── exceptions/                # Custom exceptions
│   ├── theme/                     # App theming
│   ├── utils/                     # Utilities
│   └── widgets/                   # Shared widgets
│
├── data/                          # Data layer
│   ├── models/                    # Data models
│   ├── repositories/              # Repository implementations
│   └── services/                  # External data sources
│       ├── api/                   # API service
│       ├── storage/               # Local storage service
│       └── platform/              # Platform-specific services
│
├── domain/                        # Domain layer (optional)
│   ├── entities/                  # Domain entities
│   └── use_cases/                 # Business logic use-cases
│
└── features/                      # Feature modules
    ├── auth/
    │   ├── login/
    │   │   ├── login_view.dart
    │   │   ├── login_viewmodel.dart
    │   │   └── widgets/
    │   └── register/
    ├── dashboard/
    │   ├── dashboard_view.dart
    │   ├── dashboard_viewmodel.dart
    │   └── widgets/
    └── profile/
```

## Getting Started

### Prerequisites

- Flutter SDK (3.7.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / Xcode (for mobile development)
- VS Code or Android Studio (recommended IDEs)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd enterprise_flutter_mobile_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run code generation** (if needed)
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Environment Configuration

Create a `.env` file in the root directory (never commit this):

```env
API_BASE_URL=https://api.example.com
API_KEY=your_api_key_here
```

## Development

### Code Generation

For JSON serialization, Hive adapters, and other generated code:

```bash
# Watch mode (auto-regenerates on changes)
flutter pub run build_runner watch

# One-time generation
flutter pub run build_runner build --delete-conflicting-outputs
```

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/auth/login_viewmodel_test.dart
```

### Code Quality

```bash
# Analyze code
flutter analyze

# Format code
flutter format lib/

# Check for outdated dependencies
flutter pub outdated
```

## Design System

### Colors

The app uses a comprehensive color palette defined in [app_colors.dart](lib/core/constants/app_colors.dart):

- **Primary**: Blue 700 (#1976D2)
- **Accent**: Orange 900 (#FF6F00)
- **Semantic**: Success (Green), Warning (Orange), Error (Red), Info (Blue)
- **Neutral**: Background, Surface, Text, Borders

### Typography

Font system based on 1.25 scale ratio (Major Third):

- **Headings**: h1 (32sp) → h6 (16sp)
- **Body**: Large (16sp), Medium (14sp), Small (12sp)
- **Labels**: Large (14sp), Medium (12sp), Small (11sp)

### Spacing

8-point grid system:

- xs: 4dp, sm: 8dp, md: 16dp, lg: 24dp, xl: 32dp, xxl: 48dp, xxxl: 64dp

## State Management

This project uses **Provider** for state management:

```dart
// Accessing ViewModel in View
final viewModel = context.watch<LoginViewModel>();

// Calling commands
onPressed: () => viewModel.login()

// Reading specific properties
final isLoading = context.select((LoginViewModel vm) => vm.isLoading);
```

## Dependency Injection

Dependencies are managed with **GetIt**:

```dart
// Register dependencies
getIt.registerLazySingleton<ApiService>(() => ApiService());
getIt.registerFactory<LoginViewModel>(() => LoginViewModel(getIt()));

// Access dependencies
final apiService = getIt<ApiService>();
```

## Best Practices

### DO's

✅ Keep ViewModels focused on UI logic
✅ Use repositories for data management
✅ Extract reusable widgets
✅ Write tests for business logic
✅ Use const constructors
✅ Follow naming conventions
✅ Document complex logic

### DON'Ts

❌ Put business logic in Views
❌ Access services directly from ViewModels
❌ Hardcode strings or colors
❌ Ignore linting warnings
❌ Commit secrets or API keys
❌ Skip error handling

## Testing Strategy

```
      ╱╲
     ╱  ╲    ← Few Integration Tests
    ╱────╲
   ╱      ╲  ← Some Widget Tests
  ╱────────╲
 ╱          ╲ ← Many Unit Tests
╱────────────╲
```

- **Unit Tests**: ViewModels, Repositories, Use Cases (>80% coverage)
- **Widget Tests**: Critical UI components and flows
- **Integration Tests**: End-to-end user journeys

## Documentation

- 📖 [Architecture Guide](../ARCHITECTURE_GUIDE.md) - Detailed architecture explanation
- 📋 [Implementation Guide](../IMPLEMENTATION_GUIDE.md) - Phase-by-phase implementation plan
- 📄 [PRD](../enterprise_flutter_mobile_app_prd.md) - Product requirements document

## Contributing

1. Create a feature branch (`git checkout -b feature/amazing-feature`)
2. Commit your changes (`git commit -m 'Add amazing feature'`)
3. Push to the branch (`git push origin feature/amazing-feature`)
4. Open a Pull Request

### Commit Message Convention

```
type(scope): subject

body

footer
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

## License

This project is private and proprietary.

## Contact

For questions or support, please contact the development team.

---

**Built with ❤️ using Flutter**
