import 'dart:io';

import 'package:carwashapp/api/service/model/products.dart';
import 'package:carwashapp/service/items/car_item_info.dart';
import 'package:carwashapp/service/items/location_info.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../api/service/model/rest_order.dart';
import '../api/service/model/rest_order_item.dart';

class ServiceOrder extends ChangeNotifier {
  Products? _service;
  CarItem? _carinfo;
  DateTime? resDateTime;
  LocationInfo? location;
  int _totalPrice = 0;
  int extraPrice = 0;
  String? vendorType;
  String? vendor;
  String? model;
  String? carNo;
  int? carSeq;
  final List<Products> _extra = List.empty(growable: true);

  ServiceOrder({Products? serviceItem}) : _service = serviceItem;

  Map<String, dynamic> toJson() {
    solvPrice();
    // DateFormat dateFormat = DateFormat("yyyyMMddHHmmss");
    String orderId = Platform.isAndroid ? 'A' : 'O';
    // orderId+=dateFormat.format(DateTime.now())+Random().nextInt(200).toString();
    List<RestOrderItem> restextra = List.empty(growable: true);
    return RestOrder(
      orderId: orderId,
      carInfo: _carinfo!,
      location: location!,
      resDate: resDateTime!,
      totalPrice: _totalPrice,
      title: _service!.title,
      service: RestOrderItem(
        seq: 0,
        svcSeq: _service!.seq,
        title: _service!.title,
        price: _service!.price,
      ),
      extra: (_extra.isNotEmpty)
          ? _extra
              .map((i) => RestOrderItem(
                  seq: 0, svcSeq: i.seq, title: i.title, price: i.price))
              .toList()
          : null,
    ).toJson();
  }

  void init(Products service) {
    clear();
    _service = service;
    _totalPrice = _service?.price ?? 0;
  }

  void clear() {
    _service = null;
    _extra.clear();
    //location = null;
    //resDateTime = null;
    _totalPrice = 0;
    /* _carinfo = null;
      vendorType = null;
      vendor = null;
      model = null;
      carNo = null;
      carSeq = 0;*/
  }

  Products? getService() {
    return _service;
  }

  CarItem? getCarinfo() {
    return _carinfo;
  }

  void carInfo(CarItem carItem) {
    _carinfo = carItem;
    carSeq = _carinfo!.carSeq;
    vendorType = _carinfo!.vendorType;
    vendor = _carinfo!.vendor;
    model = _carinfo!.model;
    carNo = _carinfo!.carNo;
    notifyListeners();
  }

  bool checkCarInfo() {
    return _carinfo != null && _carinfo?.carSeq != null;
  }

  String carInfoTxt() {
    return "${_carinfo?.vendor} ${_carinfo?.model} ${_carinfo?.carNo}";
  }

  String serviceName() {
    String serviceNm = "";
    if (_service != null) {
      serviceNm = _service!.title;
    }
    return serviceNm;
  }

  String dateTime() {
    String resDateTimestr = "";
    if (resDateTime != null) {
      resDateTimestr =
          DateFormat('yy/MM/dd(E) HH:mm', 'ko_KR').format(resDateTime!);
    }
    return resDateTimestr;
  }

  String address() {
    String address = "";
    if (location?.roadaddr != null) {
      address = location!.address!;
    } else if (location?.address != null) {
      address = location!.address!;
    } else {}
    return address;
  }

  void setResTime(int hour, int minute) {
    if (resDateTime != null) {
      resDateTime = DateTime(resDateTime!.year, resDateTime!.month,
          resDateTime!.day, hour, minute);
    }
  }

  void setNewCarinfo() {
    if (carSeq != null &&
        vendorType != null &&
        vendor != null &&
        vendor != "제조사" &&
        model != null &&
        model != "모델" &&
        carNo != null &&
        carNo!.isNotEmpty) {
      carInfo(CarItem(
          carSeq: carSeq!,
          vendorType: vendorType!,
          vendor: vendor!,
          model: model!,
          carNo: carNo!));
    } else {
      _carinfo = null;
    }
  }

  int price() {
    return _totalPrice;
  }

  int servicePrice() {
    return _service!.price;
  }

  List<Products> extra() {
    return _extra;
  }

  void addExtra(Products extra) {
    _extra.add(extra);
  }

  void removeExtrs(Products extra) {
    _extra.remove(extra);
  }

  bool findExtra(Products extra) {
    for (Products e in _extra) {
      if (e.seq == extra.seq) return true;
    }
    return false;
  }

  void solvPrice() {
    _totalPrice = 0;
    extraPrice = 0;
    _totalPrice += _service!.price;
    if (_extra.isNotEmpty) {
      for (var element in _extra) {
        extraPrice += element.price;
      }
    }
    _totalPrice += extraPrice;
  }

  @override
  String toString() {
    // TODO: implement toString
    return serviceName();
  }
}
