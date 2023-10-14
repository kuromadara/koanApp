import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:koan/models/koan_get.dart';
import 'package:http/http.dart' as http;
import 'package:koan/models/koan_count.dart';

class KoanCountService extends ChangeNotifier {
  late Future<KoanCount> count;

  KoanCountService();

  Future<KoanCount> fetchCount() async {
    var header = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final response = await http.get(
      Uri.parse(dotenv.env['BASE_URL']! + dotenv.env['KOAN_COUNT']!),
      headers: header,
    );
    if (response.statusCode == 200) {
      print(response.body);
      return KoanCount.fromJson(jsonDecode(response.body));
    } else {
      print(response.body);
      return KoanCount.fromJson(jsonDecode(response.body));
    }
  }
}
