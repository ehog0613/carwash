import 'package:flutter/foundation.dart';

import '../api.dart';
import 'model/car.dart';
import 'model/code_model.dart';

class CodeServices {
  static CodeServices? _instance;

  factory CodeServices() => _instance ??= CodeServices._();

  CodeServices._();

  Future<List<Code>> getVendors() async {
    List<Code> vendors = List.empty(growable: true);
    try {
      final response = await Api().dio.post(
          //Api.carCodesUrl, data: {"cd": "VENDOR"});
          Api.vendorListUrl,
          data: {});

      Map<String, dynamic> body = response.data;
      if (response.statusCode == 200 && body["data"] != null) {
        var list = body['data']['child'];

        list.forEach((key, element) {
          Code code = Code.fromJson(element as Map<String, dynamic>);
          vendors.add(code);
        });
        vendors.sort((a, b) => a.cdSeq.compareTo(b.cdSeq));
        //vendors = list.map((i) => Code.fromJson(i)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return vendors;
  }

  Future<Map<String, List<Car>>> getCarList() async {
    Map<String, List<Car>> carList = {};
    try {
      final response = await Api().dio.post(Api.carListUrl, data: {});

      Map<String, dynamic> body = response.data;
      if (response.statusCode == 200 && body["data"] != null) {
        (body['data'] as Map).forEach((key, value) {
          carList[key] = (value as List).map((i) => Car.fromJson(i)).toList();
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return carList;
  }
}
