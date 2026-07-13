import 'package:hacela_rendir/features/assets/domain/asset.dart';
import 'package:hacela_rendir/features/assets/domain/asset_type.dart';

const List<Asset> demoAssets = [
  Asset(
    symbol: 'AAPL',
    name: 'Apple Inc.',
    type: AssetType.stock,
    exchange: 'NASDAQ',
    country: 'Estados Unidos',
    currency: 'USD',
    sector: 'Tecnología',
    industry: 'Electrónica de consumo',
    isin: 'US0378331005',
    description:
        'Empresa tecnológica dedicada a dispositivos, software y servicios.',
  ),
  Asset(
    symbol: 'MSFT',
    name: 'Microsoft Corporation',
    type: AssetType.stock,
    exchange: 'NASDAQ',
    country: 'Estados Unidos',
    currency: 'USD',
    sector: 'Tecnología',
    industry: 'Software e infraestructura',
    isin: 'US5949181045',
    description:
        'Empresa tecnológica enfocada en software, nube y servicios.',
  ),
  Asset(
    symbol: 'NVDA',
    name: 'NVIDIA Corporation',
    type: AssetType.stock,
    exchange: 'NASDAQ',
    country: 'Estados Unidos',
    currency: 'USD',
    sector: 'Tecnología',
    industry: 'Semiconductores',
    isin: 'US67066G1040',
    description:
        'Diseña procesadores gráficos y plataformas de computación.',
  ),
  Asset(
    symbol: 'SPY',
    name: 'SPDR S&P 500 ETF Trust',
    type: AssetType.etf,
    exchange: 'NYSE Arca',
    country: 'Estados Unidos',
    currency: 'USD',
    sector: 'Diversificado',
    industry: 'ETF de índice',
    isin: 'US78462F1030',
    description:
        'Fondo cotizado que busca replicar el índice S&P 500.',
  ),
  Asset(
    symbol: 'GLD',
    name: 'SPDR Gold Shares',
    type: AssetType.etf,
    exchange: 'NYSE Arca',
    country: 'Estados Unidos',
    currency: 'USD',
    sector: 'Materias primas',
    industry: 'Oro',
    isin: 'US78463V1070',
    description:
        'Fondo cotizado vinculado al precio del oro.',
  ),
  Asset(
    symbol: 'GGAL',
    name: 'Grupo Financiero Galicia',
    type: AssetType.stock,
    exchange: 'BYMA',
    country: 'Argentina',
    currency: 'ARS',
    sector: 'Finanzas',
    industry: 'Bancos',
    isin: 'ARP495251018',
    description:
        'Grupo argentino de servicios financieros y bancarios.',
  ),
  Asset(
    symbol: 'BTC',
    name: 'Bitcoin',
    type: AssetType.crypto,
    exchange: 'Crypto',
    country: 'Global',
    currency: 'USD',
    sector: 'Activos digitales',
    industry: 'Criptomoneda',
    description:
        'Activo digital descentralizado basado en tecnología blockchain.',
  ),
];