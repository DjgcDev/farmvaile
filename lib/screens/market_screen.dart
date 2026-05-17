import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmTheme.backgroundGrey,
      appBar: AppBar(
        title: const Text('Market Prices'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Live Prices'),
            Tab(text: 'Income Est.'),
            Tab(text: 'Trends'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LivePricesTab(),
          _IncomeEstimatorTab(),
          _TrendsTab(),
        ],
      ),
    );
  }
}

class _LivePricesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Last updated
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: FarmTheme.paleGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.update, size: 16, color: FarmTheme.primaryGreen),
                SizedBox(width: 8),
                Text(
                  'Farm Gate Prices  •  Last updated: Today 7:00 AM',
                  style: TextStyle(
                    fontSize: 12,
                    color: FarmTheme.textMedium,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Market summary
          const Row(
            children: [
              Expanded(child: StatCard(label: 'Rising', value: '4', icon: '📈', color: Colors.green)),
              SizedBox(width: 10),
              Expanded(child: StatCard(label: 'Falling', value: '2', icon: '📉', color: Colors.red)),
              SizedBox(width: 10),
              Expanded(child: StatCard(label: 'Stable', value: '1', icon: '📊', color: FarmTheme.textLight)),
            ],
          ),
          const SizedBox(height: 20),

          const SectionHeader(title: 'All Crops Today'),
          const SizedBox(height: 12),

          ...SampleData.marketPrices.map((p) => _PriceCard(price: p)),
          const SizedBox(height: 20),

          // Best crops to sell
          const SectionHeader(
            title: 'Best to Sell Now',
            subtitle: 'Based on current market prices',
          ),
          const SizedBox(height: 12),
          _BestToSell(),
        ],
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final MarketPrice price;
  const _PriceCard({required this.price});

  @override
  Widget build(BuildContext context) {
    final isUp = price.trend == 'up';
    final isDown = price.trend == 'down';
    final trendColor = isUp ? Colors.green : isDown ? Colors.red : Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(price.icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    price.cropName,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  Text(
                    price.unit,
                    style: const TextStyle(fontSize: 12, color: FarmTheme.textLight),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₱${price.currentPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: FarmTheme.textDark,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: trendColor.withAlpha((0.12 * 255).round()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isUp ? Icons.trending_up : isDown ? Icons.trending_down : Icons.trending_flat,
                        size: 12,
                        color: trendColor,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${price.changePercent.abs().toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 11,
                          color: trendColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BestToSell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF3E5F5), Color(0xFFEDE7F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromRGBO(128, 0, 128, 0.2)),
      ),
      child: const Column(
        children: [
          Row(
            children: [
              Text('🏆', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'AI Market Analysis',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ],
          ),
          SizedBox(height: 12),
          _BestCropRow(icon: '🫘', crop: 'Sitaw (String Beans)', reason: '22% price increase this week'),
          SizedBox(height: 8),
          _BestCropRow(icon: '🍅', crop: 'Kamatis (Tomato)', reason: 'Steady demand, 16% above avg'),
          SizedBox(height: 8),
          _BestCropRow(icon: '🍆', crop: 'Talong (Eggplant)', reason: 'Price rising, good time to sell'),
        ],
      ),
    );
  }
}

class _BestCropRow extends StatelessWidget {
  final String icon, crop, reason;
  const _BestCropRow({required this.icon, required this.crop, required this.reason});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(crop, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Text(reason, style: const TextStyle(fontSize: 11, color: FarmTheme.textLight)),
            ],
          ),
        ),
        const TagChip(label: 'Sell Now'),
      ],
    );
  }
}

class _IncomeEstimatorTab extends StatefulWidget {
  @override
  State<_IncomeEstimatorTab> createState() => _IncomeEstimatorTabState();
}

class _IncomeEstimatorTabState extends State<_IncomeEstimatorTab> {
  double _landArea = 1.0;
  String _selectedCrop = 'Rice';
  double _estimatedIncome = 45000;

  void _updateEstimate() {
    final baseIncome = {
      'Rice': 45000.0,
      'Corn': 32000.0,
      'Tomato': 85000.0,
      'Eggplant': 60000.0,
      'Banana': 120000.0,
      'Mango': 95000.0,
    };
    setState(() {
      _estimatedIncome = (baseIncome[_selectedCrop] ?? 45000) * _landArea;
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenses = _estimatedIncome * 0.4;
    final netIncome = _estimatedIncome - expenses;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Income Estimator', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 4),
                  const Text('Enter your farming details below', style: TextStyle(fontSize: 12, color: FarmTheme.textLight)),
                  const SizedBox(height: 18),

                  // Crop picker
                  const Text('Crop', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCrop,
                    decoration: const InputDecoration(hintText: 'Select crop'),
                    items: ['Rice', 'Corn', 'Tomato', 'Eggplant', 'Banana', 'Mango']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) {
                      _selectedCrop = v!;
                      _updateEstimate();
                    },
                  ),
                  const SizedBox(height: 16),

                  // Land area
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Land Area (hectares)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text(
                        '${_landArea.toStringAsFixed(1)} ha',
                        style: const TextStyle(color: FarmTheme.primaryGreen, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: FarmTheme.primaryGreen,
                      thumbColor: FarmTheme.primaryGreen,
                    ),
                    child: Slider(
                      value: _landArea,
                      min: 0.5,
                      max: 10,
                      divisions: 19,
                      onChanged: (v) {
                        setState(() => _landArea = v);
                        _updateEstimate();
                      },
                    ),
                  ),

                  ElevatedButton(
                    onPressed: _updateEstimate,
                    child: const Text('Calculate Estimate'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Results
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Estimated Results', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 6),
                Text(
                  '₱${netIncome.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text('Net Income per Season', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24),
                const SizedBox(height: 12),
                _IncomeRow('Gross Revenue', _estimatedIncome, Colors.white),
                const SizedBox(height: 8),
                _IncomeRow('Est. Expenses', expenses, Colors.red.shade200),
                const SizedBox(height: 8),
                _IncomeRow('Net Income', netIncome, Colors.greenAccent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _IncomeRow(String label, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        Text(
          '₱${amount.toStringAsFixed(2)}',
          style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _TrendsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Price Trends', subtitle: 'Last 30 days'),
          const SizedBox(height: 16),
          const _TrendItem(icon: '🫘', crop: 'Sitaw (String Beans)', high: 60.00, low: 38.00, current: 55.00, trend: 'up'),
          const _TrendItem(icon: '🥬', crop: 'Ampalaya (Bitter Gourd)', high: 78.00, low: 55.00, current: 62.00, trend: 'down'),
          const _TrendItem(icon: '🍅', crop: 'Kamatis (Tomato)', high: 65.00, low: 40.00, current: 58.00, trend: 'up'),
          const _TrendItem(icon: '🍆', crop: 'Talong (Eggplant)', high: 55.00, low: 35.00, current: 48.00, trend: 'up'),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: FarmTheme.paleGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('📊', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 8),
                    Text('AI Market Forecast', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'Sitaw and kamatis prices are rising due to tighter supply from Cavite lowland farms. With rain expected mid-week, this is a good window to harvest sitaw now before field conditions deteriorate. Talong demand from Metro Manila markets remains strong.',
                  style: TextStyle(fontSize: 13, color: FarmTheme.textMedium, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendItem extends StatelessWidget {
  final String icon, crop, trend;
  final double high, low, current;
  const _TrendItem({required this.icon, required this.crop, required this.high, required this.low, required this.current, required this.trend});

  @override
  Widget build(BuildContext context) {
    final isUp = trend == 'up';
    final progress = (current - low) / (high - low);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(crop, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                ),
                Icon(
                  isUp ? Icons.trending_up : Icons.trending_down,
                  color: isUp ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  '₱${current.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: FarmTheme.paleGreen,
                valueColor: AlwaysStoppedAnimation(isUp ? FarmTheme.primaryGreen : Colors.orange),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Low: ₱${low.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, color: FarmTheme.textLight)),
                Text('High: ₱${high.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, color: FarmTheme.textLight)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
