import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';

class FirebaseService {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Future<UserProfile?> profileForCurrentUser() async {
    final user = auth.currentUser;
    if (user == null) return null;
    final snapshot = await firestore.collection('users').doc(user.uid).get();
    final data = snapshot.data();
    if (data == null) return null;
    return UserProfile.fromMap(user.uid, data);
  }

  static Future<void> ensureUserProfile(User user, {String? firstName, String? lastName}) async {
    final userRef = firestore.collection('users').doc(user.uid);
    final snapshot = await userRef.get();
    final existing = snapshot.data();

    final profileData = {
      'email': user.email ?? '',
      'role': existing?['role'] as String? ?? 'farmer',
      'createdAt': existing?['createdAt'] ?? FieldValue.serverTimestamp(),
    };

    if (firstName != null && firstName.isNotEmpty) {
      profileData['firstName'] = firstName;
    }
    if (lastName != null && lastName.isNotEmpty) {
      profileData['lastName'] = lastName;
    }

    if (!snapshot.exists) {
      await userRef.set(profileData);
      return;
    }

    final updates = <String, Object?>{};
    if (firstName != null && firstName.isNotEmpty && (existing?['firstName'] == null || existing?['firstName'] == '')) {
      updates['firstName'] = firstName;
    }
    if (lastName != null && lastName.isNotEmpty && (existing?['lastName'] == null || existing?['lastName'] == '')) {
      updates['lastName'] = lastName;
    }
    if (updates.isNotEmpty) {
      await userRef.update(updates);
    }
  }

  static Future<void> signUp(String email, String password, {required String firstName, required String lastName}) async {
    final result = await auth.createUserWithEmailAndPassword(email: email, password: password);
    final displayName = '$firstName $lastName'.trim();
    if (result.user != null && displayName.isNotEmpty) {
      await result.user!.updateDisplayName(displayName);
    }
    await ensureUserProfile(result.user!, firstName: firstName, lastName: lastName);
  }

  static Future<void> signIn(String email, String password) async {
    final result = await auth.signInWithEmailAndPassword(email: email, password: password);
    await ensureUserProfile(result.user!);
  }

  static Future<void> signOut() async {
    await auth.signOut();
  }

  static Stream<List<FarmerFarm>> farmsForUser(String uid) {
    return firestore
        .collection('users')
        .doc(uid)
        .collection('farms')
        .orderBy('plantedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FarmerFarm.fromMap(doc.id, doc.data()))
            .toList());
  }

  static Future<int> farmCount(String uid) async {
    final snapshot = await firestore.collection('users').doc(uid).collection('farms').get();
    return snapshot.size;
  }

  static Future<void> createFarm(String uid, Crop crop) async {
    final farms = await firestore.collection('users').doc(uid).collection('farms').get();
    if (farms.size >= 2) {
      throw Exception('You can only create up to two farms.');
    }

    final existing = await firestore
        .collection('users')
        .doc(uid)
        .collection('farms')
        .where('cropName', isEqualTo: crop.name)
        .get();
    if (existing.docs.isNotEmpty) {
      throw Exception('You already have a farm with ${crop.name}.');
    }

    final harvestDays = SampleData.cropHarvestDays[crop.name] ?? 90;
    await firestore.collection('users').doc(uid).collection('farms').add({
      'name': '${crop.name} Field',
      'cropName': crop.name,
      'cropIcon': crop.icon,
      'status': 'Planted',
      'progress': 0.0,
      'plantedAt': FieldValue.serverTimestamp(),
      'harvestDays': harvestDays,
    });
  }

  static Future<void> removeFarm(String uid, String farmId) async {
    await firestore
        .collection('users')
        .doc(uid)
        .collection('farms')
        .doc(farmId)
        .delete();
  }

  static Future<void> advanceFarmProgress(String uid, String farmId, double delta) async {
    final ref = firestore.collection('users').doc(uid).collection('farms').doc(farmId);
    final snapshot = await ref.get();
    if (!snapshot.exists) return;
    final current = (snapshot.data()?['progress'] as num?)?.toDouble() ?? 0.0;
    final next = (current + delta).clamp(0.0, 1.0);
    await ref.update({
      'progress': next,
      'status': next >= 1.0 ? 'Harvest Ready' : 'Growing',
    });
  }

  // ── Farm Grid (5×5) ────────────────────────────────────────────────────────

  static Stream<FarmGrid> farmGridStream(String uid, String farmId) {
    return firestore
        .collection('users')
        .doc(uid)
        .collection('farmGrids')
        .doc(farmId)
        .snapshots()
        .map((snap) => snap.exists
            ? FarmGrid.fromMap(snap.id, snap.data()!)
            : FarmGrid.empty(farmId));
  }

  static Future<void> ensureFarmGrids(String uid) async {
    final col = firestore.collection('users').doc(uid).collection('farmGrids');
    for (final entry in {'farm1': 'Farm 1', 'farm2': 'Farm 2'}.entries) {
      final doc = await col.doc(entry.key).get();
      if (!doc.exists) {
        await col.doc(entry.key).set({'name': entry.value, 'plots': {}});
      }
    }
  }

  static Future<void> plantCrop(
      String uid, String farmId, int row, int col, Crop crop) async {
    final harvestDays = SampleData.cropHarvestDays[crop.name] ?? 90;
    final ref = firestore
        .collection('users')
        .doc(uid)
        .collection('farmGrids')
        .doc(farmId);
    final plotData = {
      'cropName': crop.name,
      'cropIcon': crop.icon,
      'plantedAt': FieldValue.serverTimestamp(),
      'harvestDays': harvestDays,
      'lastWatered': FieldValue.serverTimestamp(),
    };
    try {
      // Fast path: document already exists
      await ref.update({'plots.${row}_$col': plotData});
    } catch (_) {
      // Document missing (ensureFarmGrids not yet complete) — create it now
      await ref.set({
        'name': farmId == 'farm1' ? 'Farm 1' : 'Farm 2',
        'plots': {'${row}_$col': plotData},
      }, SetOptions(merge: true));
    }
  }

  static Future<void> waterPlot(
      String uid, String farmId, int row, int col) async {
    await firestore
        .collection('users')
        .doc(uid)
        .collection('farmGrids')
        .doc(farmId)
        .update({
      'plots.${row}_$col.lastWatered': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> removePlot(
      String uid, String farmId, int row, int col) async {
    await firestore
        .collection('users')
        .doc(uid)
        .collection('farmGrids')
        .doc(farmId)
        .update({
      'plots.${row}_$col': FieldValue.delete(),
    });
  }

  static Future<int> farmerCount() async {
    final snapshot = await firestore.collection('users').get();
    return snapshot.docs
        .where((d) => (d.data()['role'] as String? ?? 'farmer') != 'admin')
        .length;
  }

  static Future<int> totalFarmCount() async {
    final snapshot = await firestore.collectionGroup('farms').get();
    return snapshot.size;
  }

  static Stream<List<MarketPrice>> marketPrices() {
    return firestore.collection('market_prices').snapshots().map((snapshot) => snapshot.docs
        .map((doc) => MarketPrice.fromMap(doc.id, doc.data()))
        .toList());
  }

  static Future<void> updateMarketPrice(
      String docId, double newPrice, double previousPrice) async {
    final trend = newPrice > previousPrice
        ? 'up'
        : newPrice < previousPrice
            ? 'down'
            : 'stable';
    await firestore.collection('market_prices').doc(docId).update({
      'previousPrice': previousPrice,
      'currentPrice': newPrice,
      'trend': trend,
    });
  }
}
