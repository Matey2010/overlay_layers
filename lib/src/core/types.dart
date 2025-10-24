import 'package:flutter/widgets.dart';

/// Type of overlay layer
enum OverlayType {
  popup,
  toast,
  modal,
  dialog,
}

/// Base overlay instance representing any type of overlay (popup, modal, toast, dialog)
class OverlayInstance<TData> {
  /// Unique identifier for this overlay
  final String id;

  /// Type of overlay
  final OverlayType type;

  /// Widget builder to render
  final WidgetBuilder builder;

  /// Data associated with this overlay
  TData data;

  /// Timestamp when overlay was created
  final DateTime createdAt;

  /// Optional key for the overlay widget
  final Key? key;

  /// Callback fired when overlay data changes
  final void Function(TData data)? onDataChange;

  /// Callback fired when overlay closes
  final void Function(TData? data)? onClose;

  OverlayInstance({
    required this.id,
    required this.type,
    required this.builder,
    required this.data,
    required this.createdAt,
    this.key,
    this.onDataChange,
    this.onClose,
  });

  /// Create a copy with updated values
  OverlayInstance<TData> copyWith({
    String? id,
    OverlayType? type,
    WidgetBuilder? builder,
    TData? data,
    DateTime? createdAt,
    Key? key,
    void Function(TData data)? onDataChange,
    void Function(TData? data)? onClose,
  }) {
    return OverlayInstance<TData>(
      id: id ?? this.id,
      type: type ?? this.type,
      builder: builder ?? this.builder,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      key: key ?? this.key,
      onDataChange: onDataChange ?? this.onDataChange,
      onClose: onClose ?? this.onClose,
    );
  }
}

/// Options for creating an overlay
class OverlayCreateOptions<TData> {
  /// Initial data for the overlay
  final TData? initialData;

  /// Optional key for the overlay widget
  final Key? key;

  /// Called when overlay data is updated
  final void Function(TData data)? onDataChange;

  /// Called when overlay is closed
  final void Function(TData? data)? onClose;

  const OverlayCreateOptions({
    this.initialData,
    this.key,
    this.onDataChange,
    this.onClose,
  });
}
