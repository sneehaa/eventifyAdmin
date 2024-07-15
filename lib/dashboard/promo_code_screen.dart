import 'dart:convert';

import 'package:eventify_admin/core/flutter_secure_storage/flutter_secure_Storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PromoCodesScreen extends StatefulWidget {
  const PromoCodesScreen({super.key});

  @override
  _PromoCodesScreenState createState() => _PromoCodesScreenState();
}

class _PromoCodesScreenState extends State<PromoCodesScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _expirationDateController =
      TextEditingController();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  List<PromoCode> _promoCodes = [];
  final SecureStorage secureStorage = SecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchPromoCodes();
  }

  Future<void> _fetchPromoCodes() async {
    try {
      String? token = await secureStorage.readToken();
      if (token == null) {
        throw Exception('Token not available');
      }

      final url = Uri.parse('http://192.168.68.109:5500/api/admin/promo-codes');
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      };
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] &&
            jsonData['promoCodes'] != null &&
            jsonData['promoCodes'] is List) {
          final List<dynamic> data = jsonData['promoCodes'];
          setState(() {
            _promoCodes = data.map((item) => PromoCode.fromJson(item)).toList();
          });
        } else {
          setState(() {
            _promoCodes = [];
          });
          throw Exception('No promo codes available');
        }
      } else {
        throw Exception('Failed to fetch promo codes');
      }
    } catch (e) {
      print('Error fetching promo codes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch promo codes')),
      );
    }
  }

  Future<void> _addPromoCode() async {
    final url =
        Uri.parse('http://192.168.68.109:5500/api/admin/promo-codes/create');

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'code': _codeController.text,
          'discount': double.parse(_discountController.text),
          'expirationDate': _expirationDateController.text,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Promo code added successfully')),
        );
        _clearInputs();
        _fetchPromoCodes();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add promo code')),
        );
        print('Failed to add promo code');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Failed to add promo code. Check server connectivity.')),
      );
      print('Error adding promo code: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _expirationDateController.text = _dateFormat.format(picked);
      });
    }
  }

  void _clearInputs() {
    _codeController.clear();
    _discountController.clear();
    _expirationDateController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Promo Codes')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Promo Code'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _discountController,
              decoration: const InputDecoration(labelText: 'Discount (%)'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextField(
                  controller: _expirationDateController,
                  decoration:
                      const InputDecoration(labelText: 'Expiration Date'),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _addPromoCode,
              style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.all<Color>(const Color(0xFFFFC806)),
              ),
              child: const Text('Add Promo Code'),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: _promoCodes.length,
                itemBuilder: (context, index) {
                  final promoCode = _promoCodes[index];
                  return ListTile(
                    title: Text(promoCode.code),
                    subtitle: Text('${promoCode.discount}% off'),
                    trailing:
                        Text(_dateFormat.format(promoCode.expirationDate)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PromoCode {
  final String code;
  final double discount;
  final DateTime expirationDate;

  PromoCode({
    required this.code,
    required this.discount,
    required this.expirationDate,
  });

  factory PromoCode.fromJson(Map<String, dynamic> json) {
    return PromoCode(
      code: json['code'],
      discount: json['discount'].toDouble(),
      expirationDate: DateTime.parse(json['expirationDate']),
    );
  }
}
