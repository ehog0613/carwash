import 'package:carwashapp/api/user/carwash_user.dart';

class LoginResult{
  final String status;
  final String message;
  final CarwashUser? user;

  LoginResult({required this.status, required this.message, required this.user});

  factory LoginResult.fromJson(Map<String,dynamic> parsedJson){
    return LoginResult(status: parsedJson['statusCode'], message: parsedJson['message'], user: parsedJson['data'] == null ? null : CarwashUser.fromJson(parsedJson['data']));
  }
}