import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyRate {
  final String currency;
  final int valueInIrr;

  CurrencyRate({required this.currency, required this.valueInIrr});

  factory CurrencyRate.fromJson(Map<String, dynamic> json) {
    return CurrencyRate(
      currency: json['currency'],
      valueInIrr: json['value_in_irr'],
    );
  }
}

Future<CurrencyRate> fetchCurrencyRate(String currency) async {
  final response = await http.get(Uri.parse('http://localhost:3000/rate/$currency'));

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    return CurrencyRate.fromJson(jsonResponse);
  } else {
    throw Exception('خطا در دریافت اطلاعات');
  }
}

