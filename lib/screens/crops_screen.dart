import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';
import 'my_farm_screen.dart';

class CropsScreen extends StatefulWidget {
  const CropsScreen({super.key});

  @override
  State<CropsScreen> createState() => _CropsScreenState();
}

class _CropsScreenState extends State<CropsScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Grains', 'Vegetables', 'Fruits'];

  List<Crop> get _filteredCrops {
    if (_selectedCategory == 'All') return SampleData.crops;
    return SampleData.crops.where((c) => c.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmTheme.backgroundGrey,
      appBar: AppBar(
        title: const Text('Crop Planner'),
        actions: [
          IconButton(icon: const Icon(Icons.tune), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            color: FarmTheme.primaryGreen,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                // Location chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.white, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'Gen. Trias, Cavite  •  Wet Season  •  Sandy-Loam Soil',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedCategory = cat),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : const Color.fromRGBO(255, 255, 255, 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                color: isSelected ? FarmTheme.primaryGreen : Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Crop Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemCount: _filteredCrops.length,
              itemBuilder: (ctx, i) {
                return _CropCard(crop: _filteredCrops[i]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const MyFarmScreen()));
        },
        backgroundColor: FarmTheme.primaryGreen,
        icon: const Icon(Icons.agriculture, color: Colors.white),
        label: const Text('My Farm', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _CropCard extends StatelessWidget {
  final Crop crop;
  const _CropCard({required this.crop});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CropDetailScreen(crop: crop)),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(crop.icon, style: const TextStyle(fontSize: 36)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: FarmTheme.paleGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      crop.category,
                      style: const TextStyle(
                        fontSize: 9,
                        color: FarmTheme.primaryGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                crop.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: FarmTheme.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                crop.suitableRegions,
                style: const TextStyle(fontSize: 11, color: FarmTheme.textLight),
              ),
              const Spacer(),
              const Divider(),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 12, color: FarmTheme.textLight),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      crop.growthDays,
                      style: const TextStyle(fontSize: 11, color: FarmTheme.textMedium),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text('💰', style: TextStyle(fontSize: 11)),
                  const SizedBox(width: 4),
                  Text(
                    '₱${(crop.estimatedIncome / 1000).toStringAsFixed(0)}K/season',
                    style: const TextStyle(
                      fontSize: 11,
                      color: FarmTheme.primaryGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CropDetailScreen extends StatelessWidget {
  final Crop crop;
  const CropDetailScreen({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmTheme.backgroundGrey,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(crop.icon, style: const TextStyle(fontSize: 80)),
                ),
              ),
            ),
            title: Text(crop.name),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            crop.name,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: FarmTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            children: [
                              TagChip(label: crop.category),
                              TagChip(label: crop.season, color: FarmTheme.accentAmber),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: FarmTheme.paleGreen,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          const Text('Est. Income', style: TextStyle(fontSize: 10, color: FarmTheme.textLight)),
                          Text(
                            '₱${(crop.estimatedIncome / 1000).toStringAsFixed(0)}K',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: FarmTheme.primaryGreen,
                            ),
                          ),
                          const Text('per season', style: TextStyle(fontSize: 10, color: FarmTheme.textLight)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  crop.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: FarmTheme.textMedium,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 20),

                // Crop Details Grid
                Row(
                  children: [
                    Expanded(child: StatCard(label: 'Growth Period', value: crop.growthDays.split(' ')[0], icon: '📅', color: FarmTheme.primaryGreen)),
                    const SizedBox(width: 10),
                    Expanded(child: StatCard(label: 'Water Needs', value: crop.waterNeeds, icon: '💧', color: FarmTheme.skyBlue)),
                    const SizedBox(width: 10),
                    const Expanded(child: StatCard(label: 'Region', value: 'Lowland', icon: '📍', color: FarmTheme.soilBrown)),
                  ],
                ),
                const SizedBox(height: 20),

                // Expert Tips
                const SectionHeader(title: 'Expert Farming Tips', subtitle: 'AI-generated recommendations'),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: crop.tips.asMap().entries.map((e) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: FarmTheme.primaryGreen,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${e.key + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  e.value,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: FarmTheme.textMedium,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MyFarmScreen()),
                          );
                        },
                        icon: const Icon(Icons.agriculture, size: 18),
                        label: const Text('Add to My Farm'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: FarmTheme.primaryGreen,
                        side: const BorderSide(color: FarmTheme.primaryGreen),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Icon(Icons.bookmark_outline),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
