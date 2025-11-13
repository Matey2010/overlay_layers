## 1.0.0

### BREAKING CHANGES

This is a major architectural refactor that uses Flutter's native Overlay system. The package now works immediately without any wrapper widgets.

#### Removed Components
- **`OverlayRoot`**: No longer needed. Remove all `OverlayRoot` wrappers from your app.
- **`OverlayContainer`**: No longer needed. Overlays render through Flutter's native Overlay.
- **`OverlayProvider`**: Removed entirely. Replaced with singleton pattern.

#### API Changes
- **`PopupController.updateData()` → `PopupController.updatePopupData()`**: Method renamed for clarity
- **`PopupDataContext.updateData()` → `PopupDataContext.updatePopupData()`**: Method renamed for clarity
- **`OverlayManager.createOverlay()`**: Now requires `BuildContext` parameter
- **`OverlayManager`**: Now uses singleton pattern with `OverlayManager.instance`
- **`PopupController.of()`**: Now uses singleton automatically, no provider needed
- **`OverlayManager.custom()`**: New constructor for custom manager instances (advanced use)

#### Migration Guide

**Before (v0.2.0):**
```dart
// App setup
OverlayRoot(
  child: MaterialApp(home: MyApp()),
)

// Update popup data
controller.updateData(id, data);
popup.updateData(data);
```

**After (v1.0.0):**
```dart
// App setup - No wrapper needed! Uses singleton automatically
MaterialApp(home: MyApp())

// Update popup data - Renamed methods
controller.updatePopupData(id, data);
popup.updatePopupData(data);

// Access global singleton (advanced)
final overlays = OverlayManager.instance.overlays;

// Or create custom manager (rare)
final customManager = OverlayManager.custom();
PopupController.withManager(context, customManager).open(...);
```

### Features

* **Native Flutter Overlay integration**: Built on `OverlayEntry` API for better performance
* **No setup required**: Works immediately with any Flutter app (MaterialApp, CupertinoApp, etc.)
* **Singleton pattern**: Global `OverlayManager.instance` provides automatic access everywhere
* **Simplified architecture**: Removed custom overlay system and provider pattern, uses Flutter's standard approach
* **Better performance**: Individual entry updates via `markNeedsBuild()` instead of full Stack rebuilds

### Implementation Details

* **OverlayManager** now creates and manages Flutter `OverlayEntry` instances
* Uses `Overlay.of(context, rootOverlay: true)` for predictable overlay placement
* Entries removed via `entry.remove()` with proper lifecycle management
* Data updates trigger `entry.markNeedsBuild()` for efficient rendering
* Controllers store `BuildContext` to access native Overlay

### Documentation

* Updated README.md with new Quick Start guide
* Updated CLAUDE.md with v1.0.0 architecture details
* Added migration guide for v0.2.0 users
* Updated API reference with renamed methods

## 0.2.0

### Features

* **Flexible overlay rendering with `includeContainer` parameter** ([lib/src/core/overlay_manager.dart:158](lib/src/core/overlay_manager.dart#L158))
  - Added `includeContainer` boolean parameter to `OverlayRoot` (defaults to `true`)
  - When `true`: Automatically includes `OverlayContainer` in a Stack for immediate overlay support
  - When `false`: Allows manual placement of `OverlayContainer` for advanced layout control
  - Enables precise control over where overlays render in the widget tree
  - Useful for complex UIs where overlays should only cover specific sections

### Documentation

* **Enhanced architecture documentation** ([lib/src/core/overlay_manager.dart:132-146](lib/src/core/overlay_manager.dart#L132-L146))
  - Added comprehensive doc comments explaining the provider pattern
  - Documented the relationship between `OverlayRoot`, `OverlayProvider`, and `OverlayContainer`
  - Clarified when and how to use `includeContainer` parameter
  - Added examples for both automatic and manual container placement

### Code Quality

* **Formatting standardization**: Applied consistent Dart formatting throughout the codebase
  - Simplified export statements in [lib/overlay_layers.dart](lib/overlay_layers.dart)
  - Streamlined constructor formatting
  - Improved method call formatting with compact arrow function syntax
  - Consistent line breaking in [lib/src/core/overlay_manager.dart](lib/src/core/overlay_manager.dart)

**Breaking Changes**: None - fully backward compatible. Existing code works without modification.

## 0.1.0 (Planned)

* Initial public release to pub.dev with popup support, overlay management system, type-safe data passing, positioning system
