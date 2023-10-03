import 'package:koan/models/common/api_response.dart';

class KoanCount {
  ApiResponse apiResponse;
  List<Data>? data;

  KoanCount({
    required this.apiResponse,
    this.data,
  });

  factory KoanCount.fromJson(Map<String, dynamic> json) {
    return KoanCount(
      apiResponse: ApiResponse.fromJson(json),
      data: json['data'] != null
          ? (json['data'] is List
                  ? (json['data'] as List).map((i) => Data.fromJson(i)).toList()
                  : [Data.fromJson(json['data'])])
              .cast<Data>()
          : null,
      // error needs to be done
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
  int count;

  Data({
    required this.count,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      count: json['count'],
    );
  }
}
