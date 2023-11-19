import 'package:carwashapp/api/service/model/resv_order_item.dart';

class ResvOrderList{
  final int totalCount;
  final int page;
  final int perRow;
  List<ResvOrderItem> orders;

  ResvOrderList({required this.totalCount, required  this.page, required this.perRow, required this.orders});
  factory ResvOrderList.fromJson(Map<String,dynamic> json){
    return ResvOrderList(
      totalCount:json['totalCount'],
      page : json['page'],
      perRow:json['perRow'],
      orders:json['orders']!=null?(json['orders'] as List).map((o) => ResvOrderItem.fromJson(o)).toList():List.empty(growable: true)
    );
  }
}