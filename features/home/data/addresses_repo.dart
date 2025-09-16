import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserAddress {
  final String id;
  final String name;
  final String phone;
  final String city;
  final String details;
  final bool isDefault;

  UserAddress({
    required this.id,
    required this.name,
    required this.phone,
    required this.city,
    required this.details,
    required this.isDefault,
  });

  factory UserAddress.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    return UserAddress(
      id: d.id,
      name: (m['name'] ?? '').toString(),
      phone: (m['phone'] ?? '').toString(),
      city: (m['city'] ?? '').toString(),
      details: (m['details'] ?? '').toString(),
      isDefault: (m['isDefault'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'phone': phone,
    'city': city,
    'details': details,
    'isDefault': isDefault,
    'updatedAt': FieldValue.serverTimestamp(),
    'createdAt': FieldValue.serverTimestamp(),
  };
}

class AddressesRepo {
  final _db = FirebaseFirestore.instance;
  String get _uid => FirebaseAuth.instance.currentUser!.uid;
  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users').doc(_uid).collection('addresses');

  Stream<List<UserAddress>> streamAll() {
    return _col.orderBy('isDefault', descending: true)
              .orderBy('createdAt', descending: true)
              .snapshots()
              .map((s) => s.docs.map(UserAddress.fromDoc).toList());
  }

  Future<List<UserAddress>> listOnce() async {
    final s = await _col.orderBy('isDefault', descending: true)
                        .orderBy('createdAt', descending: true)
                        .get();
    return s.docs.map(UserAddress.fromDoc).toList();
  }

  Future<UserAddress?> getDefault() async {
    final s = await _col.where('isDefault', isEqualTo: true).limit(1).get();
    if (s.docs.isEmpty) return null;
    return UserAddress.fromDoc(s.docs.first);
  }

  Future<String> addOrUpdate({
    String? id,
    required String name,
    required String phone,
    required String city,
    required String details,
    bool isDefault = false,
  }) async {
    final data = {
      'name': name.trim(),
      'phone': phone.trim(),
      'city': city.trim(),
      'details': details.trim(),
      'isDefault': isDefault,
      'updatedAt': FieldValue.serverTimestamp(),
      if (id == null) 'createdAt': FieldValue.serverTimestamp(),
    };

    if (isDefault) {
      // أزل العلامة عن البقية
      final batch = _db.batch();
      final others = await _col.where('isDefault', isEqualTo: true).get();
      for (final d in others.docs) {
        batch.update(d.reference, {'isDefault': false});
      }
      final ref = id == null ? _col.doc() : _col.doc(id);
      batch.set(ref, data, SetOptions(merge: true));
      await batch.commit();
      return ref.id;
    } else {
      if (id == null) {
        final ref = await _col.add(data);
        return ref.id;
      } else {
        await _col.doc(id).set(data, SetOptions(merge: true));
        return id;
      }
    }
  }

  Future<void> setDefault(String id) async {
    final batch = _db.batch();
    final docs = await _col.get();
    for (final d in docs.docs) {
      batch.update(d.reference, {'isDefault': d.id == id});
    }
    await batch.commit();
  }

  Future<void> delete(String id) => _col.doc(id).delete();
}