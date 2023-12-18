import 'package:flutter/material.dart';

class CwValidators {
  static String? userId(String? userId) {
    if (userId == null || userId.length < 8) {
      return "사용자 ID는 8 이상 입니다.";
    }
    return null;
  }

  static String? userEmail(String? value) {
    if (value == null) {
      return '이메일을 입력하세요.';
    } else {
      if (!RegExp(
              r"^[a-zA-Z0-9.a-zA-Z0-9\.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(value)) {
        return '잘못된 이메일 형식입니다.';
      } else {
        return null;
      }
    }
  }

  static String? userTel(String? value) {
    if (value == null) {
      return "휴대전화 번호를 입력해주세요.";
    }
    if (!RegExp(r'^010-?([0-9]{4})-?([0-9]{4})$').hasMatch(value)) {
      return "휴대전화 번호 형식이 올바르지 않습니다.";
    }
    return null;
  }

  static String? userPswd(String? userPswd) {
    if (userPswd == null || userPswd.length < 4) {
      return "비밀번호는 4자 이상 입력하셔야 합니다.";
    }
    return null;
  }

  static String? userPswdConf(String? confpswd, String? pswd) {
    if (userPswd(confpswd) != null || pswd != confpswd) {
      return "비밀번호 확인이 일치하지 않습니다.";
    }
    return null;
  }

  static String? checkLen(int len, String? val) {
    if (len > 0) {
      if (val == null) {
        return "값을 입력해주세요.";
      } else if (val.length < len) {
        debugPrint('val : $val, len : $len');
        return "최소 $len자 이상 입력하셔야 합니다.";
      }
    }
    return null;
  }
}
