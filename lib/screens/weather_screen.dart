import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final weather = SampleData.weather;

    return Scaffold(
      backgroundColor: FarmTheme.backgroundGrey,
      appBar: AppBar(
        title: const Text('Weather & Climate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on_outlined),
            onPressed: () {},
            tooltip: 'Change Location',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Weather Card
            _MainWeatherCard(weather: weather),
            const SizedBox(height: 20),

            // Stats Row
            Row(
              children: [
                Expanded(child: StatCard(
                  label: 'Humidity',
                  value: '${weather.humidity}%',
                  icon: '💧',
                  color: FarmTheme.skyBlue,
                )),
                const SizedBox(width: 12),
                Expanded(child: StatCard(
                  label: 'Wind Speed',
                  value: '${weather.windSpeed} km/h',
                  icon: '🌬️',
                  color: FarmTheme.softGreen,
                )),
                const SizedBox(width: 12),
                const Expanded(child: StatCard(
                  label: 'UV Index',
                  value: '7',
                  icon: '☀️',
                  color: FarmTheme.accentAmber,
                )),
              ],
            ),
            const SizedBox(height: 20),

            // 7-Day Forecast
            const SectionHeader(
              title: '7-Day Forecast',
              subtitle: 'Plan your farming schedule',
            ),
            const SizedBox(height: 12),
            _WeeklyForecast(forecast: weather.forecast),
            const SizedBox(height: 20),

            // Farming Alerts
            const SectionHeader(
              title: 'Farming Alerts',
              subtitle: 'Weather impact on your crops',
            ),
            const SizedBox(height: 12),
            _FarmingAlerts(),
            const SizedBox(height: 20),

            // Planting Calendar
            const SectionHeader(
              title: 'Planting Calendar',
              subtitle: 'Optimal windows this month',
            ),
            const SizedBox(height: 12),
            _PlantingCalendar(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _MainWeatherCard extends StatelessWidget {
  final WeatherData weather;
  const _MainWeatherCard({required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF0288D1), Color(0xFF29B6F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(30, 136, 229, 0.35),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📍 ${weather.location}',
                    style: const TextStyle(color: Color.fromRGBO(255, 255, 255, 0.9), fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weather.condition,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(weather.icon, style: const TextStyle(fontSize: 56)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${weather.temperature.toInt()}°C',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 64,
              fontWeight: FontWeight.w300,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Feels like 34°C  •  H:35°  L:23°',
            style: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.8), fontSize: 13),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 255, 255, 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Text('🌾', style: TextStyle(fontSize: 18)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Good conditions for fieldwork today. Avoid irrigation midday.',
                    style: TextStyle(color: Colors.white, fontSize: 12),
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

class _WeeklyForecast extends StatelessWidget {
  final List<WeatherForecast> forecast;
  const _WeeklyForecast({required this.forecast});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: forecast.map((f) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                child: Column(
                  children: [
                    Text(
                      f.day,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: FarmTheme.textLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(f.icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 6),
                    Text(
                      '${f.high.toInt()}°',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    Text(
                      '${f.low.toInt()}°',
                      style: const TextStyle(fontSize: 11, color: FarmTheme.textLight),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _FarmingAlerts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final alerts = [
      {
        'icon': '🌧️',
        'title': 'Rain Expected Wed–Thu',
        'body': 'Hold off on fertilizer application. Ideal time to transplant rice seedlings.',
        'color': FarmTheme.skyBlue,
        'severity': 'Info',
      },
      {
        'icon': '☀️',
        'title': 'High UV Days Sat–Sun',
        'body': 'Cover newly transplanted seedlings. Avoid pesticide spraying during peak heat.',
        'color': FarmTheme.accentAmber,
        'severity': 'Caution',
      },
      {
        'icon': '🌬️',
        'title': 'Moderate Wind Advisory',
        'body': 'Secure tall crops and trellises. Avoid aerial spraying operations.',
        'color': FarmTheme.softGreen,
        'severity': 'Advisory',
      },
    ];

    return Column(
      children: alerts.map((a) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: (a['color'] as Color).withAlpha((0.08 * 255).round()),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: (a['color'] as Color).withAlpha((0.25 * 255).round())),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(a['icon'] as String, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            a['title'] as String,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ),
                        TagChip(label: a['severity'] as String, color: a['color'] as Color),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      a['body'] as String,
                      style: const TextStyle(fontSize: 12, color: FarmTheme.textMedium, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _PlantingCalendar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final windows = [
      {'crop': '🌾 Rice', 'window': 'Apr 20–26', 'status': 'Optimal', 'color': FarmTheme.primaryGreen},
      {'crop': '🌽 Corn', 'window': 'May 1–10', 'status': 'Good', 'color': FarmTheme.lightGreen},
      {'crop': '🍅 Tomato', 'window': 'Apr 25–30', 'status': 'Fair', 'color': FarmTheme.accentAmber},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: windows.map((w) {
            return ListTile(
              title: Text(w['crop'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text('Best window: ${w['window']}', style: const TextStyle(fontSize: 12)),
              trailing: TagChip(
                label: w['status'] as String,
                color: w['color'] as Color,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
