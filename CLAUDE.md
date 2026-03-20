# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Riverbed iOS is a native Swift UIKit app for iOS, iPadOS, and macOS (Catalyst). It's a client for the Riverbed platform — an app for creating interactive CRUD apps with no programming. Licensed under MPL 2.0.

## Build & Run

- Open `Riverbed.xcodeproj` in Xcode and run
- **Linting:** SwiftLint is required (install via Homebrew). It runs as an Xcode build phase
- **Tests:** Run the `RiverbedTests` target in Xcode, or `xcodebuild test -project Riverbed.xcodeproj -scheme Riverbed -testPlan Riverbed -destination 'platform=iOS Simulator,name=iPhone 17'`
- UI tests (`RiverbedUITests`) are disabled in the test plan

## Architecture

### UI Layer (UIKit, Storyboard-based)
- Uses `UISplitViewController` as root (`RiverbedSplitViewController`) with primary/secondary navigation
- Primary: `BoardListCollectionViewController` — shows list of boards
- Secondary: `BoardViewController` — displays a selected board's cards in columns
- Cards open in `CardViewController`, which displays elements (fields/buttons) using specialized `ElementCell` subclasses
- Editing screens (boards, columns, elements, conditions) are presented modally via navigation controllers
- macOS support via Catalyst with custom menu bar commands defined in `AppDelegate`
- Storyboards in `Base.lproj/` (Main.storyboard, LaunchScreen.storyboard)

### Data Layer
- `BaseStore` — base class for API stores; handles URLSession requests and JSON:API response parsing
- Protocol-based store pattern: protocols (`BoardStore`, etc.) with API implementations (`ApiBoardStore`, etc.) and mock doubles for testing
- `SessionSource` protocol provides auth tokens; `DeviceStorageSessionSource` reads from Keychain + UserDefaults
- API URLs centralized in `RiverbedAPI` struct (currently pointing to `beta.api.riverbed.app`)
- Models use JSON:API envelope (`JSONAPI.Data<T>`) with hyphenated `CodingKeys` (e.g., `color-theme`, `icon-extended`)
- Dependencies are injected in `SceneDelegate.scene(_:willConnectTo:options:)`

### Share Extension (`RiverbedShare`)
- iOS share extension for sharing URLs/content to Riverbed boards via webhooks

### Key Domain Models
- **Board** — has columns, elements, cards, and options (webhooks, share config)
- **Card** — belongs to a board, has field values keyed by element ID
- **Column** — defines display columns on a board, with sort/filter conditions
- **Element** — defines a field type (text, date, choice, geolocation, button, button menu) on a board

## Testing

Tests use `XCTest` with mock store doubles in `RiverbedTests/Doubles/`. View controller tests use `ViewControllerPresentationSpy.xcframework` for verifying modal presentations. Test structure mirrors the main target's `Data/` and `UI/` organization.

## SwiftLint Configuration

Disabled rules: `closure_parameter_position`, `cyclomatic_complexity`, `file_length`, `function_body_length`, `todo`, `type_body_length`. Nesting type level is 2 (for JSON:API model types with nested CodingKeys).
