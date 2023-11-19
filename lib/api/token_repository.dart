import 'package:flutter_secure_storage/flutter_secure_storage.dart' as secstorage;
import 'package:jwt_decoder/jwt_decoder.dart';

class TokenRepository{
  static const String prefix = "Bearer ";
  static const storage = secstorage.FlutterSecureStorage();

  TokenRepository._internal();

  static final _singleton = TokenRepository._internal();

  factory TokenRepository() => _singleton;

  Future<String?> getAccessToken() async{
    return await storage.read(key: 'ACCESS_TOKEN');
  }

  Duration getTokenRemainingTime(String token){
    Duration remain = Duration.zero;
    DateTime expirationDate = JwtDecoder.getExpirationDate(token);
    remain = expirationDate.difference(DateTime.now());
    return remain;
  }

  Future<String?> getRefreshToken() async{
    return await storage.read(key: 'REFRESH_TOKEN');
  }

  Future<void> persistAccessToken(String accessToken,String refreshToekn) async{
    if(accessToken.startsWith(prefix)){
      accessToken = accessToken.substring(prefix.length);
    }
    if(refreshToekn.startsWith(prefix)){
      refreshToekn = refreshToekn.substring(prefix.length);
    }

    await storage.write(key: 'ACCESS_TOKEN', value: accessToken);
    await storage.write(key: 'REFRESH_TOKEN', value: refreshToekn);
  }

  Future<void> cleanAllTokens()async {
    await storage.delete(key: 'ACCESS_TOKEN');
    await storage.delete(key: 'REFRESH_TOKEN');
  }
}