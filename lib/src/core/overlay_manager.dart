import 'package:flutter/widgets.dart';
import 'types.dart';
import 'utils.dart';

/// Core overlay manager that handles all overlay types (popup, toast, modal, dialog)
/// Single source of truth for all overlays in the application
class OverlayManager extends ChangeNotifier {
  final List<OverlayInstance> _overlays = [];
  final GlobalKey<OverlayState> _overlayKey = GlobalKey<OverlayState>();

  /// All currently active overlays
  List<OverlayInstance> get overlays => List.unmodifiable(_overlays);

  /// Global key for Flutter's Overlay widget
  GlobalKey<OverlayState> get overlayKey => _overlayKey;

  /// Create a new overlay
  String createOverlay<TData>({
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

    _overlays.add(overlay);
    notifyListeners();

    return id;
  }

  /// Remove an overlay from the registry
  void removeOverlay(String id) {
    final index = _overlays.indexWhere((o) => o.id == id);
    if (index != -1) {
      final overlay = _overlays[index];
      overlay.onClose?.call(overlay.data);
      _overlays.removeAt(index);
      notifyListeners();
    }
  }

  /// Remove all overlays
  void removeAllOverlays() {
    for (final overlay in _overlays) {
      overlay.onClose?.call(overlay.data);
    }
    _overlays.clear();
    notifyListeners();
  }

  /// Update overlay data
  void updateOverlayData<TData>(String id, TData data) {
    final index = _overlays.indexWhere((o) => o.id == id);
    if (index != -1) {
      final overlay = _overlays[index] as OverlayInstance<TData>;
      final updatedData = _mergeData(overlay.data, data);
      _overlays[index] = overlay.copyWith(data: updatedData);
      overlay.onDataChange?.call(updatedData);
      notifyListeners();
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

  @override
  void dispose() {
    removeAllOverlays();
    super.dispose();
  }
}

/// Provider widget for OverlayManager
class OverlayProvider extends InheritedNotifier<OverlayManager> {
  const OverlayProvider({
    super.key,
    required OverlayManager manager,
    required super.child,
  }) : super(notifier: manager);

  static OverlayManager of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<OverlayProvider>();
    if (provider == null) {
      throw FlutterError(
        'OverlayProvider not found in context.\n'
        'Make sure your app is wrapped with OverlayProvider.',
      );
    }
    return provider.notifier!;
  }

  static OverlayManager? maybeOf(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<OverlayProvider>();
    return provider?.notifier;
  }
}

/// Root widget that provides overlay functionality to the app
///
/// This widget sets up the OverlayProvider (via InheritedWidget) that manages
/// all overlay state. Child widgets can access the overlay system through context.
///
/// The [includeContainer] parameter controls whether OverlayContainer is automatically
/// included in the widget tree. When true (default), overlays render automatically.
/// When false, you must manually place OverlayContainer somewhere in your tree.
///
/// How it works:
/// 1. OverlayRoot creates OverlayProvider (makes manager available via context)
/// 2. OverlayContainer looks up the manager via OverlayProvider.of(context)
/// 3. OverlayContainer renders all active overlays on screen
///
/// This follows Flutter's standard pattern: provider creates context, consumer reads it.
class OverlayRoot extends StatefulWidget {
  final Widget child;
  final OverlayManager? manager;

  /// Whether to automatically include OverlayContainer in the widget tree.
  ///
  /// When true (default): OverlayContainer is automatically wrapped with your child
  /// in a Stack, so overlays render immediately without additional setup.
  ///
  /// When false: You must manually add OverlayContainer widget somewhere in your tree.
  /// Useful for advanced layouts where you want precise control over overlay positioning.
  final bool includeContainer;

  const OverlayRoot({
    super.key,
    required this.child,
    this.manager,
    this.includeContainer = true,
  });

  @override
  State<OverlayRoot> createState() => _OverlayRootState();
}

class _OverlayRootState extends State<OverlayRoot> {
  late final OverlayManager _manager;
  late final bool _ownsManager;

  @override
  void initState() {
    super.initState();
    if (widget.manager != null) {
      _manager = widget.manager!;
      _ownsManager = false;
    } else {
      _manager = OverlayManager();
      _ownsManager = true;
    }
  }

  @override
  void dispose() {
    if (_ownsManager) {
      _manager.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = widget.child;

    // Automatically include OverlayContainer if requested
    if (widget.includeContainer) {
      child = Stack(
        children: [
          widget.child,
          const OverlayContainer(),
        ],
      );
    }

    return OverlayProvider(
      manager: _manager,
      child: Overlay(
        key: _manager.overlayKey,
        initialEntries: [OverlayEntry(builder: (context) => child)],
      ),
    );
  }
}

/// Widget that renders all active overlays
class OverlayContainer extends StatelessWidget {
  const OverlayContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = OverlayProvider.of(context);

    return ListenableBuilder(
      listenable: manager,
      builder: (context, _) {
        return Stack(
          children: manager.overlays.map((overlay) {
            return KeyedSubtree(
              key: ValueKey(overlay.id),
              child: _OverlayDataProvider(
                overlay: overlay,
                manager: manager,
                child: Builder(builder: overlay.builder),
              ),
            );
          }).toList(),
        );
      },
    );
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
