import 'package:cloud_firestore/cloud_firestore.dart';

// Crop model
class Crop {
  final String name;
  final String category;
  final String season;
  final String waterNeeds;
  final String growthDays;
  final String icon;
  final double estimatedIncome;
  final String suitableRegions;
  final String description;
  final List<String> tips;

  const Crop({
    required this.name,
    required this.category,
    required this.season,
    required this.waterNeeds,
    required this.growthDays,
    required this.icon,
    required this.estimatedIncome,
    required this.suitableRegions,
    required this.description,
    required this.tips,
  });
}

class WeatherData {
  final String location;
  final double temperature;
  final String condition;
  final int humidity;
  final double windSpeed;
  final String icon;
  final List<WeatherForecast> forecast;

  const WeatherData({
    required this.location,
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.icon,
    required this.forecast,
  });
}

class WeatherForecast {
  final String day;
  final double high;
  final double low;
  final String condition;
  final String icon;

  const WeatherForecast({
    required this.day,
    required this.high,
    required this.low,
    required this.condition,
    required this.icon,
  });
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class UserProfile {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final DateTime createdAt;

  UserProfile({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.createdAt,
  });

  String get displayName {
    final fullName = '${firstName.trim()} ${lastName.trim()}'.trim();
    return fullName.isEmpty ? email : fullName;
  }

  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      email: data['email'] as String? ?? '',
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      role: data['role'] as String? ?? 'farmer',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class FarmerFarm {
  final String id;
  final String name;
  final String cropName;
  final String cropIcon;
  final String status;
  final double progress;
  final DateTime plantedAt;
  final int harvestDays;

  FarmerFarm({
    required this.id,
    required this.name,
    required this.cropName,
    this.cropIcon = '🌱',
    required this.status,
    required this.progress,
    required this.plantedAt,
    this.harvestDays = 0,
  });

  // Time-based progress when harvestDays is set; falls back to stored progress for legacy data
  double get liveProgress {
    if (harvestDays > 0) {
      final elapsed = DateTime.now().difference(plantedAt).inSeconds;
      final total = harvestDays * 86400;
      return (elapsed / total).clamp(0.0, 1.0);
    }
    return progress;
  }

  int get daysRemaining {
    if (harvestDays <= 0) return 0;
    final harvestDate = plantedAt.add(Duration(days: harvestDays));
    return harvestDate.difference(DateTime.now()).inDays.clamp(0, harvestDays);
  }

  bool get isHarvestReady => liveProgress >= 1.0;

  String get growthStage {
    final p = liveProgress;
    if (isHarvestReady) return 'Harvest Ready';
    if (p < 0.10) return 'Germinating';
    if (p < 0.35) return 'Sprouting';
    if (p < 0.70) return 'Growing';
    return 'Maturing';
  }

  factory FarmerFarm.fromMap(String id, Map<String, dynamic> data) {
    return FarmerFarm(
      id: id,
      name: data['name'] as String? ?? 'My Farm',
      cropName: data['cropName'] as String? ?? 'Unknown',
      cropIcon: data['cropIcon'] as String? ?? '🌱',
      status: data['status'] as String? ?? 'Planted',
      progress: (data['progress'] as num?)?.toDouble() ?? 0.0,
      plantedAt: (data['plantedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      harvestDays: (data['harvestDays'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'cropName': cropName,
      'cropIcon': cropIcon,
      'status': status,
      'progress': progress,
      'plantedAt': plantedAt,
      'harvestDays': harvestDays,
    };
  }
}

// ─── Farm Grid plot (one cell in the 5×5 grid) ───────────────────────────────
class FarmPlot {
  final String? cropName;
  final String? cropIcon;
  final DateTime? plantedAt;
  final int harvestDays;
  final DateTime? lastWatered;

  const FarmPlot({
    this.cropName,
    this.cropIcon,
    this.plantedAt,
    this.harvestDays = 0,
    this.lastWatered,
  });

  bool get isEmpty => cropName == null;

  double get liveProgress {
    if (isEmpty || plantedAt == null || harvestDays <= 0) return 0.0;
    final elapsed = DateTime.now().difference(plantedAt!).inSeconds;
    return (elapsed / (harvestDays * 86400)).clamp(0.0, 1.0);
  }

  int get daysRemaining {
    if (plantedAt == null || harvestDays <= 0) return 0;
    return plantedAt!
        .add(Duration(days: harvestDays))
        .difference(DateTime.now())
        .inDays
        .clamp(0, harvestDays);
  }

  bool get isHarvestReady => !isEmpty && liveProgress >= 1.0;

  bool get needsWater {
    if (isEmpty) return false;
    if (lastWatered == null) return true;
    return DateTime.now().difference(lastWatered!).inHours >= 24;
  }

  String get growthStage {
    final p = liveProgress;
    if (isHarvestReady) return 'Ready';
    if (p < 0.10) return 'Seed';
    if (p < 0.35) return 'Sprout';
    if (p < 0.70) return 'Growing';
    return 'Maturing';
  }

  String get displayEmoji {
    if (isEmpty) return '';
    final p = liveProgress;
    if (p < 0.10) return '🌱';
    if (p < 0.35) return '🌿';
    return cropIcon!;
  }

  factory FarmPlot.fromMap(Map<String, dynamic> data) {
    return FarmPlot(
      cropName: data['cropName'] as String?,
      cropIcon: data['cropIcon'] as String?,
      plantedAt: (data['plantedAt'] as Timestamp?)?.toDate(),
      harvestDays: (data['harvestDays'] as num?)?.toInt() ?? 0,
      lastWatered: (data['lastWatered'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        if (cropName != null) 'cropName': cropName,
        if (cropIcon != null) 'cropIcon': cropIcon,
        if (plantedAt != null) 'plantedAt': plantedAt,
        if (harvestDays > 0) 'harvestDays': harvestDays,
        if (lastWatered != null) 'lastWatered': lastWatered,
      };
}

// ─── Farm Grid (holds all 25 plots for one farm) ──────────────────────────────
class FarmGrid {
  final String id;
  final String name;
  final Map<String, FarmPlot> plots;

  const FarmGrid({required this.id, required this.name, required this.plots});

  FarmPlot plotAt(int row, int col) =>
      plots['${row}_$col'] ?? const FarmPlot();

  int get plantedCount => plots.values.where((p) => !p.isEmpty).length;
  int get needsWaterCount => plots.values.where((p) => p.needsWater).length;
  int get harvestReadyCount => plots.values.where((p) => p.isHarvestReady).length;

  factory FarmGrid.empty(String id) => FarmGrid(
        id: id,
        name: id == 'farm1' ? 'Farm 1' : 'Farm 2',
        plots: const {},
      );

  factory FarmGrid.fromMap(String id, Map<String, dynamic> data) {
    final rawPlots = (data['plots'] as Map<String, dynamic>?) ?? {};
    return FarmGrid(
      id: id,
      name: data['name'] as String? ?? (id == 'farm1' ? 'Farm 1' : 'Farm 2'),
      plots: rawPlots.map(
        (k, v) => MapEntry(k, FarmPlot.fromMap(v as Map<String, dynamic>)),
      ),
    );
  }
}

class MarketPrice {
  final String docId;
  final String cropName;
  final String unit;
  final double currentPrice;
  final double previousPrice;
  final String trend;
  final String icon;

  const MarketPrice({
    this.docId = '',
    required this.cropName,
    required this.unit,
    required this.currentPrice,
    required this.previousPrice,
    required this.trend,
    required this.icon,
  });

  factory MarketPrice.fromMap(String id, Map<String, dynamic> data) {
    return MarketPrice(
      docId: id,
      cropName: data['cropName'] as String? ?? id,
      unit: data['unit'] as String? ?? 'per kg',
      currentPrice: (data['currentPrice'] as num?)?.toDouble() ?? 0.0,
      previousPrice: (data['previousPrice'] as num?)?.toDouble() ?? 0.0,
      trend: data['trend'] as String? ?? 'stable',
      icon: data['icon'] as String? ?? '🌾',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cropName': cropName,
      'unit': unit,
      'currentPrice': currentPrice,
      'previousPrice': previousPrice,
      'trend': trend,
      'icon': icon,
    };
  }

  double get changePercent =>
      ((currentPrice - previousPrice) / previousPrice) * 100;
}

// Sample data
class SampleData {
  // Realistic average harvest durations in days
  static const Map<String, int> cropHarvestDays = {
    'Rice': 105,
    'Corn': 85,
    'Tomato': 70,
    'Eggplant': 75,
    'Banana': 300,
    'Mango': 120,
  };

  static const List<Crop> crops = [
    Crop(
      name: 'Rice',
      category: 'Grains',
      season: 'Wet Season',
      waterNeeds: 'High',
      growthDays: '90-120 days',
      icon: '🌾',
      estimatedIncome: 45000,
      suitableRegions: 'Lowland, Irrigated',
      description: 'Staple grain crop, best grown in flooded paddies. Requires consistent water supply and warm temperatures.',
      tips: [
        'Plant when soil temperature is above 18°C',
        'Maintain 5–10 cm standing water during early growth',
        'Apply nitrogen fertilizer in split doses',
        'Watch for golden apple snail during seedling stage',
      ],
    ),
    Crop(
      name: 'Corn',
      category: 'Grains',
      season: 'Dry Season',
      waterNeeds: 'Medium',
      growthDays: '75-95 days',
      icon: '🌽',
      estimatedIncome: 32000,
      suitableRegions: 'Upland, Rainfed',
      description: 'Versatile grain crop suitable for upland areas. Good for food and feed production.',
      tips: [
        'Plant at start of rainy season for rainfed areas',
        'Space plants 75 cm x 20 cm apart',
        'Hill up plants at knee height to support roots',
        'Monitor for fall armyworm infestation',
      ],
    ),
    Crop(
      name: 'Tomato',
      category: 'Vegetables',
      season: 'Cool & Dry',
      waterNeeds: 'Medium',
      growthDays: '60-80 days',
      icon: '🍅',
      estimatedIncome: 85000,
      suitableRegions: 'Highland, Lowland',
      description: 'High-value vegetable with strong market demand. Best grown in cooler, drier months.',
      tips: [
        'Use stakes or trellis for indeterminate varieties',
        'Prune suckers for better fruit quality',
        'Avoid overhead irrigation to prevent disease',
        'Apply calcium to prevent blossom end rot',
      ],
    ),
    Crop(
      name: 'Eggplant',
      category: 'Vegetables',
      season: 'Year-round',
      waterNeeds: 'Medium',
      growthDays: '65-85 days',
      icon: '🍆',
      estimatedIncome: 60000,
      suitableRegions: 'Lowland, Irrigated',
      description: 'Popular vegetable with continuous harvest cycle. Tolerates heat well.',
      tips: [
        'Transplant seedlings at 4–5 leaf stage',
        'Mulch to conserve soil moisture',
        'Harvest every 2–3 days for best quality',
        'Rotate crops to manage soil pests',
      ],
    ),
    Crop(
      name: 'Banana',
      category: 'Fruits',
      season: 'Year-round',
      waterNeeds: 'High',
      growthDays: '9-12 months',
      icon: '🍌',
      estimatedIncome: 120000,
      suitableRegions: 'Lowland, Coastal',
      description: 'Perennial fruit crop with high market value. Requires good soil drainage and wind protection.',
      tips: [
        'Remove excess suckers, keep 1 mother + 1 ratoon',
        'Bag bunches 2–3 weeks after emergence',
        'Apply potassium-rich fertilizer monthly',
        'Avoid waterlogged soils to prevent corm rot',
      ],
    ),
    Crop(
      name: 'Mango',
      category: 'Fruits',
      season: 'Summer',
      waterNeeds: 'Low',
      growthDays: '3–5 years to bear',
      icon: '🥭',
      estimatedIncome: 95000,
      suitableRegions: 'Lowland, Coastal',
      description: 'Premium fruit with long productive life. Flower induction possible for off-season production.',
      tips: [
        'Prune after harvest to shape canopy',
        'Induce flowering with potassium nitrate spray',
        'Bag fruits at marble size for pest-free harvest',
        'Avoid over-irrigation during flowering',
      ],
    ),
  ];

  static const WeatherData weather = WeatherData(
    location: 'Gen. Trias, Cavite, PH',
    temperature: 32,
    condition: 'Partly Cloudy',
    humidity: 76,
    windSpeed: 14,
    icon: '⛅',
    forecast: [
      WeatherForecast(day: 'Mon', high: 33, low: 25, condition: 'Sunny', icon: '☀️'),
      WeatherForecast(day: 'Tue', high: 32, low: 24, condition: 'Cloudy', icon: '☁️'),
      WeatherForecast(day: 'Wed', high: 30, low: 23, condition: 'Rainy', icon: '🌧️'),
      WeatherForecast(day: 'Thu', high: 29, low: 23, condition: 'Rainy', icon: '🌧️'),
      WeatherForecast(day: 'Fri', high: 31, low: 24, condition: 'Partly Cloudy', icon: '⛅'),
      WeatherForecast(day: 'Sat', high: 33, low: 25, condition: 'Sunny', icon: '☀️'),
      WeatherForecast(day: 'Sun', high: 34, low: 26, condition: 'Sunny', icon: '☀️'),
    ],
  );

  // Farmgate prices based on CALABARZON/Cavite DA data (April 2026 estimates)
  static const List<MarketPrice> marketPrices = [
    MarketPrice(cropName: 'Sitaw (String Beans)', unit: 'per kg', currentPrice: 55.00, previousPrice: 45.00, trend: 'up', icon: '🫘'),
    MarketPrice(cropName: 'Ampalaya (Bitter Gourd)', unit: 'per kg', currentPrice: 62.00, previousPrice: 70.00, trend: 'down', icon: '🥬'),
    MarketPrice(cropName: 'Talong (Eggplant)', unit: 'per kg', currentPrice: 48.00, previousPrice: 45.00, trend: 'up', icon: '🍆'),
    MarketPrice(cropName: 'Kamatis (Tomato)', unit: 'per kg', currentPrice: 58.00, previousPrice: 50.00, trend: 'up', icon: '🍅'),
    MarketPrice(cropName: 'Pechay (Bok Choy)', unit: 'per kg', currentPrice: 35.00, previousPrice: 35.00, trend: 'stable', icon: '🥦'),
    MarketPrice(cropName: 'Okra', unit: 'per kg', currentPrice: 42.00, previousPrice: 38.00, trend: 'up', icon: '🌿'),
  ];
}
