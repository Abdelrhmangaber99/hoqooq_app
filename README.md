# Hoqooq Legal Practice Management - Project Summary

## Cached Court selection

Case forms load Governorates and Case Types from the Hoqooq backend, then query
OpenStreetMap Nominatim resolves the selected Governorate boundary, then the
Overpass API loads all mapped courthouse/judiciary objects inside it. Results
are cached on-device for 30 days and stale cached data remains available when
the public services are unavailable. The two Courts verified in the backend
seed are bundled as first-run fallbacks. Court selection does not require an
API key or billing and does not permit free-form Court entry.

A Case request persists only the selected Court display name as `courtName`;
OpenStreetMap identifiers, coordinates, and addresses remain temporary Flutter
display/cache data. Hearings continue to use the backend Court/Circuit reference
hierarchy. OpenStreetMap attribution must remain visible in the Court picker.

This document provides a technical overview of the work completed for the Hoqooq (Lexora) mobile application UI.

## 🚀 Overview

The goal was to build a production-grade Flutter UI based on Figma screenshots and a Business Requirements Document (BRD). The application follows a professional legal workspace aesthetic (Lexora), utilizing a dark theme with gold accents and high-fidelity components.

## 🏗️ Technical Architecture

The project is built using a **Clean Architecture** approach to ensure scalability and maintainability.

- **Presentation Layer**: Built using the **MVVM** pattern with **flutter_bloc** for state management.
- **Dependency Injection**: Powered by **GetIt** and **Injectable** for automated service registration.
- **Routing**: Implemented with **GoRouter**, supporting deep linking and persistent bottom navigation via `ShellRoute`.
- **Networking**: Foundation laid with **Dio**, including interceptors for authentication and error handling.
- **Models**: Built using **Freezed** and **JSON Serializer** for immutable, type-safe data structures.

## 🎨 Design System

A centralized design system was extracted to ensure pixel-perfect consistency:

- **Colors**: Primary Gold (`#D4AF37`), Deep Background (`#12110F`), and Surface variants.
- **Typography**: Dual-font system using `Playfair Display` for serif headers and `Inter` for body text.
- **Components**: Reusable `AppButton`, `AppTextField`, `AppCard`, and `StatusBadge` widgets.

## 📱 Implemented Features

### 1. Authentication
- **Splash Screen**: Animated progress and branding.
- **Login**: Email/Password authentication UI with social login options.
- **Sign Up**: Multi-field registration with password requirement tracking.

### 2. Management Workspace
- **Dashboard**: A summary-driven home screen with schedules, tasks, and recent clients.
- **Calendar**: Custom grid-based monthly view with event indicators and daily schedule lists.
- **Clients**: Searchable and filterable client list with status-coded badges.
- **Client Profile**: Holistic view of client contact info, cases, and appointments.
- **Case Details**: Interactive timeline view with case-specific statistics.

### 3. Utility & Settings
- **Notifications**: Categorized alert center for hearings and deadlines.
- **Profile Settings**: Working hours management, granular notification toggles, and security (Biometric/2FA) UI.
- **Localization**: Full support for **Arabic (RTL)** and **English** through localized JSON assets.

## 📂 Project Structure

```text
lib/
├── core/           # Shared utilities, theme, and router
├── di/             # Dependency injection configuration
├── features/       # Feature-first modules (Auth, Dashboard, etc.)
│   └── [feature]/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── shared/         # Common widgets and layouts
```

## ✅ Quality Assurance

- **Linting**: Verified with `dart analyze`.
- **Clean Code**: Adherence to SOLID, DRY, and KISS principles.
- **Responsiveness**: Layouts designed to handle various screen sizes without overflow.

---
*Developed as a production-ready UI foundation for the Hoqooq Legal Platform.*
