import 'package:flutter/widgets.dart';
import 'types.dart';
import 'utils.dart';

/// Core overlay manager that handles all overlay types (popup, toast, modal, dialog)
/// Uses Flutter's native Overlay system under the hood
class OverlayManager {
  /// Global singleton instance
  static final instance = OverlayManager._();

  /// Private constructor for singleton
  OverlayManager._();

  /// Public constructor for custom instances (advanced use cases)
  OverlayManager.custom();

  final List<OverlayInstance> _overlays = [];
  final Map<String, OverlayEntry> _entries = {};

  /// All currently active overlays
  List<OverlayInstance> get overlays => List.unmodifiable(_overlays);

  /// Create a new overlay
  /// Requires BuildContext to access Flutter's Overlay
  String createOverlay<TData>({
    required BuildContext context,
    required OverlayType type,
    required WidgetBuilder builder,
    OverlayCreateOptions<TData>? options,
  }) {
    final id = generateId(type.name);

    final overlay = OverlayInstance<TData>(
      id: id,
      type: type,
      builder: builder,
      data: (options?.initialData ?? {}) as TData,
      createdAt: DateTime.now(),
      key: options?.key,
      onDataChange: options?.onDataChange,
      onClose: options?.onClose,
    );

    // Create OverlayEntry that wraps the overlay with data provider
    final entry = OverlayEntry(
      builder: (context) => _OverlayDataProvider(
        overlay: overlay,
        manager: this,
        child: Builder(builder: builder),
      ),
    );

    _overlays.add(overlay);
    _entries[id] = entry;

    // Insert into Flutter's Overlay (use rootOverlay for predictable behavior)
    Overlay.of(context, rootOverlay: true).insert(entry);

    return id;
  }

  /// Remove an overlay from the registry
  void removeOverlay(String id) {
    final index = _overlays.indexWhere((o) => o.id == id);
    if (index != -1) {
      final overlay = _overlays[index];
      final entry = _entries.remove(id);

      // Call onClose callback
      overlay.onClose?.call(overlay.data);

      // Remove entry from Flutter's Overlay if still mounted
      if (entry?.mounted ?? false) {
        entry!.remove();
      }

      _overlays.removeAt(index);
    }
  }

  /// Remove all overlays
  void removeAllOverlays() {
    for (final overlay in _overlays) {
      overlay.onClose?.call(overlay.data);
      final entry = _entries[overlay.id];
      if (entry?.mounted ?? false) {
        entry!.remove();
      }
    }
    _overlays.clear();
    _entries.clear();
  }

  /// Update overlay data
  void updateOverlayData<TData>(String id, TData data) {
    final index = _overlays.indexWhere((o) => o.id == id);
    if (index != -1) {
      final overlay = _overlays[index] as OverlayInstance<TData>;
      final updatedData = _mergeData(overlay.data, data);
      _overlays[index] = overlay.copyWith(data: updatedData);
      overlay.onDataChange?.call(updatedData);

      // Trigger rebuild of the specific entry
      final entry = _entries[id];
      if (entry?.mounted ?? false) {
        entry!.markNeedsBuild();
      }
    }
  }

  /// Get overlay by id
  OverlayInstance? getOverlay(String id) {
    try {
      return _overlays.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get all overlays of a specific type
  List<OverlayInstance> getOverlaysByType(OverlayType type) {
    return _overlays.where((o) => o.type == type).toList();
  }

  /// Merge partial data with existing data
  TData _mergeData<TData>(TData existing, TData partial) {
    // If data is a Map, merge it
    if (existing is Map && partial is Map) {
      return {...existing, ...partial} as TData;
    }
    // Otherwise, replace it
    return partial;
  }
}

/// Internal widget that provides data context to overlay widgets
class _OverlayDataProvider<TData> extends InheritedWidget {
  final OverlayInstance<TData> overlay;
  final OverlayManager manager;

  const _OverlayDataProvider({
    required this.overlay,
    required this.manager,
    required super.child,
  });

  static _OverlayDataProvider<TData>? maybeOf<TData>(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_OverlayDataProvider<TData>>();
  }

  static _OverlayDataProvider<TData> of<TData>(BuildContext context) {
    final provider = maybeOf<TData>(context);
    if (provider == null) {
      throw FlutterError(
        'OverlayDataProvider not found in context.\n'
        'This widget must be used within an overlay component.',
      );
    }
    return provider;
  }

  @override
  bool updateShouldNotify(_OverlayDataProvider<TData> oldWidget) {
    return overlay != oldWidget.overlay;
  }
}

/// Data context provided to individual overlay components
class OverlayDataContext<TData> {
  /// ID of this overlay
  final String overlayId;

  /// Type of this overlay
  final OverlayType type;

  /// Current data
  final TData data;

  /// Update overlay data (merges with current)
  final void Function(TData data) updateData;

  /// Close this overlay
  final void Function([TData? finalData]) close;

  const OverlayDataContext({
    required this.overlayId,
    required this.type,
    required this.data,
    required this.updateData,
    required this.close,
  });

  /// Get the data context from within an overlay widget
  static OverlayDataContext<TData> of<TData>(BuildContext context) {
    final provider = _OverlayDataProvider.of<TData>(context);
    return OverlayDataContext<TData>(
      overlayId: provider.overlay.id,
      type: provider.overlay.type,
      data: provider.overlay.data,
      updateData: (data) =>
          provider.manager.updateOverlayData(provider.overlay.id, data),
      close: ([finalData]) {
        if (finalData != null) {
          provider.manager.updateOverlayData(provider.overlay.id, finalData);
        }
        provider.manager.removeOverlay(provider.overlay.id);
      },
    );
  }

  /// Try to get the data context, returns null if not within an overlay
  static OverlayDataContext<TData>? maybeOf<TData>(BuildContext context) {
    final provider = _OverlayDataProvider.maybeOf<TData>(context);
    if (provider == null) return null;

    return OverlayDataContext<TData>(
      overlayId: provider.overlay.id,
      type: provider.overlay.type,
      data: provider.overlay.data,
      updateData: (data) =>
          provider.manager.updateOverlayData(provider.overlay.id, data),
      close: ([finalData]) {
        if (finalData != null) {
          provider.manager.updateOverlayData(provider.overlay.id, finalData);
        }
        provider.manager.removeOverlay(provider.overlay.id);
      },
    );
  }
}
