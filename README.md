# overlay_layers

A flexible overlay system for Flutter with support for popups, modals, toasts, and dialogs.

## Features

- **Unified overlay management**: Single system for all overlay types
- **Type-safe**: Full TypeScript-style type safety with generics
- **Future-extensible**: Designed to support popups, modals, toasts, and dialogs
- **Simple API**: Easy-to-use controllers and data contexts
- **Lifecycle callbacks**: `onDataChange` and `onClose` hooks
- **Animated widgets**: Built-in animation support
- **Positioned popups**: Popup positioning relative to target widgets

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  overlay_layers:
    path: ../overlay_layers
```

## Usage

### 1. Wrap your app with OverlayRoot

```dart
import 'package:overlay_layers/overlay_layers.dart';

void main() {
  runApp(
    OverlayRoot(
      child: MyApp(),
    ),
  );
}
```

### 2. Open a popup

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
                  popup.updateData({'message': 'Updated!'});
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

### OverlayRoot

Root widget that provides overlay functionality to your app.

```dart
OverlayRoot(
  child: MyApp(),
)
```

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
controller.updateData(id, {'key': 'value'});

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
popup.updateData({'key': 'value'});

// Close popup
popup.close();

// Close with final data
popup.close({'finalKey': 'finalValue'});
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

The package uses a centralized `OverlayManager` to handle all overlay types. Each overlay type (popup, toast, modal, dialog) has its own controller but shares the same underlying infrastructure. This ensures:

- Consistent API across overlay types
- Proper z-index management
- Unified lifecycle management
- Easy extensibility

## License

MIT
