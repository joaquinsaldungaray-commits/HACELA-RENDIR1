import 'dart:convert';

import 'package:hacela_rendir/features/performance/domain/performance_snapshot.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerformanceRepository {
  static const String _storageKey =
      'portfolio_performance_snapshots';

  Future<List<PerformanceSnapshot>> loadSnapshots() async {
    final preferences = await SharedPreferences.getInstance();
    final rawData = preferences.getString(_storageKey);

    if (rawData == null || rawData.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(rawData) as List<dynamic>;

      final snapshots = decoded
          .map(
            (item) => PerformanceSnapshot.fromJson(
              Map<String, dynamic>.from(
                item as Map,
              ),
            ),
          )
          .toList();

      snapshots.sort(
        (first, second) => first.recordedAt.compareTo(
          second.recordedAt,
        ),
      );

      return snapshots;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSnapshots(
    List<PerformanceSnapshot> snapshots,
  ) async {
    final preferences = await SharedPreferences.getInstance();

    final orderedSnapshots =
        List<PerformanceSnapshot>.from(snapshots)
          ..sort(
            (first, second) =>
                first.recordedAt.compareTo(
              second.recordedAt,
            ),
          );

    final encoded = jsonEncode(
      orderedSnapshots
          .map(
            (snapshot) => snapshot.toJson(),
          )
          .toList(),
    );

    await preferences.setString(
      _storageKey,
      encoded,
    );
  }

  Future<void> addSnapshot(
    PerformanceSnapshot snapshot,
  ) async {
    final snapshots = await loadSnapshots();

    final snapshotDate = DateTime(
      snapshot.recordedAt.year,
      snapshot.recordedAt.month,
      snapshot.recordedAt.day,
    );

    final existingIndex = snapshots.indexWhere(
      (existing) {
        final existingDate = DateTime(
          existing.recordedAt.year,
          existing.recordedAt.month,
          existing.recordedAt.day,
        );

        return existingDate == snapshotDate;
      },
    );

    if (existingIndex == -1) {
      snapshots.add(snapshot);
    } else {
      snapshots[existingIndex] = snapshot;
    }

    await saveSnapshots(snapshots);
  }

  Future<void> clearSnapshots() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_storageKey);
  }
}