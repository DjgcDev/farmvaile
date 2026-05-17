import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';
import '../widgets/common_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmTheme.backgroundGrey,
      appBar: AppBar(title: const Text('My Farm Profile')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const CircleAvatar(
                        radius: 48,
                        backgroundColor: Color.fromRGBO(255, 255, 255, 0.2),
                        child: Text('👨‍🌾', style: TextStyle(fontSize: 48)),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: FarmTheme.accentAmber,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.edit, color: Colors.white, size: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  FutureBuilder<UserProfile?>(
                    future: FirebaseService.profileForCurrentUser(),
                    builder: (context, snapshot) {
                      final defaultName = FirebaseAuth.instance.currentUser?.email?.split('@').first ?? 'Farmer';
                      final authName = FirebaseAuth.instance.currentUser?.displayName;
                      final name = snapshot.connectionState == ConnectionState.waiting
                          ? 'Loading...'
                          : snapshot.data?.displayName ?? authName ?? defaultName;
                      return Text(
                        name,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '📍 General Trias, Cavite, Philippines',
                    style: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.85), fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _ProfileChip('🌾 Rice Farmer'),
                      _ProfileChip('🌽 Corn Grower'),
                      _ProfileChip('5.5 ha Farm'),
                    ],
                  ),
                ],
              ),
            ),

            // Stats
            const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(child: StatCard(label: 'Crops Tracked', value: '4', icon: '🌿', color: FarmTheme.primaryGreen)),
                  SizedBox(width: 10),
                  Expanded(child: StatCard(label: 'Farm Area', value: '5.5 ha', icon: '🗺️', color: FarmTheme.skyBlue)),
                  SizedBox(width: 10),
                  Expanded(child: StatCard(label: 'Seasons', value: '12', icon: '🏆', color: FarmTheme.accentAmber)),
                ],
              ),
            ),

            // Farm Details
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Farm Details'),
                  const SizedBox(height: 12),
                  Card(
                    child: Column(
                      children: [
                        _DetailRow('📍', 'Region', 'Region IV-A (CALABARZON)'),
                        _DetailRow('🌱', 'Soil Type', 'Sandy-Loam'),
                        _DetailRow('💧', 'Water Source', 'Irrigation + Rainfed'),
                        _DetailRow('🌾', 'Primary Crop', 'Sitaw (String Beans)'),
                        _DetailRow('🌽', 'Secondary Crop', 'Ampalaya / Eggplant'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const SectionHeader(title: 'Notifications'),
                  const SizedBox(height: 12),
                  const Card(
                    child: Column(
                      children: [
                        _SwitchRow('🌤️ Weather Alerts', true),
                        _SwitchRow('📈 Market Price Updates', true),
                        _SwitchRow('🌱 Planting Reminders', true),
                        _SwitchRow('🐛 Pest & Disease Alerts', false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const SectionHeader(title: 'App Settings'),
                  const SizedBox(height: 12),
                  Card(
                    child: Column(
                      children: [
                        _MenuRow(Icons.language, 'Language', 'Filipino / English'),
                        _MenuRow(Icons.notifications_none, 'Notification Settings', ''),
                        _MenuRow(Icons.help_outline, 'Help & FAQ', ''),
                        _MenuRow(Icons.info_outline, 'About FarmvAIle', 'v1.0.0'),
                        _MenuRow(
                          Icons.logout,
                          'Sign Out',
                          '',
                          onTap: () async {
                            try {
                              await FirebaseService.signOut();
                            } catch (error) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Sign out failed: $error')),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _ProfileChip(String label) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: const Color.fromRGBO(255, 255, 255, 0.2),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.3)),
    ),
    child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
  );
}

Widget _DetailRow(String icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: FarmTheme.textLight, fontSize: 13)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    ),
  );
}

class _SwitchRow extends StatefulWidget {
  final String label;
  final bool initial;
  const _SwitchRow(this.label, this.initial);

  @override
  State<_SwitchRow> createState() => _SwitchRowState();
}

class _SwitchRowState extends State<_SwitchRow> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(widget.label, style: const TextStyle(fontSize: 13)),
      value: _value,
      activeThumbColor: FarmTheme.primaryGreen,
      onChanged: (v) => setState(() => _value = v),
    );
  }
}

Widget _MenuRow(IconData icon, String label, String value, {void Function()? onTap}) {
  return ListTile(
    leading: Icon(icon, color: FarmTheme.primaryGreen, size: 22),
    title: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (value.isNotEmpty)
          Text(value, style: const TextStyle(fontSize: 12, color: FarmTheme.textLight)),
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right, size: 18, color: FarmTheme.textLight),
      ],
    ),
    onTap: onTap,
  );
}
