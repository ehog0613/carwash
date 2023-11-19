import 'package:carwashapp/api/kakao/rest_call.dart';
import 'package:carwashapp/service/items/location_info.dart';
import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

class AddressProvider extends ChangeNotifier {
  LocationInfo? _locationInfo;

  LocationInfo? get locationInfo => _locationInfo;

  void setLocationInfo(LocationInfo? locationInfo) {
    _locationInfo = locationInfo;
    notifyListeners();
  }

  Future<void> loadData(LatLng latLng) async {
    _locationInfo =
        await KakaoRestApi().address(latLng.latitude, latLng.longitude);
    notifyListeners();
  }
}
