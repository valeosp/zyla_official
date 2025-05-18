import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/onboarding_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/period_entry.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Guarda todo el onboarding, incluyendo periodLength y lastPeriodDate
  Future<void> saveOnboardingData(String uid, OnboardingData data) async {
    final userDoc = _db.collection('users').doc(uid);
    await userDoc.set(data.toMap(), SetOptions(merge: true));
  }

  /// Obtiene datos crudos de usuario (incluye onboarding y profile)
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
    return snap.exists ? snap.data() : null;
  }

  /// Actualiza campos de perfil (p.ej. photoUrl)
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  /// Guarda o actualiza una entrada de periodo
  Future<void> savePeriodEntry(PeriodEntry entry) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final docRef = _db
        .collection('users')
        .doc(uid)
        .collection('period_entries')
        .doc(entry.date.toIso8601String());
    await docRef.set(entry.toMap());
  }

  /// Recupera las entradas de periodo en un Stream
  Stream<List<PeriodEntry>> streamPeriodEntries() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _db
        .collection('users')
        .doc(uid)
        .collection('period_entries')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs
                  .map((doc) => PeriodEntry.fromMap(doc.id, doc.data()))
                  .toList(),
        );
  }

  /// Elimina una entrada de periodo
  Future<void> deletePeriodEntry(String entryId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await _db
        .collection('users')
        .doc(uid)
        .collection('period_entries')
        .doc(entryId)
        .delete();
  }
}
