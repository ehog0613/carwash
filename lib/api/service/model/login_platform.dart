enum LoginPlatform{
  carwash,
  kakao,
  naver;

  factory LoginPlatform.fromString(String platform){
    // ignore: unrelated_type_equality_checks
    return LoginPlatform.values.firstWhere((element) => element == platform);
  }
}