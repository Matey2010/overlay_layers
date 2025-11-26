## 3.0.0

### BREAKING CHANGES

This release removes type-specific widget duplication and introduces a unified, highly configurable widget system.

#### Removed Widgets

All type-specific widgets have been removed to eliminate duplication:

* **`PopupScaffold`** → use `OverlayScaffold`
* **`ModalScaffold`** → use `OverlayScaffold`
* **`AnimatedPopup`** → use `AnimatedOverlay`
* **`AnimatedModal`** → use `AnimatedOverlay`
* **`SlideUpModal`** → use `AnimatedOverlay(slideFrom: Offset(0, 1))`
* **`PositionedPopup`** → use `PositionedOverlay`
* **`PopupPosition`** (enum) → use `OverlayPosition`

#### New Generic Widgets

**OverlayScaffold**: Unified scaffold for all overlay types
- Replaces both PopupScaffold and ModalScaffold (they were identical)
- Works with popups, modals, toasts, dialogs, tooltips
- Same API: `backdropColor`, `onBackdropTap`, `alignment`, `padding`

**AnimatedOverlay**: Flexible animation system
- Configure any combination of fade, scale, and slide animations
- `fade: bool` - Enable fade animation (default: true)
- `scale: bool` - Enable scale animation (default: true)
- `slideFrom: Offset?` - Slide direction (null = no slide)
  - `Offset(0, 1)` = slide from bottom
  - `Offset(0, -1)` = slide from top
  - `Offset(-1, 0)` = slide from left
  - `Offset(1, 0)` = slide from right
- `scaleBegin`, `scaleEnd` - Customize scale range
- `duration`, `curve` - Control timing

**PositionedOverlay**: Generic positioned overlay
- Renamed from PositionedPopup for consistency
- Position any overlay relative to a target widget
- Perfect for tooltips, dropdowns, context menus
- Enum renamed: `PopupPosition` → `OverlayPosition`

### Features

* **Tree-shakable exports**: Widgets exported separately so unused widgets don't bloat your bundle
* **Maximum flexibility**: AnimatedOverlay supports any animation combination
* **Zero duplication**: Single implementation for all overlay types
* **Future-ready**: Prepared for upcoming TooltipOverlay feature

### Migration from v2.0.0

```dart
// Before (v2.0.0)
PopupScaffold(
  child: AnimatedPopup(child: MyContent()),
)

// After (v3.0.0)
OverlayScaffold(
  child: AnimatedOverlay(child: MyContent()),
)

// Before: SlideUpModal
SlideUpModal(child: MyContent())

// After: AnimatedOverlay with slideFrom
AnimatedOverlay(
  slideFrom: Offset(0, 1),
  child: MyContent(),
)

// Before: PositionedPopup
PositionedPopup(
  targetRect: rect,
  position: PopupPosition.bottom,
  child: MyContent(),
)

// After: PositionedOverlay
PositionedOverlay(
  targetRect: rect,
  position: OverlayPosition.bottom,
  child: MyContent(),
)

// Custom animations (new capability!)
AnimatedOverlay(
  fade: true,
  scale: false,
  slideFrom: Offset(-1, 0),  // Slide from left
  duration: Duration(milliseconds: 150),
  child: MyContent(),
)
```

### Benefits

* **Smaller bundle size**: Tree-shaking removes unused widgets
* **Simpler API**: One scaffold, one animation widget
* **More flexible**: Mix any animations (fade + slide, scale + slide, etc.)
* **Consistent**: Same widgets work for all overlay types

## 2.0.0

### Features

* **🎉 Modal Support**: New interchangeable modal system
  - **`ModalController`**: Controller for managing modals with `open()`, `close()`, and `updateModalData()` methods
  - **`ModalDataContext`**: Access and update modal data from within modal widgets
  - **Interchangeable behavior**: Only one modal can be displayed at a time - opening a new modal automatically closes the previous one
  - **Modal widgets**: `ModalScaffold`, `AnimatedModal`, and `SlideUpModal` for building modal UIs
  - Same type-safe data passing and lifecycle management as popups
  - Full API parity with popup system
  - New files: [lib/src/modal/modal_controller.dart](lib/src/modal/modal_controller.dart), [lib/src/modal/modal_widgets.dart](lib/src/modal/modal_widgets.dart)

**Example:**
```dart
// Open a modal (automatically closes any existing modal)
ModalController.of(context).open(
  builder: (context) => MyModalWidget(),
  options: OverlayCreateOptions(initialData: {'title': 'Hello'}),
);

// Access data inside modal
final modal = ModalDataContext.of<Map<String, dynamic>>(context);
modal.updateModalData({'title': 'Updated'});
modal.close();
```

### Bug Fixes

* **Fixed data update functionality**: Overlay data updates now trigger UI rebuilds correctly
  - The `OverlayEntry` builder was capturing the original overlay reference in a closure
  - When `updatePopupData()` or `updateModalData()` was called, data was updated but UI didn't reflect changes
  - **Solution**: Builder now looks up current overlay from manager's list on each rebuild
  - Changes in [lib/src/core/overlay_manager.dart](lib/src/core/overlay_manager.dart#L46-L54)

* **Fixed type cast error with Map<String, dynamic>**: Resolved runtime exception when merging map data
  - Error: `type '_Map<dynamic, dynamic>' is not a subtype of type 'Map<String, dynamic>' in type cast`
  - Occurred when calling `updatePopupData()` or `updateModalData()` with `Map<String, dynamic>` data
  - **Solution**: Added explicit handling for `Map<String, dynamic>` type in `_mergeData` method
  - Changes in [lib/src/core/overlay_manager.dart](lib/src/core/overlay_manager.dart#L129-L141)

### Technical Details

**Data Update Fix - Before (Broken):**
```dart
final entry = OverlayEntry(
  builder: (context) => _OverlayDataProvider(
    overlay: overlay, // Stale reference!
    manager: this,
    child: Builder(builder: builder),
  ),
);
```

**Data Update Fix - After (Fixed):**
```dart
final entry = OverlayEntry(
  builder: (context) {
    final currentOverlay = _overlays.firstWhere((o) => o.id == id);
    return _OverlayDataProvider(
      overlay: currentOverlay, // Fresh data on each rebuild!
      manager: this,
      child: Builder(builder: builder),
    );
  },
);
```

### Migration from v1.0.0

No breaking changes. Simply update to v2.0.0 to get:
- ✅ New modal support with full feature set
- ✅ Fixed data update functionality for popups
- ✅ Resolved type cast errors

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
* **Popup support**: Multiple popups can coexist simultaneously
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
