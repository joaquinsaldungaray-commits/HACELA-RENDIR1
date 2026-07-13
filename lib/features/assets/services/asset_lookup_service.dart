import 'package:hacela_rendir/features/assets/data/asset_repository.dart';
import 'package:hacela_rendir/features/assets/domain/asset.dart';

class AssetLookupService {
  const AssetLookupService({
    AssetRepository? repository,
  }) : repository = repository ?? const AssetRepository();

  final AssetRepository repository;

  Future<Asset?> findBySymbol(
    String symbol,
  ) {
    return repository.findBySymbol(
      symbol,
    );
  }

  Future<List<Asset>> search(
    String query,
  ) {
    return repository.search(
      query,
    );
  }
}