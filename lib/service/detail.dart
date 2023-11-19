import 'package:carwashapp/api/service/code_service.dart';
import 'package:carwashapp/api/service/model/products.dart';
import 'package:carwashapp/provider/provider_address.dart';
import 'package:carwashapp/service/extra.dart';
import 'package:carwashapp/service/service_order_info.dart';
import 'package:carwashapp/utils/dialogs.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:provider/provider.dart';
import 'package:time_range/time_range.dart';
import 'package:toast/toast.dart';

import '../api/kakao/rest_call.dart';
import '../api/service/model/car.dart';
import '../api/service/model/code_model.dart';
import '../layout/def_style.dart';
import '../utils/geo_util.dart';
import 'items/location_info.dart';

class ServiceDetail extends StatefulWidget {
  final Products _selService;

  const ServiceDetail(Products service, {Key? key})
      : _selService = service,
        super(key: key);

  @override
  State<StatefulWidget> createState() => _ServiceDetail();
}

class _ServiceDetail extends State<ServiceDetail> {
  var curr = NumberFormat.currency(locale: "ko_KR", symbol: "");
  late ServiceOrder _orderProvider;
  final CodeServices _vendorService = CodeServices();
  final TextEditingController _carNoCtrl = TextEditingController();
  final DatePickerController _dateController = DatePickerController();
  String _locationEditMode = "mapview"; // address, mapview

  TimeOfDay? _resTime;
  TimeOfDay _firstTime = const TimeOfDay(hour: 9, minute: 00);
  TimeOfDay _lastTime = const TimeOfDay(hour: 18, minute: 00);

  final List<Code> _vendorTypes = [Code(cdSeq: 0, cd: "구분", cdVal: "구분")];
  final List<Code> _vendors = [Code(cdSeq: 0, cd: "제조사", cdVal: "제조사")];
  final List<Car> _models = [
    Car(cdSeq: 0, carSeq: 0, prodNm: "모델", vendor: "없음", descMsg: "기본 선택자")
  ];
  late Map<String, List<Car>> _carLists;
  Code? _vendorItem;
  Car? _modelItem;

  LocationInfo? _locationInfo;

  //static const orange = Color(0xFFFE9A75);
  static const dark = Color(0xFF333A47);

  //static const double leftPadding = 50;

  late double _lat;
  late double _lng;

  //List<DateTime> _dateRange = List.empty(growable: true);
  DateTime _startDate = DateTime.now();
  late DateTime _curr;
  final _defaultTimeRange = TimeRangeResult(
    const TimeOfDay(hour: 9, minute: 00),
    const TimeOfDay(hour: 12, minute: 30),
  );
  TimeRangeResult? _timeRange;

  late KakaoMapController mapController;

  @override
  void initState() {
    _timeRange = _defaultTimeRange;
    super.initState();
    _curr = DateTime.now();
    //int drstart = 0;
    if (_curr.hour > 17) {
      //drstart = 1;
      _startDate.add(const Duration(days: 1));
    }
    /*
    for(int j=0;j<7;j++){
      _dateRange.add(DateTime.now().add(Duration(days: drstart+j)));
    }*/
    _syncDate();
  }

  void _syncDate() async {
    var vendorLists = await _vendorService.getVendors();
    if (vendorLists.isNotEmpty) {
      _vendorTypes.addAll(vendorLists);
    }
    _carLists = await _vendorService.getCarList();
    _initSelect("vendorType");
  }

  Future<Position?> _getLocation() async {
    try {
      Position? position = await GeoUtil.determinePosition();
      if (_orderProvider.location != null) {
        _lat = _orderProvider.location!.lat!;
        _lng = _orderProvider.location!.lng!;
      } else {
        _lat = position.latitude;
        _lng = position.longitude;
        _locationInfo = await KakaoRestApi().address(_lat, _lng);
      }
      return position;
    } on PermissionDeniedException {
      CwDialogs.exitAlert(context, "위치정보 확인 권한을 허용해주셔야 합니다.");
      setState(() {
        _locationEditMode = "mapview";
      });
    } on LocationServiceDisabledException {
      CwDialogs.exitAlert(context, "위치정보를 활성화 후 다시 시도해주세요.");
      setState(() {
        _locationEditMode = "mapview";
      });
    }
    return null;
  }

  @override
  void dispose() {
    _carNoCtrl.dispose();
    super.dispose();
  }

  // 차량 정보 정상 등록 여부 확인
  bool _checkOrderCarInfo() {
    return (_orderProvider.vendor != null &&
        _orderProvider.vendor!.isNotEmpty &&
        _orderProvider.model != null &&
        _orderProvider.model!.isNotEmpty &&
        _orderProvider.carNo != null &&
        _orderProvider.carNo!.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    _orderProvider = Provider.of<ServiceOrder>(context, listen: true);
    _orderProvider.init(widget._selService);

    Products item = widget._selService;
    _carNoCtrl.text = _orderProvider.carNo ?? "";
    if (_orderProvider.location == null) {
      _locationEditMode = "mapview";
    } else {
      _locationInfo = _orderProvider.location;
    }
    ToastContext().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("기본예약정보 입력",
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.indigo)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Image.asset(
                    item.img!,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  DefStyle.subTitle(_orderProvider.serviceName()),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 15, top: 10, right: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${curr.format(item.price)} ~",
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: DefStyle.importColor1)),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          // todo : 상세 정보 DB 연동 필요
                          "-작업내용 : 타이어, 휠, 외부",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          "차량 정보",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        _checkOrderCarInfo()
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _orderProvider.carInfoTxt(),
                                    style: DefStyle.textLiHead,
                                  ),
                                  DefStyle.grayBtn("변경", () => _carInfoSet())
                                ],
                              )
                            : Center(
                                child: DefStyle.okBtn(
                                  "차량 정보 등록",
                                  () => _carInfoSet(),
                                ),
                              ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          "일시 정보",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        _orderProvider.resDateTime != null
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _orderProvider.resDateTime
                                        .toString()
                                        .substring(0, 16),
                                    style: DefStyle.textLiHead,
                                  ),
                                  DefStyle.grayBtn("변경", () => _dateInfoSet())
                                ],
                              )
                            : Center(
                                child: DefStyle.okBtn(
                                    "예약 일시 등록", () => _dateInfoSet())),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          "위치 정보",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        _orderProvider.location != null
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _orderProvider.address(),
                                    style: DefStyle.textLiHead,
                                  ),
                                  DefStyle.grayBtn(
                                      "변경", () => _locationInfoSet())
                                ],
                              )
                            : Center(
                                child: DefStyle.okBtn(
                                    "예약 위치 등록", () => _locationInfoSet())),
                      ],
                    ),
                  ),
                  const Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.only(top: 40, left: 10, right: 10),
                          child: Text(""),
                        )
                      ])
                ]),
          ),
        ),
      ),
      bottomNavigationBar: Material(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(54, 104, 170, 1),
              padding: const EdgeInsets.all(20)),
          child: Text(
            "예약하기",
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.white),
          ),
          onPressed: () async {
            if (!_orderProvider.checkCarInfo()) {
              Toast.show('차량 정보를 입력해주세요.',
                  duration: Toast.lengthShort, gravity: Toast.center);
              await Future.delayed(const Duration(seconds: Toast.lengthShort));
              _carInfoSet();
            } else if (_orderProvider.resDateTime == null) {
              Toast.show('예약 일시를 선택해주세요.',
                  duration: Toast.lengthShort, gravity: Toast.center);
              await Future.delayed(const Duration(seconds: Toast.lengthShort));
              _dateInfoSet();
            } else if (_orderProvider.location == null) {
              Toast.show('장소를 지정해 주세요.',
                  duration: Toast.lengthShort, gravity: Toast.center);
              await Future.delayed(const Duration(seconds: Toast.lengthShort));
              _locationInfoSet();
            } else {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, "/service/extra");
            }
          },
        ),
      ),
    );
  }

  // 차량 정보 입력 창
  void _carInfoSet() async {
    return await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, carState) {
            return Dialog(
              child: Container(
                height: 350.0,
                color: Colors.transparent,
                //could change this to Color(0xFF737373),
                //so you don't have to change MaterialApp canvasColor
                child: ListView(children: [
                  Container(
                      color: Colors.black12,
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: const Column(
                        children: [
                          Text(
                            "차량선택",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 22),
                          ),
                          Text("세차서비스 요청 차량을 확인해 주세요.")
                        ],
                      )),
                  Builder(builder: (context) {
                    return _inputCarInfo();
                  }),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    DefStyle.okBtn("확인", () {
                      if (_vendorItem == null ||
                          _orderProvider.vendor == _vendors[0].cdVal) {
                        Toast.show('제조사를 선택해주세요.',
                            duration: Toast.lengthShort, gravity: Toast.center);
                      } else if (_modelItem == null ||
                          _orderProvider.model == _models[0].prodNm) {
                        Toast.show('모델을 선택해주세요.',
                            duration: Toast.lengthShort, gravity: Toast.center);
                      } else if (_carNoCtrl.text.isEmpty ||
                          _carNoCtrl.text.length < 7) {
                        Toast.show('차량번호를 입력해주세요.',
                            duration: Toast.lengthShort, gravity: Toast.center);
                      } else {
                        setState(() {
                          //_orderProvider.vendor = _vendorItem?.cdVal ?? "";
                          //_orderProvider.model = _modelItem?.prodNm ?? "";
                          _orderProvider.carNo = _carNoCtrl.text;
                          _orderProvider.setNewCarinfo();
                          Navigator.pop(context);
                          if (_orderProvider.resDateTime == null) {
                            _dateInfoSet();
                          }
                        });
                      }
                    }),
                    const SizedBox(
                      width: 10,
                    ),
                    DefStyle.grayBtn("취소", () {
                      Navigator.pop(context);
                    })
                  ]),
                ]),
              ),
            );
          });
        });
  }

  // 차량 정보 입력
  StatefulBuilder _inputCarInfo() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter carEditState) {
      if (kDebugMode) {
        print("rend carinput");
      }
      return Column(children: [
        DefStyle.liBottomLineWidget(
            "제조사",
            _vendorTypes.length < 2
                ? [const Text("----")]
                : [
                    DropdownButton<String?>(
                      value: _orderProvider.vendorType,
                      underline: Container(),
                      onChanged: (String? newValue) {
                        carEditState(() {
                          if (_orderProvider.vendorType != newValue) {
                            _orderProvider.vendorType = newValue!;
                            _initSelect("vendorType");
                          }
                        });
                      },
                      items: _vendorTypes
                          .map((e) => e.cdVal)
                          .toSet()
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    DropdownButton<String>(
                      value: _orderProvider.vendor,
                      underline: Container(),
                      items: _vendors
                          .map((e) => e.cdVal)
                          .toSet()
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e, style: DefStyle.textLibody),
                            ),
                          )
                          .toList(),
                      onChanged: (String? newValue) {
                        carEditState(() {
                          if (_orderProvider.vendor != newValue!) {
                            _orderProvider.vendor = newValue;
                            _initSelect("vendor");
                          }
                        });
                      },
                    ),
                    // DropdownButton<String?>(
                    //   value: _orderProvider.vendor,
                    //   underline: Container(),
                    //   onChanged: (String? newValue) {
                    //     carEditState(() {
                    //       if (_orderProvider.vendor != newValue!) {
                    //         _orderProvider.vendor = newValue;
                    //         _initSelect("vendor");
                    //       }
                    //     });
                    //   },
                    //   items: _vendors.map<DropdownMenuItem<String>>((code) {
                    //     return DropdownMenuItem(
                    //       value: code.cdVal,
                    //       child: Text(code.cdVal, style: DefStyle.textLibody),
                    //     );
                    //   }).toList(),
                    // )
                  ]),
        DefStyle.liBottomLineWidget(
            "모델",
            _vendorTypes.length < 2
                ? [const Text("----")]
                : [
                    DropdownButton<String?>(
                      value: _orderProvider.model,
                      underline: Container(),
                      onChanged: (String? newValue) {
                        carEditState(() {
                          if (_orderProvider.model != newValue) {
                            _orderProvider.model = newValue!;
                            _initSelect("model");
                          }
                        });
                      },
                      items: _models.map<DropdownMenuItem<String>>((value) {
                        return DropdownMenuItem(
                          value: value.prodNm,
                          child: Text(
                            value.prodNm,
                            style: DefStyle.textLibody,
                          ),
                        );
                      }).toList(),
                    ),
                  ]),
        DefStyle.liBottomLineWidget(
          "차량번호",
          _vendorTypes.length < 2
              ? [const Text("----")]
              : [
                  Flexible(
                    child: TextField(
                      controller: _carNoCtrl,
                    ),
                  )
                ],
        ),
        const SizedBox(
          height: 40,
        ),
      ]);
    });
  }

  // 차량 정보 변경 데이터 처리
  void _initSelect(String type) {
    switch (type) {
      case 'vendorType':
        if (_vendors.length > 1) {
          _vendors.removeRange(1, _vendors.length);
        }
        for (var code in _vendorTypes) {
          if (_orderProvider.vendorType == code.cdVal) {
            _vendorItem = code;
            break;
          }
        }
        if (_vendorItem != null) {
          if (_vendorItem!.child != null && _vendorItem!.child!.isNotEmpty) {
            _vendors.addAll(_vendorItem!.child!);
          }
        } else {
          _orderProvider.vendorType = _vendorTypes[0].cdVal;
        }
        continue vendorCase;
      vendorCase:
      case 'vendor':
        _vendorItem = null;
        if (_models.length > 1) {
          _models.removeRange(1, _models.length);
        }
        for (var code in _vendors) {
          if (_orderProvider.vendor == code.cdVal) {
            _vendorItem = code;
            break;
          }
        }
        if (_vendorItem == null) {
          _orderProvider.vendor = _vendors[0].cdVal;
        } else if (_carLists.containsKey(_vendorItem!.cd)) {
          List<Car>? cars = _carLists[_vendorItem!.cd];
          if (cars != null && cars.isNotEmpty) {
            _models.addAll(cars);
          }
        }
        continue modelCase;
      modelCase:
      case 'model':
        _modelItem = null;
        for (var car in _models) {
          if (car.prodNm == _orderProvider.model) {
            _modelItem = car;
            break;
          }
        }
        if (_modelItem == null) {
          _orderProvider.model = _models[0].prodNm;
          _orderProvider.carSeq = 0;
        } else {
          _orderProvider.carSeq = _modelItem!.carSeq;
        }
        break;
    }
  }

  void _dateInfoSet() {
    //_orderProvider.resDateTime = null;
    //_resTime = null;

    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (builder) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter dateState) {
            return Container(
              height: 330.0,
              color: Colors.transparent,
              child: ListView(children: [
                Container(
                  color: Colors.black12,
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: const Column(
                    children: [
                      Text(
                        "일시선택",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                      Text("요청 일시를 확인해 주세요.")
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                DatePicker(_startDate,
                    width: 60,
                    height: 90,
                    controller: _dateController,
                    daysCount: 7,
                    initialSelectedDate: _orderProvider.resDateTime,
                    selectionColor: DefStyle.importColor1,
                    selectedTextColor: Colors.white,
                    locale: 'ko_KR.UTF-8',
                    //activeDates: _dateRange,
                    onDateChange: (date) {
                  _orderProvider.resDateTime = date;
                  _resTime = null;
                  DateTime now = DateTime.now();
                  if (date.day == now.day) {
                    if (now.hour > 8) {
                      if (now.hour >= 17) {
                        _startDate =
                            DateTime.now().add(const Duration(days: 1));
                        dateState(() {
                          _firstTime = TimeOfDay(hour: 9, minute: 00);
                          _lastTime = TimeOfDay(hour: 18, minute: 00);
                        });
                      } else {
                        dateState(() {
                          if (now.minute > 30) {
                            _firstTime =
                                TimeOfDay(hour: now.hour + 1, minute: 30);
                          } else {
                            _firstTime =
                                TimeOfDay(hour: now.hour + 1, minute: 0);
                          }
                        });
                      }
                    }
                  }
                }),
                const SizedBox(
                  height: 30,
                ),
                TimeList(
                  firstTime: _firstTime,
                  lastTime: _lastTime,
                  initialTime: null,
                  timeStep: 30,
                  padding: 10,
                  onHourSelected: _startHourChanged,
                  borderColor: Colors.grey,
                  activeBorderColor: DefStyle.importColor1,
                  backgroundColor: Colors.white,
                  activeBackgroundColor: DefStyle.importColor1,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    color: dark,
                  ),
                  activeTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                DefStyle.okBtn("확인", () {
                  //_orderProvider.resDateTime!.compareTo(curr) < 0  : 오늘 이후 만 가능
                  if (_orderProvider.resDateTime == null) {
                    Toast.show("날짜를 선택해주세요.");
                  } else if (_resTime == null) {
                    Toast.show("시간을 선택해주세요.");
                  } else {
                    if (kDebugMode) {
                      print("선택 시간 : $_resTime");
                    }
                    DateTime selDateTime = DateTime(
                        _orderProvider.resDateTime!.year,
                        _orderProvider.resDateTime!.month,
                        _orderProvider.resDateTime!.day,
                        _resTime!.hour,
                        _resTime!.minute,
                        0);
                    if (DateTime.now()
                            .add(const Duration(minutes: 30))
                            .compareTo(selDateTime) >=
                        0) {
                      Toast.show("서비스 요청 불가 시간대 입니다.");
                    } else {
                      setState(() {
                        _orderProvider.resDateTime = selDateTime;
                      });
                      Navigator.pop(context);
                    }
                    if (_orderProvider.location == null) {
                      _locationInfoSet();
                    }
                  }
                })
              ]),
            );
          });
        });
  }

  void _startHourChanged(TimeOfDay hour) {
    _resTime = hour;
    // todo 오늘 시간 설정 가능하게 하는 부분 - first & end
    // _orderProvider.setResTime(hour.hour, hour.minute);
  }

  void _locationInfoSet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (builder) {
          debugPrint("_locationEditMode: $_locationEditMode");
          return StatefulBuilder(builder: (
            BuildContext context,
            StateSetter locState,
          ) {
            return ChangeNotifierProvider<AddressProvider>(
              create: (BuildContext context) => AddressProvider(),
              builder: (context, child) {
                return Container(
                  height: _locationEditMode == "address" ? 250.0 : 700,
                  color: Colors.transparent,
                  child: Center(
                    child: ListView(
                      children: [
                        Container(
                          color: Colors.black12,
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: const Column(
                            children: [
                              Text(
                                "서비스 장소 선택",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 24),
                              ),
                              Text("세차 서비스 예약 장소를 확인해 주세요.")
                            ],
                          ),
                        ),
                        _locationEditMode == 'address'
                            ? Column(children: [
                                DefStyle.liBottomLine(
                                    "예약장소", _orderProvider.address()),
                                DefStyle.liBottomLine(
                                    "상세입력", _orderProvider.address()),
                              ])
                            : FutureBuilder<Position?>(
                                future: _getLocation(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    if (snapshot.data != null) {
                                      return const ServiceMapView();
                                    } else {
                                      return const Text("좌표 확인 오류");
                                    }
                                  } else if (snapshot.hasError) {
                                    if (kDebugMode) {
                                      print(snapshot.data);
                                      // 에러메세지 ex) 사용자 정보를 확인할 수 없습니다.
                                      print(snapshot.error);
                                    } // null

                                    return Text(snapshot.error.toString());
                                  } else {
                                    return const SizedBox(
                                      height: 400,
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }
                                },
                              ),
                        const SizedBox(height: 16),
                        // _locationInfo?.address != null
                        //     ? Center(
                        //         child: Text(
                        //           "주소 : ${_locationInfo?.address}",
                        //           style: DefStyle.textLibody,
                        //         ),
                        //       )
                        //     : const SizedBox(height: 20),
                        context.watch<AddressProvider>().locationInfo != null
                            ? Center(
                                child: Text(
                                  "주소 : ${context.watch<AddressProvider>().locationInfo!.address}",
                                  style: DefStyle.textLibody,
                                ),
                              )
                            : const SizedBox(height: 20),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DefStyle.okBtn("확인", () {
                              if (context
                                      .read<AddressProvider>()
                                      .locationInfo !=
                                  null) {
                                Navigator.pop(context);
                                setState(() {
                                  _orderProvider.location = context
                                      .read<AddressProvider>()
                                      .locationInfo;
                                });
                              } else if (_orderProvider.checkCarInfo() &&
                                  _orderProvider.resDateTime != null) {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ServiceExtra(),
                                  ),
                                );
                              } else {
                                Navigator.pop(context);
                              }
                            }),
                            const SizedBox(width: 10),
                            DefStyle.grayBtn(
                              "취소",
                              () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          });
        });
  }
}

class ServiceMapView extends StatefulWidget {
  const ServiceMapView({
    super.key,
  });

  @override
  State<ServiceMapView> createState() => _ServiceMapViewState();
}

class _ServiceMapViewState extends State<ServiceMapView> {
  late Marker marker;
  late KakaoMapController mapController;
  late Position currentPosition;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    Position position = await GeoUtil.determinePosition();
    debugPrint("position: ${position.toString()}");
    setState(() {
      currentPosition = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    AddressProvider provider = context.read<AddressProvider>();
    return SizedBox(
      height: 250,
      child: KakaoMap(
        onMapCreated: ((controller) async {
          mapController = controller;

          LatLng latLng = await mapController.getCenter();
          LocationInfo? locationInfo =
              await KakaoRestApi().address(latLng.latitude, latLng.longitude);

          marker = Marker(
            markerId: "marker",
            latLng: latLng,
            width: 30,
            height: 44,
            offsetX: 15,
            offsetY: 44,
          );

          mapController.addMarker(markers: [marker]);
          provider.setLocationInfo(locationInfo);
        }),
        center: LatLng(
          currentPosition.latitude,
          currentPosition.longitude,
        ),
        onMapTap: ((latLng) async {
          marker.latLng = latLng;
          LocationInfo? locationInfo =
              await KakaoRestApi().address(latLng.latitude, latLng.longitude);

          mapController.clearMarker();
          mapController.addMarker(markers: [marker]);
          mapController.panTo(latLng);

          provider.setLocationInfo(locationInfo);
          setState(() {});
        }),
        currentLevel: 4,
      ),
    );
  }
}
