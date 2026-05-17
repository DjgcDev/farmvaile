import 'dart:async';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';

class MyFarmScreen extends StatefulWidget {
  const MyFarmScreen({super.key});

  @override
  State<MyFarmScreen> createState() => _MyFarmScreenState();
}

class _MyFarmScreenState extends State<MyFarmScreen> {
  final String? _uid = FirebaseService.auth.currentUser?.uid;
  String _activeFarmId = 'farm1';
  late Timer _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Ensure farm documents exist in background — does not block the UI
    if (_uid != null) {
      FirebaseService.ensureFarmGrids(_uid!).catchError((_) {});
    }
    // Refresh every minute so growth % and "days remaining" stay current
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    super.dispose();
  }

  Future<void> _plantCrop(Crop crop, int row, int col) async {
    if (_uid == null) return;
    final days = SampleData.cropHarvestDays[crop.name] ?? 90;
    final harvestDate = DateTime.now().add(Duration(days: days));
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final dateStr = '${harvestDate.day} ${months[harvestDate.month - 1]} ${harvestDate.year}';
    try {
      await FirebaseService.plantCrop(_uid!, _activeFarmId, row, col, crop);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${crop.icon} ${crop.name} planted! Est. harvest: $dateStr'),
          backgroundColor: FarmTheme.primaryGreen,
          duration: const Duration(seconds: 3),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: FarmTheme.errorRed,
        ));
      }
    }
  }

  void _showPlotSheet(FarmPlot plot, int row, int col) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => _PlotSheet(
        plot: plot,
        onWater: () => _waterPlot(row, col),
        onRemove: () => _removePlot(row, col),
      ),
    );
  }

  Future<void> _waterPlot(int row, int col) async {
    if (_uid == null) return;
    Navigator.pop(context);
    await FirebaseService.waterPlot(_uid!, _activeFarmId, row, col);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('💧 Crop watered!'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ));
    }
  }

  Future<void> _removePlot(int row, int col) async {
    if (_uid == null) return;
    Navigator.pop(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Crop?'),
        content: const Text('Clear this plot? Progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: FarmTheme.errorRed),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok == true && _uid != null) {
      await FirebaseService.removePlot(_uid!, _activeFarmId, row, col);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return const Scaffold(body: Center(child: Text('Not authenticated')));
    }

    return Scaffold(
      backgroundColor: FarmTheme.backgroundGrey,
      appBar: AppBar(title: const Text('My Farm')),
      body: StreamBuilder<FarmGrid>(
        stream: FirebaseService.farmGridStream(_uid!, 'farm1'),
        builder: (_, snap1) => StreamBuilder<FarmGrid>(
          stream: FirebaseService.farmGridStream(_uid!, 'farm2'),
          builder: (_, snap2) {
            final farm1 = snap1.data ?? FarmGrid.empty('farm1');
            final farm2 = snap2.data ?? FarmGrid.empty('farm2');
            final activeGrid = _activeFarmId == 'farm1' ? farm1 : farm2;

            return Column(
              children: [
                _FarmSwitcher(
                  farm1: farm1,
                  farm2: farm2,
                  activeFarmId: _activeFarmId,
                  onSwitch: (id) => setState(() => _activeFarmId = id),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _FarmGridView(
                          grid: activeGrid,
                          onDrop: _plantCrop,
                          onCellTap: _showPlotSheet,
                        ),
                        _StatsBar(grid: activeGrid),
                        const Divider(height: 24),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: Row(
                            children: [
                              Text(
                                'Crop Shelf',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: FarmTheme.textDark,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text(
                                '— drag to any empty plot',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: FarmTheme.textLight,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 138,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            itemCount: SampleData.crops.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 10),
                            itemBuilder: (_, i) =>
                                _CropShelfItem(crop: SampleData.crops[i]),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Farm switcher tabs
// ─────────────────────────────────────────────────────────────────────────────

class _FarmSwitcher extends StatelessWidget {
  final FarmGrid farm1;
  final FarmGrid farm2;
  final String activeFarmId;
  final ValueChanged<String> onSwitch;

  const _FarmSwitcher({
    required this.farm1,
    required this.farm2,
    required this.activeFarmId,
    required this.onSwitch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FarmTheme.primaryGreen,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Row(
        children: [
          _Tab(farm: farm1, isActive: activeFarmId == 'farm1', onTap: () => onSwitch('farm1')),
          const SizedBox(width: 8),
          _Tab(farm: farm2, isActive: activeFarmId == 'farm2', onTap: () => onSwitch('farm2')),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final FarmGrid farm;
  final bool isActive;
  final VoidCallback onTap;

  const _Tab({required this.farm, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                '🌾 ${farm.name}',
                style: TextStyle(
                  color: isActive ? FarmTheme.primaryGreen : Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${farm.plantedCount}/25 planted'
                '${farm.harvestReadyCount > 0 ? "  •  ${farm.harvestReadyCount} ready 🎉" : ""}',
                style: TextStyle(
                  color: isActive
                      ? FarmTheme.textLight
                      : Colors.white.withValues(alpha: 0.7),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5×5 farm grid
// ─────────────────────────────────────────────────────────────────────────────

class _FarmGridView extends StatelessWidget {
  final FarmGrid grid;
  final void Function(Crop, int, int) onDrop;
  final void Function(FarmPlot, int, int) onCellTap;

  const _FarmGridView({
    required this.grid,
    required this.onDrop,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final available = constraints.maxWidth - 24; // 12px padding each side
      final cellSize = (available - 4 * 4) / 5; // 4px gap × 4 gaps

      return Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: List.generate(5, (row) => Padding(
            padding: row > 0 ? const EdgeInsets.only(top: 4) : EdgeInsets.zero,
            child: Row(
              children: List.generate(5, (col) => Padding(
                padding: col > 0 ? const EdgeInsets.only(left: 4) : EdgeInsets.zero,
                child: _FarmCell(
                  plot: grid.plotAt(row, col),
                  size: cellSize,
                  onDrop: (crop) => onDrop(crop, row, col),
                  onTap: grid.plotAt(row, col).isEmpty
                      ? null
                      : () => onCellTap(grid.plotAt(row, col), row, col),
                ),
              )),
            ),
          )),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single plot cell
// ─────────────────────────────────────────────────────────────────────────────

class _FarmCell extends StatelessWidget {
  final FarmPlot plot;
  final double size;
  final ValueChanged<Crop> onDrop;
  final VoidCallback? onTap;

  const _FarmCell({
    required this.plot,
    required this.size,
    required this.onDrop,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<Crop>(
      onWillAcceptWithDetails: (_) => plot.isEmpty,
      onAcceptWithDetails: (d) => onDrop(d.data),
      builder: (_, candidateData, __) {
        final hovering = candidateData.isNotEmpty && plot.isEmpty;
        return GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: _bgColor(hovering),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _borderColor(hovering),
                width: plot.isHarvestReady ? 2.0 : 1.0,
              ),
              boxShadow: plot.isHarvestReady
                  ? [BoxShadow(
                      color: FarmTheme.accentAmber.withValues(alpha: 0.55),
                      blurRadius: 5,
                    )]
                  : null,
            ),
            child: hovering
                ? const Center(child: Icon(Icons.add_circle, color: Colors.white, size: 20))
                : _content(),
          ),
        );
      },
    );
  }

  Color _bgColor(bool hovering) {
    if (hovering) return FarmTheme.lightGreen;
    if (plot.isEmpty) return const Color(0xFFC4A882);
    if (plot.isHarvestReady) return const Color(0xFF2E7D32);
    return const Color(0xFF558B2F);
  }

  Color _borderColor(bool hovering) {
    if (hovering) return Colors.white;
    if (plot.isEmpty) return const Color(0xFFB08D5A);
    if (plot.isHarvestReady) return FarmTheme.accentAmber;
    return const Color(0xFF33691E);
  }

  Widget _content() {
    if (plot.isEmpty) {
      return Center(
        child: Icon(Icons.add, size: size * 0.28, color: const Color(0xFFB08D5A)),
      );
    }
    final emojiSize = (size * 0.3 + plot.liveProgress * size * 0.28)
        .clamp(size * 0.28, size * 0.6);
    return Stack(
      children: [
        Center(child: Text(plot.displayEmoji, style: TextStyle(fontSize: emojiSize))),
        if (plot.needsWater)
          Positioned(
            bottom: 2, left: 2,
            child: Icon(Icons.water_drop, size: size * 0.2, color: Colors.orange.shade400),
          ),
        if (plot.isHarvestReady)
          Positioned(
            top: 1, right: 1,
            child: Text('✨', style: TextStyle(fontSize: size * 0.18)),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats bar
// ─────────────────────────────────────────────────────────────────────────────

class _StatsBar extends StatelessWidget {
  final FarmGrid grid;
  const _StatsBar({required this.grid});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _StatChip(
            label: 'Planted',
            value: '${grid.plantedCount}',
            icon: '🌱',
            color: FarmTheme.primaryGreen,
          ),
          const SizedBox(width: 8),
          _StatChip(
            label: 'Needs Water',
            value: '${grid.needsWaterCount}',
            icon: '💧',
            color: Colors.orange,
          ),
          const SizedBox(width: 8),
          _StatChip(
            label: 'Ready',
            value: '${grid.harvestReadyCount}',
            icon: '🎉',
            color: FarmTheme.accentAmber,
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(fontSize: 9, color: FarmTheme.textLight),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Plot detail bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _PlotSheet extends StatelessWidget {
  final FarmPlot plot;
  final VoidCallback onWater;
  final VoidCallback onRemove;

  const _PlotSheet({required this.plot, required this.onWater, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final progress = plot.liveProgress;
    final ready = plot.isHarvestReady;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(plot.displayEmoji, style: const TextStyle(fontSize: 48)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plot.cropName!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: FarmTheme.textDark,
                      ),
                    ),
                    Text(
                      '${plot.growthStage}  •  ${plot.harvestDays} day crop',
                      style: const TextStyle(fontSize: 12, color: FarmTheme.textLight),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: FarmTheme.paleGreen,
              color: ready ? FarmTheme.accentAmber : FarmTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ready
                    ? '🎉 Ready to Harvest!'
                    : '${plot.daysRemaining} days until harvest',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ready ? FarmTheme.accentAmber : FarmTheme.textDark,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}% grown',
                style: const TextStyle(fontSize: 12, color: FarmTheme.textLight),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: plot.needsWater ? Colors.orange.shade50 : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: plot.needsWater
                    ? Colors.orange.shade200
                    : Colors.blue.shade200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.water_drop,
                  color: plot.needsWater ? Colors.orange : Colors.blue,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  plot.needsWater ? 'This crop needs water' : 'Watered today ✓',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: plot.needsWater
                        ? Colors.orange.shade800
                        : Colors.blue.shade800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: plot.needsWater ? onWater : null,
                  icon: const Icon(Icons.water_drop_outlined, size: 16),
                  label: Text(plot.needsWater ? 'Water Crop' : 'Watered ✓'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    disabledBackgroundColor: Colors.blue.shade100,
                    disabledForegroundColor: Colors.blue.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Remove'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: FarmTheme.errorRed,
                    side: const BorderSide(color: FarmTheme.errorRed),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Crop shelf — draggable items
// ─────────────────────────────────────────────────────────────────────────────

class _CropShelfItem extends StatelessWidget {
  final Crop crop;
  const _CropShelfItem({required this.crop});

  @override
  Widget build(BuildContext context) {
    return Draggable<Crop>(
      data: crop,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(scale: 1.08, child: _card(elevated: true)),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: _card()),
      child: _card(),
    );
  }

  Widget _card({bool elevated = false}) {
    final days = SampleData.cropHarvestDays[crop.name] ?? 90;
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: FarmTheme.cardWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: elevated
            ? [BoxShadow(
                color: FarmTheme.primaryGreen.withValues(alpha: 0.28),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )]
            : [BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 5,
                offset: const Offset(0, 2),
              )],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(crop.icon, style: const TextStyle(fontSize: 30)),
          const SizedBox(height: 5),
          Text(
            crop.name,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: FarmTheme.textDark,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '~$days days',
            style: const TextStyle(fontSize: 9, color: FarmTheme.textLight),
          ),
        ],
      ),
    );
  }
}
