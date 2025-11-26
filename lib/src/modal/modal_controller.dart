import 'package:flutter/widgets.dart';
import '../core/overlay_manager.dart';
import '../core/types.dart';

/// Controller for managing modals
/// Modals are interchangeable - only one modal can be displayed at a time
/// Opening a new modal automatically closes the previous one
class ModalController {
  final OverlayManager _manager;
  final BuildContext _context;

  ModalController._(this._manager, this._context);

  /// Get controller from context
  /// Uses the global singleton OverlayManager
  static ModalController of(BuildContext context) {
    return ModalController._(OverlayManager.instance, context);
  }

  /// Get controller with custom manager (advanced use case)
  static ModalController withManager(
    BuildContext context,
    OverlayManager manager,
  ) {
    return ModalController._(manager, context);
  }

  /// Open a new modal
  /// Automatically closes any existing modal (interchangeable behavior)
  ///
  /// Example:
  /// ```dart
  /// final modalId = modalController.open(
  ///   builder: (context) => MyModalWidget(),
  ///   options: OverlayCreateOptions(
  ///     initialData: {'title': 'Welcome'},
  ///     onDataChange: (data) => print(data),
  ///     onClose: (data) => print('Closed with $data'),
  ///   ),
  /// );
  /// ```
  String open<TData>({
    required WidgetBuilder builder,
    OverlayCreateOptions<TData>? options,
  }) {
    // INTERCHANGEABLE: Close existing modal first
    final modals = _manager.getOverlaysByType(OverlayType.modal);
    if (modals.isNotEmpty) {
      _manager.removeOverlay(modals.last.id);
    }

    // Open new modal
    return _manager.createOverlay<TData>(
      context: _context,
      type: OverlayType.modal,
      builder: builder,
      options: options,
    );
  }

  /// Close the current modal
  void close() {
    final modals = _manager.getOverlaysByType(OverlayType.modal);
    if (modals.isNotEmpty) {
      _manager.removeOverlay(modals.last.id);
    }
  }

  /// Update data of the current modal
  void updateModalData<TData>(TData data) {
    final modals = _manager.getOverlaysByType(OverlayType.modal);
    if (modals.isNotEmpty) {
      _manager.updateOverlayData<TData>(modals.last.id, data);
    }
  }

  /// Get the currently open modal (if any)
  OverlayInstance? get modal {
    final modals = _manager.getOverlaysByType(OverlayType.modal);
    return modals.isNotEmpty ? modals.last : null;
  }
}

/// Data context for modal components
/// Use this to access and update modal data from within a modal widget
class ModalDataContext<TData> {
  final OverlayDataContext<TData> _context;

  ModalDataContext._(this._context);

  /// ID of this modal
  String get modalId => _context.overlayId;

  /// Current data
  TData get data => _context.data;

  /// Update modal data (merges with current)
  void updateModalData(TData data) => _context.updateData(data);

  /// Close this modal
  void close([TData? finalData]) => _context.close(finalData);

  /// Get modal data context from within a modal widget
  ///
  /// Example:
  /// ```dart
  /// class MyModalWidget extends StatelessWidget {
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     final modal = ModalDataContext.of<Map<String, dynamic>>(context);
  ///
  ///     return Column(
  ///       children: [
  ///         Text(modal.data['title']),
  ///         ElevatedButton(
  ///           onPressed: () => modal.close(),
  ///           child: Text('Close'),
  ///         ),
  ///       ],
  ///     );
  ///   }
  /// }
  /// ```
  static ModalDataContext<TData> of<TData>(BuildContext context) {
    final dataContext = OverlayDataContext.of<TData>(context);

    if (dataContext.type != OverlayType.modal) {
      throw FlutterError(
        'ModalDataContext can only be used within modal components.\n'
        'Current overlay type: ${dataContext.type}',
      );
    }

    return ModalDataContext._(dataContext);
  }

  /// Try to get modal data context, returns null if not within a modal
  static ModalDataContext<TData>? maybeOf<TData>(BuildContext context) {
    final dataContext = OverlayDataContext.maybeOf<TData>(context);
    if (dataContext == null || dataContext.type != OverlayType.modal) {
      return null;
    }

    return ModalDataContext._(dataContext);
  }
}
