// Core overlay system exports
export 'src/core/overlay_manager.dart'
    show
        OverlayManager,
        OverlayProvider,
        OverlayRoot,
        OverlayContainer,
        OverlayDataContext;
export 'src/core/types.dart'
    show OverlayInstance, OverlayType, OverlayCreateOptions;

// Popup exports
export 'src/popup/popup_controller.dart' show PopupController, PopupDataContext;
export 'src/popup/popup_widgets.dart'
    show PopupScaffold, AnimatedPopup, PositionedPopup, PopupPosition;

// Future exports will be added here:
// Toast functionality
// export 'src/toast/toast_controller.dart';

// Modal functionality
// export 'src/modal/modal_controller.dart';

// Dialog functionality
// export 'src/dialog/dialog_controller.dart';
