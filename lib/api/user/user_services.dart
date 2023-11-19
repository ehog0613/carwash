import 'dart:core';

import 'package:carwashapp/api/user/carwash_user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:geolocator/geolocator.dart';

import '../api.dart';
import '../service/model/login_platform.dart';
import '../token_repository.dart';

class UserService {
  static UserService? _instance;

  factory UserService() => _instance ??= UserService._();

  UserService._();

  Future<dynamic> login(String userId, String userPswd, String fcmToken,
      [Position? pos]) async {
    dynamic _data = {
      "userId": userId,
      "userPswd": userPswd,
      "fcmToken": fcmToken,
      "lat": (pos != null) ? pos.latitude : null,
      "lng": (pos != null) ? pos.longitude : null
    };

    // todo : 프로바이더 분리시 호출 주소 변경 처리
    return await Api()
        .dio
        .post(Api.loginUrl, data: _data)
        .then((response) async {
      final Map<String, dynamic> body = response.data;
      if (kDebugMode) {
        print("$body");
      } // 로그 분석 목적

      if (body['statusCode'] == 200) {
        if (body['data'] != null) {
          return body['data'];
        } else {
          throw UnauthorizedException(body['message']);
        }
      } else {
        throw UnauthorizedException("로그인 처리중 오류가 발생했습니다.");
      }
    }).catchError((onError) {
      if (onError.runtimeType == UnauthorizedException) {
        throw onError;
      }
      if (kDebugMode) {
        print("Login Error : $onError");
      }
      if (onError.response.data != null &&
          onError.response.data["data"] != null) {
        throw UnauthorizedException(onError.response.data["data"]);
      } else {
        //throw UnauthorizedException(onError.error);
        throw UnauthorizedException("로그인 처리중 오류가 발생했습니다.");
      }
      //throw UnauthorizedException("로그인 처리중 오류가 발생했습니다.");
    });
  }

  Future<dynamic> loginSns(
      LoginPlatform loginType, String token, String fcmToken,
      [Position? pos]) async {
    dynamic rdata = {
      "token": token,
      "fcmToken": fcmToken,
      "lat": (pos != null) ? pos.latitude : null,
      "lng": (pos != null) ? pos.longitude : null
    };
    late String loginUrl;
    switch (loginType) {
      case LoginPlatform.kakao:
        loginUrl = Api.kakaoLogin;
        break;
      case LoginPlatform.naver:
        loginUrl = Api.naverLogin;
        break;
      default:
        throw UnauthorizedException("알수 없는 로그인 요청 입니다.");
    }
    return await Api().dio.post(loginUrl, data: rdata).then((response) async {
      final Map<String, dynamic> body = response.data;
      if (body['statusCode'] == 200) {
        if (body['data'] != null) {
          return body['data'];
        } else {
          throw UnauthorizedException(body['message']);
        }
      } else {
        throw UnauthorizedException("로그인 처리중 오류가 발생했습니다.");
      }
    }).catchError((onError) {
      if (onError.runtimeType == UnauthorizedException) {
        throw onError;
      }
      if (kDebugMode) {
        print("Login Error : $onError");
      }
      if (onError.response.data != null &&
          onError.response.data["data"] != null) {
        throw UnauthorizedException(onError.response.data["data"]);
      } else {
        throw UnauthorizedException("로그인 처리중 오류가 발생했습니다.");
      }
    });
  }

  Future<dynamic> logOut() async {
    try {
      await SessionManager().destroy();
      await TokenRepository().cleanAllTokens();
      return true;
    } on Exception {
      // todo 중복 관련 확인 필요
      throw Exception("로그아웃 실패");
    }
  }

  Future<dynamic> join(Map<String, dynamic> joindata) async {
    await Api().dio.post(Api.joinUrl, data: joindata).then((response) {
      final Map<String, dynamic> body = response.data;
      if (kDebugMode) {
        print("$body");
      } // 로
      if (response.statusCode == 200) {
        Map<String, dynamic> user = body['data'];
        return user;
      } else {
        throw JoinFailException("가입 실패");
      }
    }).catchError((error) {
      if (kDebugMode) {
        print(error);
      }
      if (error.response.data != null &&
          error.response.data["message"] != null) {
        throw JoinFailException(error.response.data["message"]);
      } else {
        throw JoinFailException("처리중 오류가 발생 했습니다.\n잠시후 다시 시도해주세요.");
      }
      //throw DuplicationIdException("이미 등록된 ID 값 입니다.");
    });
  }

  Future<dynamic> myOrder(Map<String, dynamic> reqData) async {
    // todo : pageing 파라메터 처리  및 저장 관련 처리
    var sessionManager = SessionManager();
    CarwashUser user = CarwashUser.fromJson(await sessionManager.get("user"));
    String url = Api.myOrderListUrl;
    if (user.userType == "PROVIDER") {
      url = Api.providerOrderListUrl;
    }

    final response = await Api().dio.post(url, data: reqData);
    final Map<String, dynamic> body = response.data;
    if (kDebugMode) {
      print("$body");
    } // 로
    if (response.statusCode == 200) {
      Map<String, dynamic> result = body['data'];
      return result;
    }
  }
}

class UnauthorizedException implements Exception {
  String cause;

  UnauthorizedException(this.cause);
}

class JoinFailException implements Exception {
  String cause;

  JoinFailException(this.cause);
}

class DuplicationIdException implements Exception {
  String cause;

  DuplicationIdException(this.cause);
}
