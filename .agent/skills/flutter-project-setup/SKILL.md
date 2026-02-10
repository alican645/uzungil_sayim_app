---
name: flutter-project-setup
description: Sets up a scalable Flutter project structure with Clean Architecture and essential packages.
---

# Flutter Project Setup Skill

This skill guides you through setting up a structured Flutter project, ensuring best practices and scalability.

## Project Structure Overview

The project follows a Clean Architecture approach:

- **lib/core**: Contains core business logic and domain models.
  - **application**: Application logic (e.g., BLoCs, Cubits).
  - **domain**: Enterprise business rules (Entities, Use Cases, Repository Interfaces).
- **lib/infrastructure**: Implementations of interfaces defined in domain (Repositories, Data Sources, API Clients).
- **lib/presentation**: UI components and state management integration.
  - **Views**: Screen widgets and pages.
  - **navigation**: Routing configuration (e.g., GoRouter).

## Package Installation

The following packages are essential for this architecture and should be added to `pubspec.yaml`:

### State Management & DI
- `flutter_bloc`: For state management.
- `get_it`: For dependency injection.
- `equatable`: For value equality.
- `dartz`: For functional programming utilities (Either type).

### Networking
- `dio`: For HTTP requests.

### Navigation
- `go_router`: For declarative routing.

### UI Components
- `cupertino_icons`: iOS style icons.
- `syncfusion_flutter_charts`: For data visualization (if needed).

### Code Quality (Dev Dependencies)
- `bloc_lint`: Lint rules for BLoC.
- `very_good_analysis`: Strict lint rules.
- `flutter_test`: For unit and widget testing.

## Setup Instructions

1.  **Create Directories**:
    Manually create the following folder structure inside `lib/`:
    ```
    lib/
    ├── core/
    │   ├── application/
    │   └── domain/
    ├── infrastructure/
    │   ├── infrastructure/
    │   └── persistence/
    └── presentation/
        ├── Views/
        └── navigation/
    ```

2.  **Add Dependencies**:
    Run the following command to add dependencies:
    ```bash
    flutter pub add flutter_bloc get_it equatable dartz dio go_router cupertino_icons syncfusion_flutter_charts
    ```

3.  **Add Dev Dependencies**:
    Run the following command to add dev dependencies:
    ```bash
    flutter pub add --dev bloc_lint very_good_analysis
    ```

4.  **Verify Setup**:
    Ensure `pubspec.yaml` is updated and run `flutter pub get` to install packages.
