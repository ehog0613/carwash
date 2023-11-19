
import 'package:carwashapp/api/service/model/resv_order_service.dart';

class ResvOrderItem{
  final int seq;
  final String orderId;
  final String carinfo;
  final String carNum;
  String? zipCode;
  final String addr;
  String? addrExt;
  final double gpsLat;
  final double gpsLng;
  final double? distance;
  final DateTime resDate;
  final int price;
  final String title;
  String? status;
  int? provider;
  String? providerId;
  final DateTime ordDate;
  DateTime? compDate;

  final ResvOrderService service;
  final List<ResvOrderService>? extra;
  final List<int>? photos;

  ResvOrderItem({
    required this.seq,
    required this.orderId,
    required this.carinfo,
    required this.carNum,
      this.zipCode,
    required this.addr,
      this.addrExt,
    required this.gpsLat,
    required this.gpsLng,
    this.distance,
    required this.resDate,
    required this.price,
    required this.title,
      this.status,
      this.provider,
    this.providerId,
    required this.ordDate,
      this.compDate,
    required this.service,
      this.extra,
  this.photos});

  factory ResvOrderItem.fromJson(Map<String,dynamic> json){
    return ResvOrderItem(
      seq: json['seq'],
      orderId: json['orderId'],
      carinfo: json['carinfo'],
      carNum: json['carNum'],
      zipCode: json['zipCode']??"",
      addr: json['addr'],
      addrExt: json['addrExt']??"",
      gpsLat: json['gpsLat'],
      gpsLng: json['gpsLng'],
      distance: json['distance'],
      resDate: DateTime.parse(json['resDate']!),
      price: json['price'],
      title:json['title'],
      status: json['status']??"",
      provider: json['provider']??0,
      providerId: json['providerId']??"",
      ordDate: DateTime.parse(json['ordDate']),
      compDate: json['compDate']!= null?DateTime.parse(json['compDate']):null,
      service: ResvOrderService.fromJson(json['service']),
      extra: json['extra'] != null?(json["extra"] as List).map((i) =>ResvOrderService.fromJson(i)).toList():List.empty(growable: true),
      photos: json['photos'] != null?(json["photos"] as List).map((i) =>i as int).toList():List.empty(growable: true)
    );
  }
}