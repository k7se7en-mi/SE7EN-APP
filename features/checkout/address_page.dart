import 'package:flutter/material.dart';
import '../../core/widgets/glass_container.dart';

class AddressData {
  final String name;
  final String phone;
  final String city;
  final String district;
  final String street;
  final String building;
  final String postalCode;

  AddressData({
    required this.name,
    required this.phone,
    required this.city,
    required this.district,
    required this.street,
    required this.building,
    required this.postalCode,
  });
}

class AddressPage extends StatefulWidget {
  final double subtotal;
  final double vat;
  final double codFee;
  final bool withCod;

  const AddressPage({
    super.key,
    required this.subtotal,
    required this.vat,
    required this.codFee,
    required this.withCod,
  });

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _city = TextEditingController();
  final _district = TextEditingController();
  final _street = TextEditingController();
  final _building = TextEditingController();
  final _postal = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _city.dispose();
    _district.dispose();
    _street.dispose();
    _building.dispose();
    _postal.dispose();
    super.dispose();
  }

  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'حقل مطلوب' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('العنوان')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassContainer(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _field('الاسم الكامل', _name),
                  _field('رقم الجوال', _phone, keyboard: TextInputType.phone),
                  _field('المدينة', _city),
                  _field('الحي', _district),
                  _field('الشارع', _street),
                  _field('المبنى/الشقة', _building),
                  _field('الرمز البريدي', _postal, keyboard: TextInputType.number),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('حفظ والانتقال إلى الدفع'),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final address = AddressData(
                            name: _name.text.trim(),
                            phone: _phone.text.trim(),
                            city: _city.text.trim(),
                            district: _district.text.trim(),
                            street: _street.text.trim(),
                            building: _building.text.trim(),
                            postalCode: _postal.text.trim(),
                          );

                          Navigator.of(context).pushNamed(
                            '/checkout',
                            arguments: {
                              'address': address,
                              'subtotal': widget.subtotal,
                              'vat': widget.vat,
                              'codFee': widget.codFee,
                              'withCod': widget.withCod,
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController c, {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: c,
        validator: _req,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
      ),
    );
  }
}