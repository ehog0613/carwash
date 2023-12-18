import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'token_repository.dart';

class Api {
  static final _singleton = Api._internal();
  static const _isLocal = false;

  static BaseOptions baseOption = BaseOptions(
    baseUrl: _isLocal
        ? "http://192.168.0.14:8080/api"
        : "http://119.201.211.211:8080/api",
    receiveTimeout: const Duration(seconds: 15), // 15 seconds
    connectTimeout: const Duration(seconds: 2),
    sendTimeout: const Duration(seconds: 5),
  );

  static String loginUrl = "/auth/login";
  static String providerLoginUrl = "/auth/providerlogin";
  static String joinUrl = "/auth/join";
  static String kakaoLogin = "/auth/kakao/login";
  static String naverLogin = "/auth/naver/login";

  static String userInfonUrl = "/auth/info";
  static String refreshTokenUrl = "/auth/refresh";
  static String productListUrl = "/services/list";
  static String vendorListUrl = "/services/vendorList";
  static String carListUrl = "/services/carList";
  static String requestOrderUrl = "/customer/order";
  static String myOrderListUrl = "/customer/order/list";
  static String providerOrderListUrl = "/provider/order/list";
  static String providerOrderFindUrl = "/provider/order/find";
  static String providerOrderResv = "/provider/order/reserve";
  static String providerOrderStatus = "/provider/order/status";
  static String providerOrderPhoto = "/provider/order/upload";
  static String providerPosition = "/provider/position";
  static String findId = "/auth/search/userid";

  final dio = Dio(baseOption);
  final Dio _tokenDio = Dio(BaseOptions(
    baseUrl: _isLocal
        ? "http://192.168.0.14:8080/api"
        : "http://119.201.211.211:8080/api",
  ));
  String? _accessToken;
  String? _refreshToken;

  Api._internal() {
    dio.interceptors.add(LogInterceptor());
    dio.interceptors
        .add(QueuedInterceptorsWrapper(onRequest: (options, handler) async {
      if (!options.path.startsWith("/init/") &&
          (options.path == Api.userInfonUrl ||
              !options.path.startsWith("/auth/"))) {
        if (_accessToken == null || _accessToken!.isNotEmpty) {
          Map<String, String> myHeader = await getMyheader();
          if (myHeader["Authorization"]!.isNotEmpty) {
            _accessToken = myHeader["Authorization"];
            _refreshToken = myHeader["Refresh"];
          }
        }
        if (_accessToken != null && _accessToken!.isNotEmpty) {
          if (TokenRepository().getTokenRemainingTime(_accessToken!).inMinutes <
                  1 &&
              _refreshToken != null &&
              _refreshToken!.isNotEmpty &&
              TokenRepository()
                      .getTokenRemainingTime(_refreshToken!)
                      .inMinutes >
                  1) {
            // token 재발급
            await TokenRepository().cleanAllTokens();
            _tokenDio.options.headers["Authorization"] = _accessToken;
            _tokenDio.options.headers["Refresh"] = _refreshToken;
            await _tokenDio.post(Api.refreshTokenUrl).then((d) async {
              if (d.statusCode == 200 &&
                  d.headers["Authorization"]?[0] != null) {
                await setToken(d.headers["Authorization"]?[0] ?? "",
                    d.headers["Refresh"]?[0] ?? "");
              }
            }).catchError((error, stackTracd) async {
              handler.reject(error, true);
              return;
            });
          }
        }

        if (_accessToken != null && _accessToken!.isNotEmpty) {
          options.headers["Authorization"] = _accessToken;
          // options.headers["Refresh"] = _refreshToken;
          if (kDebugMode) {
            print("request Token : ${options.headers["Authorization"]?[0]}");
          }
        } else if (options.path == Api.userInfonUrl) {
          return handler.reject(DioError(
              requestOptions: options,
              type: DioErrorType.cancel,
              error: "notoken"));
        }
      }
      return handler.next(options);
    }, onResponse: (response, handler) async {
      if (response.statusCode == 200) {
        if (response.headers["Authorization"]?[0] != null &&
            response.headers["Authorization"]![0] != _accessToken) {
          await setToken(response.headers["Authorization"]?[0] ?? "",
              response.headers["Refresh"]?[0] ?? "");
        }
      }
      return handler.next(response);
    }, onError: (error, handler) async {
      if (kDebugMode) {
        print("On Error : $error");
      }
      if (error.response?.statusCode == 401 &&
          _refreshToken != null &&
          _refreshToken!.isNotEmpty) {
        _tokenDio.options.headers["Authorization"] = _accessToken;
        _tokenDio.options.headers["Refresh"] = _refreshToken;
        await _tokenDio.post(Api.refreshTokenUrl, data: {}).then((d) async {
          if (kDebugMode) {
            print(
                "Refresh : ${d.statusCode} + Token : ${d.headers["Authorization"]?[0]}  ${d.headers["Refresh"]?[0]}");
          }
          if (d.statusCode == 200 && d.headers["Authorization"]?[0] != null) {
            await setToken(d.headers["Authorization"]?[0] ?? "",
                d.headers["Refresh"]?[0] ?? "");
          }
        }).then((value) async {
          final clonedRequest = await dio.request(error.requestOptions.path,
              options: Options(
                  method: error.requestOptions.method,
                  headers: error.requestOptions.headers),
              data: error.requestOptions.data,
              queryParameters: error.requestOptions.queryParameters);
          // dio.fetch(dio.options).then(
          //       (r) => handler.resolve(r),
          //   onError: (e) {
          //     handler.reject(e);
          //   },
          // );
          return handler.resolve(clonedRequest);
        }).catchError((error, stackTracd) async {
          handler.reject(error);
          return;
        });
      }

      /*if (error.response?.statusCode == 401 || error.response?.statusCode == 403) {
          var options = error.response!.requestOptions;
          if(options.headers['Authorization'] != null && options.headers['Authorization'].isNotEmpty && _accessToken != options.headers['Authorization']) {
            options.headers['Authorization'] = _accessToken;
            //repeat
            dio.fetch(options).then(
                  (r) => handler.resolve(r),
              onError: (e) {
                handler.reject(e);
              },
            );
            return;
          }
          var refreshToken = await TokenRepository().getRefreshToken();
          if (refreshToken != null && refreshToken.isNotEmpty && TokenRepository().getTokenRemainingTime(refreshToken).inMinutes > 1) {
            _tokenDio.options.headers["Refresh"] = "Bearer $refreshToken";
            await _tokenDio.post(Api.refreshTokenUrl,data: {}).then((d) async {
              if (kDebugMode) {
                print("On Error : ${d.statusCode} + Token : ${d.headers["Authorization"]?[0]}  \r\n ${d.headers["Refresh"]?[0]}");
              }
              if(d.statusCode == 200 && d.headers["Authorization"]?[0] != null){
                _accessToken = d.headers["Authorization"]![0];
                refreshToken = d.headers["Refresh"]?[0]??"";
                if (kDebugMode) {
                  print("retoken set on error");
                }
                await TokenRepository().persistAccessToken(_accessToken!, refreshToken!);
                options.headers['Authorization'] = _accessToken;
              }
            }).then((value){
              dio.fetch(options).then(
                    (r) => handler.resolve(r),
                onError: (e) {
                  handler.reject(e);
                },
              );
            }).catchError((error,stackTracd) async {
              await TokenRepository().cleanAllTokens();
              //handler.reject((error));
              handler.next(error);
            });
            return;
          }
        }*/
      return handler.next(error);
    }));
  }

  Future<Map<String, String>> getMyheader() async {
    Map<String, String> myheaders = <String, String>{};
    var accessToken = await TokenRepository().getAccessToken() ?? "";
    var refreshToken = await TokenRepository().getRefreshToken() ?? "";
    if (accessToken.isNotEmpty && refreshToken.isNotEmpty) {
      if (!accessToken.startsWith(TokenRepository.prefix)) {
        accessToken = TokenRepository.prefix + accessToken;
      }
      if (!refreshToken.startsWith(TokenRepository.prefix)) {
        refreshToken = TokenRepository.prefix + refreshToken;
      }
    }
    myheaders["Authorization"] = accessToken;
    myheaders["Refresh"] = refreshToken;
    return myheaders;
  }

  Future<void> setToken(String? auth, String? refresh) async {
    if (auth!.isNotEmpty) {
      _accessToken = auth;
    } else {
      _accessToken = "";
    }

    if (refresh!.isNotEmpty) {
      _refreshToken = refresh;
    } else {
      _refreshToken = "";
    }
    if (kDebugMode) {
      print("setToken :  $_accessToken \r\n $_refreshToken");
    }
    await TokenRepository().persistAccessToken(_accessToken!, _refreshToken!);
  }

  factory Api() => _singleton;
}
