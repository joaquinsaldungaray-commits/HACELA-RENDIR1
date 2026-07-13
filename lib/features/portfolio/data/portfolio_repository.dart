import 'dart:convert';

import 'package:hacela_rendir/features/portfolio/domain/portfolio_position.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PortfolioRepository {
  static const String _positionsKey = 'portfolio_positions';

  Future<bool> hasStoredPositions() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.containsKey(_positionsKey);
  }

  Future<List<PortfolioPosition>> loadPositions() async {
    final preferences = await SharedPreferences.getInstance();
    final rawData = preferences.getString(_positionsKey);

    if (rawData == null || rawData.isEmpty) {
      return [];
    }

    final decodedData = jsonDecode(rawData) as List<dynamic>;

    return decodedData
        .map(
          (item) => PortfolioPosition.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<void> savePositions(
    List<PortfolioPosition> positions,
  ) async {
    final preferences = await SharedPreferences.getInstance();

    final encodedData = jsonEncode(
      positions
          .map(
            (position) => position.toJson(),
          )
          .toList(),
    );

    await preferences.setString(
      _positionsKey,
      encodedData,
    );
  }

  Future<void> clearPositions() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_positionsKey);
  }
}