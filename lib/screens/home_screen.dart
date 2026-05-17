import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';
import '../widgets/common_widgets.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final weather = SampleData.weather;

    return Scaffold(
      backgroundColor: FarmTheme.backgroundGrey,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1B5E20),
                      Color(0xFF2E7D32),
                      Color(0xFF388E3C),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FutureBuilder<UserProfile?>(
                              future: FirebaseService.profileForCurrentUser(),
                              builder: (context, snapshot) {
                                final defaultName = FirebaseAuth.instance.currentUser?.email?.split('@').first ?? 'Farmer';
                                final authName = FirebaseAuth.instance.currentUser?.displayName;
                                final name = snapshot.connectionState == ConnectionState.waiting
                                    ? 'Loading...'
                                    : snapshot.data?.displayName ?? authName ?? defaultName;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome $name',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Manage your farm dashboard',
                                      style: TextStyle(
                                        color: Color.fromRGBO(255, 255, 255, 0.85),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const CircleAvatar(
                              radius: 24,
                              backgroundColor: Color.fromRGBO(255, 255, 255, 0.2),
                              child: Text('👨‍🌾', style: TextStyle(fontSize: 22)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(255, 255, 255, 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(weather.icon, style: const TextStyle(fontSize: 28)),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${weather.temperature.toInt()}°C  •  ${weather.condition}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '📍 ${weather.location}  •  💧 ${weather.humidity}% humidity',
                                    style: const TextStyle(
                                      color: Color.fromRGBO(255, 255, 255, 0.8),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            title: const Text('FarmvAIle'),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // AI Recommendation Banner
                _AIRecommendationBanner(onNavigate: onNavigate),
                const SizedBox(height: 20),

                // Quick Actions
                const SectionHeader(title: 'Quick Actions'),
                const SizedBox(height: 12),
                _QuickActionsGrid(onNavigate: onNavigate),
                const SizedBox(height: 20),

                // Today's Market Snapshot
                SectionHeader(
                  title: 'Market Today',
                  subtitle: 'Live farm gate prices',
                  trailing: TextButton(
                    onPressed: () => onNavigate(3),
                    child: const Text('See All', style: TextStyle(color: FarmTheme.primaryGreen)),
                  ),
                ),
                const SizedBox(height: 12),
                _MarketSnapshot(),
                const SizedBox(height: 20),

                // Crop Recommendations
                SectionHeader(
                  title: 'Crops for Your Season',
                  subtitle: 'Based on your location & weather',
                  trailing: TextButton(
                    onPressed: () => onNavigate(2),
                    child: const Text('View All', style: TextStyle(color: FarmTheme.primaryGreen)),
                  ),
                ),
                const SizedBox(height: 12),
                _CropRecommendationRow(onNavigate: onNavigate),
                const SizedBox(height: 20),

                // AI Tip of the Day
                _TipOfTheDay(),
                const SizedBox(height: 30),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _AIRecommendationBanner extends StatelessWidget {
  final Function(int) onNavigate;
  const _AIRecommendationBanner({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: FarmTheme.primaryGreen.withAlpha((0.35 * 255).round()),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: FarmTheme.accentAmber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '🤖 AI Recommendation',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Best time to plant\nRice this week!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Rain expected Wed–Thu. Prepare beds now — sitaw thrives after light rains in Cavite lowlands.',
                  style: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 0.85),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => onNavigate(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Ask AI for Details →',
                      style: TextStyle(
                        color: FarmTheme.primaryGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Text('🌾', style: TextStyle(fontSize: 64)),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final Function(int) onNavigate;
  const _QuickActionsGrid({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {'icon': '🌤️', 'label': 'Weather', 'tab': 1},
      {'icon': '🌿', 'label': 'Crops', 'tab': 2},
      {'icon': '📈', 'label': 'Market', 'tab': 3},
      {'icon': '🤖', 'label': 'AI Chat', 'tab': 4},
    ];

    return Row(
      children: actions.map((a) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onNavigate(a['tab'] as int),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: FarmTheme.cardWhite,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: FarmTheme.primaryGreen.withAlpha((0.08 * 255).round()),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(a['icon'] as String, style: const TextStyle(fontSize: 26)),
                    const SizedBox(height: 6),
                    Text(
                      a['label'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: FarmTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MarketSnapshot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final prices = SampleData.marketPrices.take(3).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: prices.map((p) {
            final isUp = p.trend == 'up';
            final isDown = p.trend == 'down';
            return ListTile(
              leading: Text(p.icon, style: const TextStyle(fontSize: 24)),
              title: Text(
                p.cropName,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              subtitle: Text(p.unit, style: const TextStyle(fontSize: 11, color: FarmTheme.textLight)),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₱${p.currentPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isUp ? '▲' : isDown ? '▼' : '─',
                        style: TextStyle(
                          fontSize: 10,
                          color: isUp ? Colors.green : isDown ? Colors.red : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${p.changePercent.abs().toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 11,
                          color: isUp ? Colors.green : isDown ? Colors.red : Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _CropRecommendationRow extends StatelessWidget {
  final Function(int) onNavigate;
  const _CropRecommendationRow({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final crops = SampleData.crops.take(4).toList();
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: crops.length,
        itemBuilder: (ctx, i) {
          final c = crops[i];
          return GestureDetector(
            onTap: () => onNavigate(2),
            child: Container(
              width: 120,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: FarmTheme.cardWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: FarmTheme.primaryGreen.withAlpha((0.08 * 255).round()),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.icon, style: const TextStyle(fontSize: 30)),
                  const SizedBox(height: 8),
                  Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 4),
                  TagChip(label: c.season, color: FarmTheme.lightGreen),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TipOfTheDay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FarmTheme.accentAmberLight),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('💡', style: TextStyle(fontSize: 24)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tip of the Day',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: FarmTheme.soilBrown,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Apply organic mulch around your vegetable beds to retain soil moisture during the dry season. This can reduce watering frequency by up to 50%.',
                  style: TextStyle(
                    fontSize: 12,
                    color: FarmTheme.textMedium,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
