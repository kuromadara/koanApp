import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:koan/models/koan_get.dart';
import 'package:http/http.dart' as http;

class KoanService extends ChangeNotifier {
  KoanPost koanPost;
  late Future<KoanGet> koan;

  KoanService({required this.koanPost});

  Future<KoanGet> fetchKoan() async {
    var header = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final response = await http.post(
      Uri.parse(dotenv.env['BASE_URL']! + dotenv.env['KOAN']!),
      headers: header,
      body: jsonEncode(koanPost.toJson()),
    );
    if (response.statusCode == 200) {
      print(response.body);
      return KoanGet.fromJson(jsonDecode(response.body));
    } else {
      print(response.body);
      return KoanGet.fromJson(jsonDecode(response.body));
    }
  }
}
