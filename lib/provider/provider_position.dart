import 'package:carwashapp/service/items/location_info.dart';
import 'package:carwashapp/users/userstate.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../api/api.dart';
import '../layout/def_style.dart';
import '../utils/dialogs.dart';
import '../utils/geo_util.dart';

class ProviderPosition extends StatefulWidget {
  const ProviderPosition({super.key});

  @override
  State<ProviderPosition> createState() => _ProviderPosition();
}

class _ProviderPosition extends State<ProviderPosition> {
  late UserState _userState;
  late WebViewController _mapController;
  LocationInfo? _locationInfo;

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _userState = Provider.of<UserState>(context, listen: false);

    return Scaffold(
        appBar: AppBar(
          title: Text("접수 기준위치 지정",
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.indigo)),
          centerTitle: true,
        ),
        body: SafeArea(
            child: Container(
                color: Colors.transparent,
                child: Column(children: [
                  FutureBuilder<LocationInfo?>(
                      future: _getLocation(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data != null) {
                            _locationInfo = snapshot.data;
                            // return kakaoMap(setState);
                            return Container();
                          } else {
                            return const Text("좌표 확인 오류");
                          }
                        } else if (snapshot.hasError) {
                          return Text(snapshot.error.toString());
                        } else {
                          return const SizedBox(
                            height: 400,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                      }),
                  const SizedBox(
                    height: 20,
                  ),
                  _locationInfo?.address != null
                      ? Center(
                          child: Text(
                            "주소 : ${_locationInfo?.address}",
                            style: DefStyle.textLibody,
                          ),
                        )
                      : const SizedBox(
                          height: 20,
                        ),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    DefStyle.okBtn("확인", () async {
                      if (_locationInfo != null) {
                        CwDialogs.modalLoading(context, "등록 처리중");
                        await Api().dio.post(Api.providerPosition, data: {
                          "lat": _locationInfo!.lat!,
                          "lng": _locationInfo!.lng!
                        }).then((response) {
                          if (response.statusCode == 200) {
                            if (response.data["message"] == "Success") {
                              Navigator.pop(context);
                            }
                          }
                          //print(value);
                        }).catchError((onError) {
                          Navigator.pop(context);
                        });
                        if (mounted) {
                          Navigator.pop(context);
                        }
                        // }else if(_orderProvider.checkCarInfo() && _orderProvider.resDateTime != null) {
                        //   Navigator.pop(context);
                        //   Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (context) => const ServiceExtra(),
                        //     ),
                        //   );
                        // }else{
                        //   Navigator.pop(context);
                        // }
                      }
                    }),
                    const SizedBox(
                      width: 10,
                    ),
                    DefStyle.grayBtn("취소", () {
                      Navigator.pop(context);
                    })
                  ])
                ]))));
  }

  Future<LocationInfo?> _getLocation() async {
    try {
      return await Api().dio.get(Api.providerPosition).then((response) async {
        final Map<String, dynamic> body = response.data;
        if (response.statusCode == 200 && response.data != null) {
          LocationInfo? locationInfo;
          if (response.data['data'] != null) {
            locationInfo = LocationInfo.fromJson(response.data['data']);
          } else {
            Position? position = await GeoUtil.determinePosition();
            locationInfo =
                LocationInfo(lat: position.latitude, lng: position.longitude);
          }
          if (locationInfo.lat != null) {
            //  return await KakaoRestApi().address(locationInfo.lat!, locationInfo.lng!);
          } else {
            if (mounted) {
              CwDialogs.alert(context, "서버통신중 오류가 발생 했습니다.", () {
                Navigator.pop(context);
              });
            }
          }
        }
        return null;
      });
      //
    } on PermissionDeniedException catch (e) {
      debugPrint(e.toString());
      CwDialogs.alert(context, "위치정보 확인 권한을 허용해주셔야 합니다.", () {
        Navigator.pop(context);
      });
    } on LocationServiceDisabledException catch (e) {
      debugPrint(e.toString());
      CwDialogs.alert(context, "위치정보를 활성화 후 다시 시도해주세요.", () {
        Navigator.pop(context);
      });
    } on Exception catch (e) {
      debugPrint(e.toString());
      CwDialogs.alert(context, "서버통신중 오류가 발생 했습니다..", () {
        Navigator.pop(context);
      });
    }
    return null;
  }

// Widget kakaoMapView(StateSetter locState) {
//   Size size = MediaQuery.of(context).size;
//   return Scaffold(body: kakaoMap(onMapCreated: (())));
// }
}
