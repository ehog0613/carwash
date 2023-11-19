import 'package:carwashapp/api/service/model/rest_order_item.dart';
import 'package:carwashapp/service/items/car_item_info.dart';
import 'package:carwashapp/service/items/location_info.dart';

class RestOrder{
  final String orderId;
  final CarItem carInfo;
  final LocationInfo location;
  final int totalPrice;
  final String title;
  final DateTime resDate;
  final RestOrderItem service;
  List<RestOrderItem>? extra;

  int? seq;
  int? userSeq;
  int? provider;

  DateTime? ordDate;
  DateTime? compDate;
  String? status;

  RestOrder({required this.orderId,required  this.carInfo,required this.location,required this.totalPrice,required this.title,required this.resDate,
  required this.service,this.seq, this.extra,this.status,this.compDate,this.ordDate,this.provider,this.userSeq} );

  factory RestOrder.fromJson(Map<String, dynamic> json){
    List<RestOrderItem> childs = [];
    if(json["extra"] != null){
      (json["extra"] as Map<String,dynamic>).forEach((key,val){
        childs.add(RestOrderItem.fromJson(val));
      });
      //childs.sort((a,b)=>a.cdSeq.compareTo(b.cdSeq));
    }
    return RestOrder(
        orderId:json['orderId']??"",
        carInfo:CarItem.fromJson(json['carinfo']),
        location:LocationInfo.fromJson(json['location']),
        resDate: json['resDate'],
        service: RestOrderItem.fromJson(json['service']),
        totalPrice:json['totalPrice']??0,
        title:json['title'],
        extra:childs,
        seq:json['seq']??0,
        provider:json['privider']??0,
        ordDate:json['ordDate'],
        compDate:json['compDate'],
        status:json['status']);
  }

  Map<String,dynamic>toJson()=>{
    "orderId":orderId,
    "carInfo":carInfo.toJson(),
    "location":location.toJson(),
    "resDate":resDate.toIso8601String(),
    "totalPrice":totalPrice,
    "service":service.toJson(),
    "title":title,
    "extra":extra != null?extra!.map((i)=>i.toJson()).toList():null,
    "seq":seq,
    "provider":provider,
    "ordDate":ordDate,
    "compDate":compDate,
    "status":status
  };

}