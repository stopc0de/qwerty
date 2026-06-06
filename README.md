<div align="center">
  <img src="icons.icon/" width="120" alt="Uninstaller Icon" />
  <h1 align="center">Uninstaller</h1>
  <p align="center">A macOS app uninstaller built with SwiftUI — clean, safe, and effortless.</p>
</div>

<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS%2013+-blue?logo=apple&logoColor=white" alt="Platform" />
  <img src="https://img.shields.io/badge/Swift-5.9-orange?logo=swift" alt="Swift" />
  <img src="https://img.shields.io/badge/license-MIT-green" alt="License" />
</p>

---

## Overview

**Uninstaller** is a native macOS application that helps you completely remove unwanted applications and their associated files. Unlike simply dragging an app to Trash, Uninstaller also finds and cleans up scattered leftovers — preferences, caches, application support data, logs, and more — so nothing is left behind.

## Features

- **Comprehensive App Scanning** — Scans `/Applications`, `~/Applications`, system utilities, and user directories to build a complete list.
- **Smart Categorization** — Apps are grouped into *Applications*, *Utilities*, *User-installed*, and *System* for easy browsing.
- **Search & Filter** — Quickly find apps by name with real-time filtering.
- **Detailed App Info** — View app icon, version, size, bundle identifier, and installation path.
- **Deep Cleanup** — Scans `~/Library` and `/Library` directories for associated files including:
  - Preferences (`.plist`)
  - Caches
  - Application Support
  - Saved Application State
  - Logs
  - Containers
  - HTTP Storages
  - Group Containers
  - WebKit Databases
- **Safe Uninstall** — Apps are moved to Trash first; associated files are cleaned up after, with real-time progress feedback.
- **System App Protection** — System applications are clearly marked and cannot be uninstalled.
- **Native SwiftUI Interface** — Smooth animations, sidebar navigation, dark mode support, and a modern macOS design.

## Requirements

- macOS 13 (Ventura) or later
- Xcode 15+ (for building from source)

## Installation

### Build from Source

```bash
# Clone the repository
git clone https://github.com/yourusername/uninstaller.git
cd uninstaller/Uninstaller

# Build and generate the app bundle
make app

# Or run directly
make run
```

After building, the `.app` bundle will be at `build/Uninstaller.app`. Drag it to your `Applications` folder, or run it directly.

### Build with Xcode

```bash
make xcode
```

Then open the generated Xcode project and build.

## Usage

1. Launch Uninstaller — it will automatically scan all installed applications.
2. Browse apps by category in the sidebar, or use the search bar.
3. Click an app to view its details and associated files.
4. Click **Uninstall** to remove the app and its associated files.
5. Confirm the action — the app will be moved to Trash and leftovers will be cleaned up.

## Project Structure

```
Uninstaller/
├── Sources/Uninstaller/
│   ├── UninstallerApp.swift        # App entry point & launch screen
│   ├── ContentView.swift           # Main split-view layout
│   ├── Models/
│   │   ├── MacApp.swift            # App data model & categories
│   │   └── AssociatedFile.swift    # Associated file model & categories
│   ├── Services/
│   │   ├── AppScanner.swift        # Scans installed applications
│   │   └── UninstallService.swift  # Handles uninstall & file cleanup
│   ├── ViewModels/
│   │   └── AppListViewModel.swift  # State management for the app list
│   └── Views/
│       ├── SidebarView.swift       # Category sidebar
│       ├── AppListView.swift       # Application list with cards
│       ├── AppDetailView.swift     # Detail panel for selected app
│       ├── WelcomeView.swift       # Empty-state welcome screen
│       ├── UninstallConfirmationView.swift  # Uninstall confirmation dialog
│       └── UninstallProgressView.swift      # Progress & completion view
├── icons.icon/                     # App icon assets
├── gen_icon.swift                  # Icon generator script
├── Info.plist                      # Bundle metadata
├── Makefile                        # Build automation
├── Package.swift                   # SwiftPM manifest
└── LICENSE                         # MIT License
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
