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
