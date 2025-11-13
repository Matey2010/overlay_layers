# overlay_layers

A flexible overlay system for Flutter with support for popups, modals, toasts, and dialogs.

Built on Flutter's native Overlay system with type-safe data passing and lifecycle management.

## Features

- **Native Flutter integration**: Uses Flutter's Overlay API under the hood
- **No wrapper required**: Works immediately without wrapping your app
- **Type-safe**: Full type safety with generics
- **Future-extensible**: Designed to support popups, modals, toasts, and dialogs
- **Simple API**: Easy-to-use controllers and data contexts
- **Lifecycle callbacks**: `onDataChange` and `onClose` hooks
- **Animated widgets**: Built-in animation support
- **Positioned popups**: Popup positioning relative to target widgets

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  overlay_layers: ^1.0.0
```

## Quick Start

No setup required! Just import and use:

```dart
import 'package:overlay_layers/overlay_layers.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        PopupController.of(context).open(
          builder: (context) => MyPopupWidget(),
        );
      },
      child: Text('Open Popup'),
    );
  }
}
```

That's it! The package uses a global singleton manager automatically.

## Usage

### 1. Open a popup

```dart
import 'package:overlay_layers/overlay_layers.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final popupController = PopupController.of(context);

    return ElevatedButton(
      onPressed: () {
        popupController.open(
          builder: (context) => MyPopupWidget(),
          options: OverlayCreateOptions(
            initialData: {'message': 'Hello!'},
            onClose: (data) => print('Closed with: $data'),
          ),
        );
      },
      child: Text('Open Popup'),
    );
  }
}
```

### 3. Access popup data from within a popup

```dart
class MyPopupWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final popup = PopupDataContext.of<Map<String, dynamic>>(context);

    return PopupScaffold(
      onBackdropTap: () => popup.close(),
      child: AnimatedPopup(
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(popup.data['message']),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  popup.updatePopupData({'message': 'Updated!'});
                },
                child: Text('Update'),
              ),
              ElevatedButton(
                onPressed: () => popup.close(),
                child: Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## API Reference

### PopupController

Controller for managing popups.

```dart
final controller = PopupController.of(context);

// Open a popup
final id = controller.open(
  builder: (context) => MyPopupWidget(),
  options: OverlayCreateOptions(
    initialData: {},
    onDataChange: (data) => print(data),
    onClose: (data) => print('Closed'),
  ),
);

// Close specific popup
controller.close(id);

// Close topmost popup
controller.close();

// Close all popups
controller.closeAll();

// Update popup data from outside
controller.updatePopupData(id, {'key': 'value'});

// Get all active popups
final popups = controller.popups;
```

### PopupDataContext

Access and update popup data from within a popup widget.

```dart
final popup = PopupDataContext.of<MyDataType>(context);

// Access data
final data = popup.data;

// Update data (merges with existing)
popup.updatePopupData({'key': 'value'});

// Close popup
popup.close();

// Close with final data
popup.close({'finalKey': 'finalValue'});
```

### OverlayManager

Access the global singleton manager for advanced use cases:

```dart
// Access all active overlays
final overlays = OverlayManager.instance.overlays;

// Get overlays by type
final popups = OverlayManager.instance.getOverlaysByType(OverlayType.popup);

// Or use a custom manager instance (advanced)
final customManager = OverlayManager.custom();
PopupController.withManager(context, customManager).open(...);
```

### Helper Widgets

#### PopupScaffold

Base popup layout with backdrop and positioning.

```dart
PopupScaffold(
  backdropColor: Colors.black.withOpacity(0.5),
  onBackdropTap: () => popup.close(),
  alignment: Alignment.center,
  child: MyContent(),
)
```

#### AnimatedPopup

Animated wrapper with fade and scale animation.

```dart
AnimatedPopup(
  duration: Duration(milliseconds: 200),
  curve: Curves.easeOut,
  child: MyContent(),
)
```

#### PositionedPopup

Position popup relative to a target widget.

```dart
PositionedPopup(
  targetRect: targetRect,
  position: PopupPosition.bottom,
  spacing: 8.0,
  child: MyContent(),
)
```

## Future Features

The package is designed to support additional overlay types:

- **Toast**: Temporary notifications
- **Modal**: Full-screen overlays
- **Dialog**: Alert-style overlays

These will be added in future versions following the same architectural pattern.

## Architecture

The package is built on Flutter's native Overlay system with a centralized `OverlayManager` for state management. Each overlay type (popup, toast, modal, dialog) has its own controller but shares the same underlying infrastructure.

**How it works:**
1. Controllers access Flutter's native `Overlay.of(context)`
2. `OverlayManager` creates and manages `OverlayEntry` instances
3. Each entry wraps your widget with type-safe data context
4. Updates trigger `markNeedsBuild()` on specific entries

**Benefits:**
- No wrapper widget required (uses existing Overlay from MaterialApp/CupertinoApp)
- Native Flutter integration and performance
- Consistent API across overlay types
- Proper z-index management
- Type-safe data passing with generics
- Unified lifecycle management

## License

MIT
