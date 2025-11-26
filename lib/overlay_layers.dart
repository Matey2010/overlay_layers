// Core overlay system exports
export 'src/core/overlay_manager.dart' show OverlayManager, OverlayDataContext;
export 'src/core/types.dart'
    show OverlayInstance, OverlayType, OverlayCreateOptions;

// Generic overlay widgets (exported separately for tree-shaking)
export 'src/core/overlay_widgets.dart' show OverlayScaffold;
export 'src/core/overlay_widgets.dart' show AnimatedOverlay;
export 'src/core/overlay_widgets.dart' show PositionedOverlay, OverlayPosition;

// Popup exports
export 'src/popup/popup_controller.dart' show PopupController, PopupDataContext;

// Modal exports
export 'src/modal/modal_controller.dart' show ModalController, ModalDataContext;

// Future exports will be added here:
// Toast functionality
// export 'src/toast/toast_controller.dart' show ToastController, ToastDataContext;

// Tooltip functionality
// export 'src/tooltip/tooltip_controller.dart' show TooltipController, TooltipDataContext;

// Dialog functionality
// export 'src/dialog/dialog_controller.dart' show DialogController, DialogDataContext;
