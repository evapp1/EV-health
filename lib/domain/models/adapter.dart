import 'package:ev_health/domain/models/domain_enums.dart';
import 'package:ev_health/domain/models/identifiers.dart';
import 'package:ev_health/domain/models/model_support.dart';

/// Immutable, privacy-safe adapter metadata.
final class Adapter {
  /// Creates validated adapter metadata.
  Adapter({
    required this.id,
    required this.source,
    required String displayName,
    required String adapterClass,
    required this.compatibilityStatus,
    required DateTime createdAtUtc,
    required DateTime updatedAtUtc,
    DateTime? lastConnectedAtUtc,
  }) : displayName = requireText(displayName, 'displayName'),
       adapterClass = requireText(adapterClass, 'adapterClass'),
       lastConnectedAtUtc = lastConnectedAtUtc == null
           ? null
           : requireUtc(lastConnectedAtUtc, 'lastConnectedAtUtc'),
       createdAtUtc = requireUtc(createdAtUtc, 'createdAtUtc'),
       updatedAtUtc = requireUtc(updatedAtUtc, 'updatedAtUtc') {
    requireOrdered(
      this.createdAtUtc,
      'createdAtUtc',
      this.updatedAtUtc,
      'updatedAtUtc',
    );
    final connectedAt = this.lastConnectedAtUtc;
    if (connectedAt != null) {
      requireOrdered(
        this.createdAtUtc,
        'createdAtUtc',
        connectedAt,
        'lastConnectedAtUtc',
      );
      requireOrdered(
        connectedAt,
        'lastConnectedAtUtc',
        this.updatedAtUtc,
        'updatedAtUtc',
      );
    }
  }

  /// App-generated identifier.
  final AdapterId id;

  /// Real, demo, or test classification.
  final DataSource source;

  /// User-visible adapter name or alias.
  final String displayName;

  /// Generic adapter family/class, without a hardware address.
  final String adapterClass;

  /// Locally observed compatibility.
  final AdapterCompatibilityStatus compatibilityStatus;

  /// Optional last successful connection time in UTC.
  final DateTime? lastConnectedAtUtc;

  /// UTC creation time.
  final DateTime createdAtUtc;

  /// UTC update time.
  final DateTime updatedAtUtc;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Adapter &&
          other.id == id &&
          other.source == source &&
          other.displayName == displayName &&
          other.adapterClass == adapterClass &&
          other.compatibilityStatus == compatibilityStatus &&
          other.lastConnectedAtUtc == lastConnectedAtUtc &&
          other.createdAtUtc == createdAtUtc &&
          other.updatedAtUtc == updatedAtUtc;

  @override
  int get hashCode => Object.hash(
    id,
    source,
    displayName,
    adapterClass,
    compatibilityStatus,
    lastConnectedAtUtc,
    createdAtUtc,
    updatedAtUtc,
  );
}
