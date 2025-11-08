# Claude AI Development Notes

## Project Overview

`overlay_layers` is a Flutter package providing a unified overlay management system for popups, modals, toasts, and dialogs. The core architecture centers around a centralized `OverlayManager` that handles all overlay types with type-safe data passing and lifecycle management.

## Architecture Summary

### Core Components

1. **OverlayManager** ([lib/src/core/overlay_manager.dart](lib/src/core/overlay_manager.dart))
   - Central state manager for all overlays
   - Extends `ChangeNotifier` for reactive updates
   - Manages overlay lifecycle (create, update, remove)
   - Handles data merging for type-safe updates

2. **OverlayProvider** ([lib/src/core/overlay_manager.dart:106-130](lib/src/core/overlay_manager.dart#L106-L130))
   - `InheritedNotifier` widget providing OverlayManager access
   - Static `of()` and `maybeOf()` methods for context-based access
   - Throws descriptive error if not found in widget tree

3. **OverlayRoot** ([lib/src/core/overlay_manager.dart:147-189](lib/src/core/overlay_manager.dart#L147-L189))
   - Root widget wrapping the entire app
   - Creates or accepts external OverlayManager instance
   - Manages manager lifecycle (creation and disposal)
   - Wraps app with Flutter's Overlay widget
   - **NEW in v0.2.0**: `includeContainer` parameter for flexible overlay rendering
     - When `true` (default): Automatically includes `OverlayContainer` in a Stack
     - When `false`: Allows manual placement of `OverlayContainer` for advanced layouts

4. **OverlayContainer** ([lib/src/core/overlay_manager.dart:191-207](lib/src/core/overlay_manager.dart#L191-L207))
   - Renders all active overlays in a Stack
   - Uses `ListenableBuilder` for reactive updates
   - Each overlay wrapped in `KeyedSubtree` with unique ID
   - Provides `_OverlayDataProvider` context to each overlay
   - **NEW in v0.2.0**: Can be manually placed when `OverlayRoot.includeContainer = false`

5. **OverlayDataContext** ([lib/src/core/overlay_manager.dart:240-302](lib/src/core/overlay_manager.dart#L240-L302))
   - Public API for overlay widgets to access their data
   - Provides `data`, `updateData()`, and `close()` methods
   - Type-safe generic implementation
   - Static `of()` and `maybeOf()` accessors

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
- Core: `OverlayManager`, `OverlayProvider`, `OverlayRoot`, `OverlayContainer`, `OverlayDataContext`
- Types: `OverlayInstance`, `OverlayType`, `OverlayCreateOptions`
- Popup: `PopupController`, `PopupDataContext`, `PopupScaffold`, `AnimatedPopup`, `PositionedPopup`, `PopupPosition`

**Internal (not exported):**
- `_OverlayDataProvider`: Internal inherited widget for data context
- `_OverlayRootState`: Private state management
- Utility functions in `utils.dart`

## Version History

### v0.2.0 (Current)

Major architectural enhancement for flexible overlay rendering - see [CHANGELOG.md](CHANGELOG.md)

**Key Changes:**

- Added `includeContainer` parameter to `OverlayRoot` for flexible overlay rendering
- Enhanced documentation explaining the provider pattern architecture
- Improved code formatting and consistency

### v0.1.0 (Planned)

Initial public release on pub.dev with popup support

## Common Tasks

### Open a Popup Programmatically
```dart
final controller = PopupController.of(context);
final id = controller.open(
  builder: (context) => MyPopupWidget(),
  options: OverlayCreateOptions(initialData: {}),
);
```

### Access Data Inside Popup
```dart
final popup = PopupDataContext.of<Map<String, dynamic>>(context);
popup.updateData({'key': 'value'});
popup.close();
```

### Basic Setup (Automatic Container)

```dart
// Default behavior - OverlayContainer automatically included
OverlayRoot(
  child: MyApp(),
)
```

### Advanced Setup (Manual Container Placement)

```dart
// Advanced: Manual control over OverlayContainer placement
OverlayRoot(
  includeContainer: false, // Don't auto-include container
  child: MaterialApp(
    home: Scaffold(
      body: Column(
        children: [
          Expanded(child: MyContent()),
          // Overlays render only above MyContent, not the banner
          Expanded(
            child: Stack(
              children: [
                MyOtherContent(),
                const OverlayContainer(), // Manual placement
              ],
            ),
          ),
        ],
      ),
    ),
  ),
)
```

### Custom Overlay Manager
```dart
final customManager = OverlayManager();
OverlayRoot(
  manager: customManager,
  child: MyApp(),
)
```

## Notes for AI Assistants

- Always preserve the centralized architecture - don't create separate overlay systems
- Maintain type safety with generics throughout
- Follow the established patterns when adding new overlay types
- Keep formatting consistent with v0.2.0 standards
- Export new features explicitly in [lib/overlay_layers.dart](lib/overlay_layers.dart)
- Add lifecycle callbacks (onDataChange, onClose) for all overlay types
- Use `ChangeNotifier` pattern for reactive updates
