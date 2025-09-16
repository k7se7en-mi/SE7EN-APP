import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as ll;

class AddressesPage extends StatelessWidget {
  const AddressesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final u = FirebaseAuth.instance.currentUser!;
    final col = FirebaseFirestore.instance
        .collection('users')
        .doc(u.uid)
        .collection('addresses')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text('العناوين')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const _AddAddressDialog(),
        ),
        child: const Icon(Icons.add_location_alt),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _LocationPickerCard(),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: col.snapshots(),
              builder: (_, s) {
                if (s.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = s.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('لا توجد عناوين بعد'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final m = docs[i].data();
                    return Card(
                      child: ListTile(
                        title: Text('${m['label'] ?? 'عنوان'} - ${m['city'] ?? ''}'),
                        subtitle: Text([
                          m['district'],
                          m['street'],
                          m['building']
                        ]
                            .where((e) => e != null && e.toString().isNotEmpty)
                            .join('، ')),
                        trailing: Switch(
                          value: (m['isDefault'] ?? false) as bool,
                          onChanged: (v) async {
                            final batch = FirebaseFirestore.instance.batch();
                            for (final d in docs) {
                              batch.update(d.reference, {
                                'isDefault': d.id == docs[i].id ? v : false
                              });
                            }
                            await batch.commit();
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AddAddressDialog extends StatefulWidget {
  const _AddAddressDialog();

  @override
  State<_AddAddressDialog> createState() => _AddAddressDialogState();
}

class _AddAddressDialogState extends State<_AddAddressDialog> {
  final _label = TextEditingController(text: 'البيت');
  final _city = TextEditingController();
  final _district = TextEditingController();
  final _street = TextEditingController();
  final _building = TextEditingController();
  final _postal = TextEditingController();

  @override
  void dispose() { _label.dispose(); _city.dispose(); _district.dispose(); _street.dispose(); _building.dispose(); _postal.dispose(); super.dispose(); }

  Future<void> _add() async {
    final u = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance.collection('users').doc(u.uid).collection('addresses').add({
      'label': _label.text.trim(),
      'city': _city.text.trim(),
      'district': _district.text.trim(),
      'street': _street.text.trim(),
      'building': _building.text.trim(),
      'postalCode': _postal.text.trim(),
      'isDefault': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة عنوان'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(controller: _label, decoration: const InputDecoration(labelText: 'التسمية')),
            TextField(controller: _city, decoration: const InputDecoration(labelText: 'المدينة')),
            TextField(controller: _district, decoration: const InputDecoration(labelText: 'الحي')),
            TextField(controller: _street, decoration: const InputDecoration(labelText: 'الشارع')),
            TextField(controller: _building, decoration: const InputDecoration(labelText: 'رقم المبنى')),
            TextField(controller: _postal, decoration: const InputDecoration(labelText: 'الرمز البريدي')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('إلغاء')),
        FilledButton(onPressed: _add, child: const Text('حفظ')),
      ],
    );
  }
}

/// بطاقة خريطة سريعة في صفحة العناوين لالتقاط موقع المستخدم وحفظه
class _LocationPickerCard extends StatefulWidget {
  const _LocationPickerCard();

  @override
  State<_LocationPickerCard> createState() => _LocationPickerCardState();
}

class _LocationPickerCardState extends State<_LocationPickerCard> {
  final _mapController = MapController();
  ll.LatLng? _current;
  ll.LatLng? _picked;
  bool _loading = true;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _permissionDenied = true;
          _loading = false;
        });
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _permissionDenied = true;
          _loading = false;
        });
        return;
      }
      final p = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _current = ll.LatLng(p.latitude, p.longitude);
        _picked = _current;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر الحصول على الموقع: $e')),
        );
      }
    }
  }

  Future<void> _savePicked() async {
    final pos = _picked ?? _current;
    if (pos == null) return;

    final labelController = TextEditingController(text: 'موقعي');
    final confirm = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسمية الموقع'),
        content: TextField(
          controller: labelController,
          decoration: const InputDecoration(labelText: 'التسمية'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, labelController.text.trim()),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (confirm == null || confirm.isEmpty) return;

    final u = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(u.uid)
        .collection('addresses')
        .add({
      'label': confirm,
      'city': '',
      'district': '',
      'street': '',
      'building': '',
      'postalCode': '',
      'geo': GeoPoint(pos.latitude, pos.longitude),
      'isDefault': false,
      'createdAt': FieldValue.serverTimestamp(),
      'fromMap': true,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الموقع ضمن العناوين')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _permissionDenied
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'الرجاء منح صلاحية الموقع لالتقاط موقعك من الخريطة',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _initLocation,
                          icon: const Icon(Icons.my_location),
                          label: const Text('إعادة المحاولة'),
                        )
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter:
                              _current ?? const ll.LatLng(24.7136, 46.6753), // Riyadh fall-back
                          initialZoom: 15,
                          onTap: (_, point) => setState(() => _picked = point),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.se7en.app',
                          ),
                          if (_picked != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _picked!,
                                  width: 40,
                                  height: 40,
                                  alignment: Alignment.topCenter,
                                  child: const Icon(
                                    Icons.location_pin,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Column(
                          children: [
                            Material(
                              color: Colors.white,
                              shape: const CircleBorder(),
                              child: IconButton(
                                tooltip: 'موقعي الحالي',
                                icon: const Icon(Icons.my_location),
                                onPressed: () async {
                                  await _initLocation();
                                  if (_current != null) {
                                    _mapController.move(_current!, 16);
                                    setState(() => _picked = _current);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: FilledButton.icon(
                          onPressed: _savePicked,
                          icon: const Icon(Icons.save_alt),
                          label: const Text('حفظ هذا الموقع ضمن العناوين'),
                        ),
                      )
                    ],
                  ),
      ),
    );
  }
}
