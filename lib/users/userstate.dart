import 'dart:core';

import 'package:carwashapp/api/user/carwash_user.dart';
import 'package:carwashapp/api/user/user_services.dart';
import 'package:carwashapp/service/items/car_item_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';

import '../api/service/model/login_platform.dart';
import '../service/items/location_info.dart';

class UserState extends ChangeNotifier{
  final storage = const FlutterSecureStorage();
  static bool _isLogin = false;
  static LoginPlatform _loginPlatform = LoginPlatform.carwash;
  late CarwashUser _user;
  String _fcmToken = "";
  Position? _position;
  final List<CarItem> _cars = List.empty(growable: true);
  final List<LocationInfo> _locations = List.empty(growable: true);
  void signIn(CarwashUser user,LoginPlatform loginPlatform) async{
    if(user.userId.isNotEmpty && user.userType.isNotEmpty) {
      _user = user;
      _isLogin = true;
      _loginPlatform = loginPlatform;
      await storage.write(key: "loginPlatform",value: _loginPlatform.toString());
      notifyListeners();
    }
  }

  void setLoginPlatform(LoginPlatform loginPlatform){
    _loginPlatform = loginPlatform;
  }

  LoginPlatform getLoginPlatform(){
    return _loginPlatform;
  }

  bool loginPlatfromIs(LoginPlatform loginPlatform){
    return _loginPlatform == loginPlatform;
  }

  void setPosition(Position position){
    _position = position;
  }

  Position? getPosition(){
    return _position;
  }

  void setFcmToken(String fcmToken){
    _fcmToken = fcmToken;
  }

  String getFcmToken(){
    return _fcmToken;
  }

  void signOut() async{
    _user =CarwashUser(userId: "", userName: "Guest", userTel: "", userEmail: "", userType: "");
    _isLogin = false;
    _cars.clear();
    _locations.clear();
    switch(_loginPlatform){
      case LoginPlatform.naver:
        break;
      case LoginPlatform.kakao:
        break;
      case LoginPlatform.carwash:
      default:
        break;
    }
    _loginPlatform = LoginPlatform.carwash;
    await storage.write(key: "loginPlatform",value: _loginPlatform.toString());
    notifyListeners();
  }


  bool isLogin(){
    return _isLogin;
  }

  String id(){
    if(_isLogin) {
      return _user.userId;
    }
    return "";
  }

  String name(){
    if(_isLogin) {
      return _user.userName;
    }
    return "";
  }

  String email(){
    if(_isLogin) {
      return _user.userEmail;
    }
    return "";
  }

  int countCar(){
    return _cars.length;
  }
  void addCar(CarItem car){
    _cars.add(car);
  }

  List<CarItem> allCars(){
    return _cars;
  }

  CarItem? getCar([int index=0]){
    if(_cars.isNotEmpty && index < _cars.length) {
        return _cars[index];
    }
    return null;
  }

  int countLocation(){
    return _locations.length;
  }
  void addLocation(LocationInfo location){
    _locations.add(location);
  }

  List<LocationInfo> allLocations(){
    return _locations;
  }

  LocationInfo? getLocation([int index=0]){
    if(_locations.isNotEmpty && index < _locations.length) {
      return _locations[index];
    }
    return null;
  }

  bool provider(){
    return _isLogin && _user.userType == "PROVIDER";
  }
}