import 'package:hacela_rendir/features/assets/data/demo_assets.dart';
import 'package:hacela_rendir/features/assets/domain/asset.dart';

class AssetRepository {
  const AssetRepository();

  Future<List<Asset>> getAll() async {
    return List<Asset>.unmodifiable(
      demoAssets,
    );
  }

  Future<Asset?> findBySymbol(
    String symbol,
  ) async {
    final normalizedSymbol = symbol.trim().toUpperCase();

    if (normalizedSymbol.isEmpty) {
      return null;
    }

    for (final asset in demoAssets) {
      if (asset.symbol.toUpperCase() == normalizedSymbol) {
        return asset;
      }
    }

    return null;
  }

  Future<List<Asset>> search(
    String query,
  ) async {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return getAll();
    }

    return demoAssets.where(
      (asset) {
        return asset.symbol.toLowerCase().contains(
                  normalizedQuery,
                ) ||
            asset.name.toLowerCase().contains(
                  normalizedQuery,
                ) ||
            asset.sector.toLowerCase().contains(
                  normalizedQuery,
                ) ||
            asset.industry.toLowerCase().contains(
                  normalizedQuery,
                );
      },
    ).toList();
  }
}