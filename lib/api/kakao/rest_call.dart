import 'package:carwashapp/service/items/location_info.dart';
import 'package:carwashapp/utils/constant.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class KakaoRestApi {
  static final _singleton = KakaoRestApi._internal();

  static BaseOptions baseOption = BaseOptions(
    baseUrl: "https://dapi.kakao.com/v2",
    receiveTimeout: const Duration(seconds: 15), // 15 seconds
    connectTimeout: const Duration(seconds: 3),
    sendTimeout: const Duration(seconds: 5),
  );

  static String regioncodeUrl = "/local/geo/coord2regioncode.json";
  static String addressUrl = "/local/geo/coord2address.json";

  final dio = Dio(baseOption);

  KakaoRestApi._internal() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers["Authorization"] = "KakaoAK ${KakaoKey.REST_API_KEY}";
        return handler.next(options);
      },
    ));
  }

  Future<Map<String, dynamic>?> regioncode(double lat, double lng) async {
    // Map<String,dynamic> result ={"meta":null,"documents":null};
    try {
      final response =
          await dio.get(regioncodeUrl, queryParameters: {"x": lng, "y": lat});
      return response.data;
    } catch (e) {
      // todo :오류 처리
      if (kDebugMode) {
        print(e);
      }
    }
    return null;
  }

  Future<LocationInfo?> address(double lat, double lng) async {
    try {
      final response = await dio.get("$addressUrl?x=$lng&y=$lat");
      if (response.statusCode == 200 && response.data != null) {
        if (response.data["meta"]["total_count"] as int > 0) {
          return LocationInfo(
              lat: lat,
              lng: lng,
              roadaddr: response.data["documents"][0]['road_address']
                      ?["address_name"] ??
                  "",
              address: response.data["documents"][0]['address']
                      ?["address_name"] ??
                  "",
              detail: "");
        }
      }
    } catch (e) {
      //tody : 오류 처리
      if (kDebugMode) {
        print(e);
      }
    }
    return null;
  }

  factory KakaoRestApi() => _singleton;
}
