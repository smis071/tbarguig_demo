// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = 'users_locations';

  /// تحديث / إنشاء وثيقة المستخدم مع الاحداثيات و avatarUrl و name
  Future<void> updateMyLocation({
    required String userId,
    required String name,
    required String avatarUrl,
    required double latitude,
    required double longitude,
  }) async {
    final docRef = _firestore.collection(collection).doc(userId);
    await docRef.set({
      'userId': userId,
      'name': name,
      'avatarUrl': avatarUrl,
      'latitude': latitude,
      'longitude': longitude,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// استمع لتحديثات المجموعة كاملة - لحفظها على الخريطة
  Stream<List<Map<String, dynamic>>> streamAllUsersLocations() {
    return _firestore.collection(collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'userId': data['userId'],
          'name': data['name'],
          'avatarUrl': data['avatarUrl'],
          'latitude': (data['latitude'] as num).toDouble(),
          'longitude': (data['longitude'] as num).toDouble(),
          'updatedAt': data['updatedAt'],
        };
      }).toList();
    });
  }

  /// (اختياري) حذف موقع المستخدم عند الخروج
  Future<void> removeMyLocation(String userId) async {
    await _firestore.collection(collection).doc(userId).delete();
  }
}
