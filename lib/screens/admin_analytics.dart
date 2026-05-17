import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  int _farmerCount = 0;
  int _farmCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final farmers = await FirebaseService.farmerCount();
      final farms = await FirebaseService.totalFarmCount();
      if (mounted) {
        setState(() {
          _farmerCount = farmers;
          _farmCount = farms;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmTheme.backgroundGrey,
      appBar: AppBar(
        title: const Text('Analytics'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Platform Summary'),
              const SizedBox(height: 12),
              if (_loading)
                const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()))
              else
                _SummaryPanel(farmerCount: _farmerCount, farmCount: _farmCount),
              const SizedBox(height: 28),
              _sectionTitle('Market Price Comparison'),
              const SizedBox(height: 12),
              StreamBuilder<List<MarketPrice>>(
                stream: FirebaseService.marketPrices(),
                builder: (_, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final prices = snap.data ?? [];
                  if (prices.isEmpty) {
                    return const Text('No price data.',
                        style: TextStyle(color: FarmTheme.textLight));
                  }
                  final maxPrice = prices
                      .map((p) => p.currentPrice)
                      .reduce((a, b) => a > b ? a : b);
                  return _PriceBarChart(prices: prices, maxPrice: maxPrice);
                },
              ),
              const SizedBox(height: 28),
              _sectionTitle('Crop Reference'),
              const SizedBox(height: 12),
              _CropReferenceList(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: FarmTheme.textDark),
      );
}

class _SummaryPanel extends StatelessWidget {
  final int farmerCount;
  final int farmCount;
  const _SummaryPanel({required this.farmerCount, required this.farmCount});

  @override
  Widget build(BuildContext context) {
    final avgFarms =
        farmerCount > 0 ? (farmCount / farmerCount).toStringAsFixed(1) : '—';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FarmTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)
        ],
      ),
      child: Column(
        children: [
          _SummaryRow(
            icon: Icons.people_alt_rounded,
            color: FarmTheme.primaryGreen,
            label: 'Total Farmers',
            value: '$farmerCount',
          ),
          const Divider(height: 24),
          _SummaryRow(
            icon: Icons.agriculture_rounded,
            color: FarmTheme.accentAmber,
            label: 'Total Farms',
            value: '$farmCount',
          ),
          const Divider(height: 24),
          _SummaryRow(
            icon: Icons.bar_chart_rounded,
            color: const Color(0xFF5C6BC0),
            label: 'Avg Farms / Farmer',
            value: avgFarms,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  const _SummaryRow(
      {required this.icon,
      required this.color,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: FarmTheme.textDark)),
        ),
        Text(value,
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }
}

class _PriceBarChart extends StatelessWidget {
  final List<MarketPrice> prices;
  final double maxPrice;
  const _PriceBarChart({required this.prices, required this.maxPrice});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FarmTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)
        ],
      ),
      child: Column(
        children: prices.map((p) => _PriceBar(p: p, maxPrice: maxPrice)).toList(),
      ),
    );
  }
}

class _PriceBar extends StatelessWidget {
  final MarketPrice p;
  final double maxPrice;
  const _PriceBar({required this.p, required this.maxPrice});

  @override
  Widget build(BuildContext context) {
    final isUp = p.trend == 'up';
    final isDown = p.trend == 'down';
    final trendColor = isUp
        ? Colors.green.shade600
        : isDown
            ? Colors.red.shade600
            : FarmTheme.textLight;
    final barFill = maxPrice > 0 ? (p.currentPrice / maxPrice).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(p.icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(p.cropName,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: FarmTheme.textDark)),
              ),
              Text('₱${p.currentPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: trendColor)),
              const SizedBox(width: 4),
              Icon(
                isUp
                    ? Icons.arrow_upward_rounded
                    : isDown
                        ? Icons.arrow_downward_rounded
                        : Icons.remove,
                size: 13,
                color: trendColor,
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: barFill,
              minHeight: 8,
              backgroundColor: FarmTheme.backgroundGrey,
              valueColor: AlwaysStoppedAnimation<Color>(trendColor),
            ),
          ),
          if (p.previousPrice > 0) ...[
            const SizedBox(height: 3),
            Text(
              'Prev: ₱${p.previousPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 10, color: FarmTheme.textLight),
            ),
          ],
        ],
      ),
    );
  }
}

class _CropReferenceList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const crops = SampleData.crops;
    return Container(
      decoration: BoxDecoration(
        color: FarmTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)
        ],
      ),
      child: Column(
        children: List.generate(crops.length, (i) {
          final crop = crops[i];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Text(crop.icon, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(crop.name,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: FarmTheme.textDark)),
                          Text(
                            '${crop.category} · ${crop.season} · ${crop.waterNeeds} water',
                            style: const TextStyle(
                                fontSize: 11, color: FarmTheme.textLight),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(crop.growthDays,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: FarmTheme.primaryGreen)),
                        Text(
                          '₱${(crop.estimatedIncome / 1000).toStringAsFixed(0)}k/ha',
                          style: const TextStyle(
                              fontSize: 10, color: FarmTheme.textLight),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (i < crops.length - 1)
                const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        }),
      ),
    );
  }
}
