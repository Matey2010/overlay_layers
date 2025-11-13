# Claude AI Development Notes

## Project Overview

`overlay_layers` is a Flutter package providing a unified overlay management system for popups, modals, toasts, and dialogs. Built on Flutter's native Overlay API with type-safe data passing and lifecycle management. **No wrapper widgets required** - works immediately with any Flutter app.

## Architecture Summary

### Core Architecture (v1.0.0)

The package uses Flutter's native `Overlay` system under the hood:

1. **Controllers** (e.g., PopupController) access `Overlay.of(context)` when opening overlays
2. **OverlayManager** creates `OverlayEntry` instances and inserts them into Flutter's Overlay
3. **Each OverlayEntry** wraps the user's widget with `_OverlayDataProvider` for type-safe data access
4. **Updates** call `entry.markNeedsBuild()` for efficient rendering
5. **Removal** calls `entry.remove()` to clean up

**Key benefit**: No custom overlay system, no wrapper widgets - pure Flutter integration.

### Core Components

1. **OverlayManager** ([lib/src/core/overlay_manager.dart](lib/src/core/overlay_manager.dart))
   - **Singleton pattern** with `OverlayManager.instance` global accessor
   - Central state manager for all overlays
   - Creates and manages Flutter `OverlayEntry` instances
   - Requires `BuildContext` to access `Overlay.of(context)`
   - Handles data merging for type-safe updates
   - Calls `entry.markNeedsBuild()` on data updates
   - Optional custom instances via `OverlayManager.custom()` for advanced use

2. **_OverlayDataProvider** (Internal)
   - Internal `InheritedWidget` wrapping each overlay's widget
   - Provides type-safe data context to overlay widgets
   - Lives inside each `OverlayEntry` builder

3. **OverlayDataContext** ([lib/src/core/overlay_manager.dart](lib/src/core/overlay_manager.dart))
   - Public API for overlay widgets to access their data
   - Provides `data`, `updateData()`, and `close()` methods
   - Type-safe generic implementation
   - Static `of()` and `maybeOf()` accessors
   - Works through `_OverlayDataProvider`

4. **Controllers** (e.g., PopupController)
   - Type-specific controllers (PopupController, future: ToastController, etc.)
   - Store `BuildContext` to access Flutter's Overlay
   - Provide convenient methods: `open()`, `close()`, `updatePopupData()`
   - `open()` returns overlay ID for external control

### Type System

- **OverlayType**: Enum defining overlay types (popup, toast, modal, dialog)
- **OverlayInstance**: Generic class representing an active overlay
- **OverlayCreateOptions**: Configuration for overlay creation (initialData, callbacks)

### Current Implementation Status

**Implemented:**
- Core overlay management system
- Popup functionality with controller
- Type-safe data passing with generics
- Lifecycle callbacks (onDataChange, onClose)
- Helper widgets (PopupScaffold, AnimatedPopup, PositionedPopup)

**Planned (Future):**
- Toast controller and widgets
- Modal controller and widgets
- Dialog controller and widgets

## Code Style and Formatting (v0.0.2 Changes)

### Formatting Standards Applied

The codebase follows these Dart formatting conventions:

1. **Export Statements**
   - Single-line exports when possible
   - Multi-line only for multiple exports from same file
   ```dart
   // Preferred
   export 'src/popup/popup_controller.dart' show PopupController, PopupDataContext;

   // Multi-line for clarity when needed
   export 'src/popup/popup_widgets.dart'
       show PopupScaffold, AnimatedPopup, PositionedPopup, PopupPosition;
   ```

2. **Constructor Formatting**
   - Compact single-line when parameters fit
   - Super parameters on same line as other params
   ```dart
   const OverlayRoot({super.key, required this.child, this.manager});
   ```

3. **Method Chaining and Calls**
   - Arrow function syntax for concise lambdas
   - Line breaks for readability when chaining
   ```dart
   updateData: (data) =>
       provider.manager.updateOverlayData(provider.overlay.id, data),
   ```

4. **Widget Builder Callbacks**
   - Inline builder when simple
   ```dart
   initialEntries: [OverlayEntry(builder: (context) => widget.child)]
   ```

### Key Patterns to Follow

1. **Context Access Pattern**
   ```dart
   final provider = context
       .dependOnInheritedWidgetOfExactType<OverlayProvider>();
   ```

2. **Data Merging**
   - Map types merge with spread operator
   - Non-map types are replaced
   ```dart
   if (existing is Map && partial is Map) {
     return {...existing, ...partial} as TData;
   }
   return partial;
   ```

3. **Error Messages**
   - Descriptive FlutterError with usage hints
   ```dart
   throw FlutterError(
     'OverlayProvider not found in context.\n'
     'Make sure your app is wrapped with OverlayProvider.',
   );
   ```

## Development Guidelines

### Adding New Overlay Types

When adding toast, modal, or dialog functionality:

1. Create controller in `src/<type>/` following PopupController pattern
2. Create widgets in `src/<type>/` following popup widgets pattern
3. Add exports to main [lib/overlay_layers.dart](lib/overlay_layers.dart)
4. Use same `OverlayManager` infrastructure
5. Create type-specific `<Type>DataContext` extending `OverlayDataContext`

### Testing Approach

- Unit test OverlayManager data merging logic
- Widget test overlay lifecycle (create, update, remove)
- Integration test multiple overlay types simultaneously
- Test error cases (missing provider, invalid IDs)

### Public API Surface

**Exported from package:**
- Core: `OverlayManager` (singleton), `OverlayDataContext`
- Types: `OverlayInstance`, `OverlayType`, `OverlayCreateOptions`
- Popup: `PopupController`, `PopupDataContext`, `PopupScaffold`, `AnimatedPopup`, `PositionedPopup`, `PopupPosition`

**Internal (not exported):**
- `_OverlayDataProvider`: Internal inherited widget for data context
- Utility functions in `utils.dart`

**Removed in v1.0.0:**
- `OverlayRoot`: No longer needed - use Flutter's native Overlay
- `OverlayContainer`: No longer needed - OverlayEntry handles rendering
- `OverlayProvider`: Replaced with singleton pattern (`OverlayManager.instance`)

## Version History

### v1.0.0 (Current)

**BREAKING CHANGES**: Major architectural refactor to use Flutter's native Overlay system - see [CHANGELOG.md](CHANGELOG.md)

**Key Changes:**
- Removed `OverlayRoot` and `OverlayContainer` - no wrapper widgets required
- Removed `OverlayProvider` - replaced with singleton pattern
- `OverlayManager` now uses Flutter's `OverlayEntry` API directly
- `OverlayManager.instance` provides global singleton access
- Renamed `updateData()` → `updatePopupData()` in PopupController and PopupDataContext
- Controllers now require `BuildContext` to access `Overlay.of(context)`
- Native Flutter integration for better performance and compatibility

**Migration from v0.2.0:**
```dart
// Before (v0.2.0)
OverlayRoot(child: MyApp())
PopupController.of(context).open(...)

// After (v1.0.0) - No setup needed!
MaterialApp(home: MyApp())
PopupController.of(context).open(...)  // Uses singleton automatically
```

### v0.2.0

Flexible overlay rendering with `includeContainer` parameter.

### v0.1.0

Initial release with popup support.

## Common Tasks

### Open a Popup Programmatically
```dart
final controller = PopupController.of(context);
final id = controller.open(
  builder: (context) => MyPopupWidget(),
  options: OverlayCreateOptions(initialData: {}),
);
```

### Access and Update Data Inside Popup
```dart
final popup = PopupDataContext.of<Map<String, dynamic>>(context);
popup.updatePopupData({'key': 'value'});  // Note: renamed method
popup.close();
```

### Update Popup Data from Outside
```dart
final controller = PopupController.of(context);
final id = controller.open(...);
controller.updatePopupData(id, {'newKey': 'newValue'});  // Note: renamed method
```

### Basic Setup (No Wrapper Needed!)

```dart
// Just use your app - overlays work automatically with the singleton!
void main() {
  runApp(MaterialApp(home: MyHomePage()));
}
```

### Advanced: Custom OverlayManager

```dart
// Only if you need a custom manager (very rare)
final customManager = OverlayManager.custom();
PopupController.withManager(context, customManager).open(...);

// Access global singleton
final overlays = OverlayManager.instance.overlays;
```

## Notes for AI Assistants

- Always preserve the centralized architecture - don't create separate overlay systems
- Maintain type safety with generics throughout
- Follow the established patterns when adding new overlay types
- Export new features explicitly in [lib/overlay_layers.dart](lib/overlay_layers.dart)
- Add lifecycle callbacks (onDataChange, onClose) for all overlay types
- **v1.0.0+**: All overlays use Flutter's native `OverlayEntry` system
- **v1.0.0+**: `OverlayManager.instance` singleton is the default, no OverlayProvider needed
- **v1.0.0+**: Controllers must store `BuildContext` to access `Overlay.of(context)`
- **v1.0.0+**: Data update methods renamed to be more specific (e.g., `updatePopupData`)
- **v1.0.0+**: No wrapper widgets required - works with any Flutter app immediately
- **v1.0.0+**: Custom managers available via `OverlayManager.custom()` for advanced use
