import 'package:flutter/widgets.dart';
import '../core/overlay_manager.dart';
import '../core/types.dart';

/// Controller for managing popups
/// Provides convenient methods to open, close, and update popups
class PopupController {
  final OverlayManager _manager;

  PopupController(this._manager);

  /// Get controller from context
  static PopupController of(BuildContext context) {
    final manager = OverlayProvider.of(context);
    return PopupController(manager);
  }

  /// Try to get controller from context
  static PopupController? maybeOf(BuildContext context) {
    final manager = OverlayProvider.maybeOf(context);
    return manager != null ? PopupController(manager) : null;
  }

  /// Open a new popup
  ///
  /// Example:
  /// ```dart
  /// final popupId = popupController.open(
  ///   builder: (context) => MyPopupWidget(),
  ///   options: OverlayCreateOptions(
  ///     initialData: {'name': 'John'},
  ///     onDataChange: (data) => print(data),
  ///     onClose: (data) => print('Closed with $data'),
  ///   ),
  /// );
  /// ```
  String open<TData>({
    required WidgetBuilder builder,
    OverlayCreateOptions<TData>? options,
  }) {
    return _manager.createOverlay<TData>(
      type: OverlayType.popup,
      builder: builder,
      options: options,
    );
  }

  /// Close a specific popup or the topmost popup
  void close([String? popupId]) {
    if (popupId != null) {
      _manager.removeOverlay(popupId);
    } else {
      // Close topmost popup
      final popups = _manager.getOverlaysByType(OverlayType.popup);
      if (popups.isNotEmpty) {
        _manager.removeOverlay(popups.last.id);
      }
    }
  }

  /// Close all popups
  void closeAll() {
    final popups = _manager.getOverlaysByType(OverlayType.popup);
    for (final popup in popups) {
      _manager.removeOverlay(popup.id);
    }
  }

  /// Update data of a specific popup
  void updateData<TData>(String popupId, TData data) {
    _manager.updateOverlayData<TData>(popupId, data);
  }

  /// Get all currently open popups
  List<OverlayInstance> get popups =>
      _manager.getOverlaysByType(OverlayType.popup);
}

/// Data context for popup components
/// Use this to access and update popup data from within a popup widget
class PopupDataContext<TData> {
  final OverlayDataContext<TData> _context;

  PopupDataContext._(this._context);

  /// ID of this popup
  String get popupId => _context.overlayId;

  /// Current data
  TData get data => _context.data;

  /// Update popup data (merges with current)
  void updateData(TData data) => _context.updateData(data);

  /// Close this popup
  void close([TData? finalData]) => _context.close(finalData);

  /// Get popup data context from within a popup widget
  ///
  /// Example:
  /// ```dart
  /// class MyPopupWidget extends StatelessWidget {
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     final popup = PopupDataContext.of<Map<String, dynamic>>(context);
  ///
  ///     return Column(
  ///       children: [
  ///         Text(popup.data['name']),
  ///         ElevatedButton(
  ///           onPressed: () => popup.close(),
  ///           child: Text('Close'),
  ///         ),
  ///       ],
  ///     );
  ///   }
  /// }
  /// ```
  static PopupDataContext<TData> of<TData>(BuildContext context) {
    final dataContext = OverlayDataContext.of<TData>(context);

    if (dataContext.type != OverlayType.popup) {
      throw FlutterError(
        'PopupDataContext can only be used within popup components.\n'
        'Current overlay type: ${dataContext.type}',
      );
    }

    return PopupDataContext._(dataContext);
  }

  /// Try to get popup data context, returns null if not within a popup
  static PopupDataContext<TData>? maybeOf<TData>(BuildContext context) {
    final dataContext = OverlayDataContext.maybeOf<TData>(context);
    if (dataContext == null || dataContext.type != OverlayType.popup) {
      return null;
    }

    return PopupDataContext._(dataContext);
  }
}
