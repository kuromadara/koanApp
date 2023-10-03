import 'package:koan/models/common/api_response.dart';

class Koan {
  ApiResponse apiResponse;
  List<Data>? data;

  Koan({
    required this.apiResponse,
    this.data,
  });

  factory Koan.fromJson(Map<String, dynamic> json) {
    return Koan(
      apiResponse: ApiResponse.fromJson(json),
      data: json['data'] != null
          ? (json['data'] is List
                  ? (json['data'] as List).map((i) => Data.fromJson(i)).toList()
                  : [Data.fromJson(json['data'])])
              .cast<Data>()
          : null,
      // errors: json['errors'] != null
      //     ? (json['errors'] is List
      //         ? (json['errors'] as List).map((i) => Errors.fromJson(i)).toList()
      //         : [Errors.fromJson(json['errors'])])
      //     : null,
    );
  }

  List<Data>? get datas => data;
}

class Data {
  int id;
  String title;
  String koan;

  Data({
    required this.id,
    required this.title,
    required this.koan,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['id'],
      title: json['title'],
      koan: json['koan'],
    );
  }
}

class KoanPost {
  String id;

  KoanPost({required this.id});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}
