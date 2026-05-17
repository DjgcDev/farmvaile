import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';

class AdminPricesScreen extends StatelessWidget {
  const AdminPricesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmTheme.backgroundGrey,
      appBar: AppBar(
        title: const Text('Update Prices'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<MarketPrice>>(
        stream: FirebaseService.marketPrices(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final prices = snap.data ?? [];
          if (prices.isEmpty) {
            return const Center(
              child: Text('No prices in database.',
                  style: TextStyle(color: FarmTheme.textLight)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: prices.length,
            itemBuilder: (_, i) => _PriceEditCard(price: prices[i]),
          );
        },
      ),
    );
  }
}

class _PriceEditCard extends StatefulWidget {
  final MarketPrice price;
  const _PriceEditCard({required this.price});

  @override
  State<_PriceEditCard> createState() => _PriceEditCardState();
}

class _PriceEditCardState extends State<_PriceEditCard> {
  late final TextEditingController _ctrl;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: widget.price.currentPrice.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final raw = _ctrl.text.trim();
    final newPrice = double.tryParse(raw);
    if (newPrice == null || newPrice <= 0) {
      setState(() => _error = 'Enter a valid price');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await FirebaseService.updateMarketPrice(
          widget.price.docId, newPrice, widget.price.currentPrice);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.price.cropName} updated to ₱${newPrice.toStringAsFixed(2)}'),
            backgroundColor: FarmTheme.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Failed to save. Try again.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.price;
    final isUp = p.trend == 'up';
    final isDown = p.trend == 'down';
    final trendColor = isUp
        ? Colors.green.shade600
        : isDown
            ? Colors.red.shade600
            : FarmTheme.textLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(p.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.cropName,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: FarmTheme.textDark)),
                    Text(p.unit,
                        style: const TextStyle(
                            fontSize: 11, color: FarmTheme.textLight)),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(
                    isUp
                        ? Icons.arrow_upward_rounded
                        : isDown
                            ? Icons.arrow_downward_rounded
                            : Icons.remove,
                    size: 14,
                    color: trendColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isUp ? 'Up' : isDown ? 'Down' : 'Stable',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: trendColor),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Previous: ₱${p.previousPrice.toStringAsFixed(2)}   Current: ₱${p.currentPrice.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 11, color: FarmTheme.textLight),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'New Price (₱)',
                    prefixText: '₱ ',
                    errorText: _error,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: FarmTheme.primaryGreen, width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FarmTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Save',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
