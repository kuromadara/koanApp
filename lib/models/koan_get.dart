import 'package:koan/models/common/api_response.dart';
import 'package:koan/models/common/koan.dart';

class KoanGet {
  ApiResponse apiResponse;
  List<Koan>? data;

  KoanGet({
    required this.apiResponse,
    this.data,
  });

  factory KoanGet.fromJson(Map<String, dynamic> json) {
    return KoanGet(
      apiResponse: ApiResponse.fromJson(json),
      data: json['data'] != null
          ? (json['data'] is List
                  ? (json['data'] as List).map((i) => Koan.fromJson(i)).toList()
                  : [Koan.fromJson(json['data'])])
              .cast<Koan>()
          : null,
      // errors: json['errors'] != null
      //     ? (json['errors'] is List
      //         ? (json['errors'] as List).map((i) => Errors.fromJson(i)).toList()
      //         : [Errors.fromJson(json['errors'])])
      //     : null,
    );
  }

  List<Koan>? get datas => data;
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
