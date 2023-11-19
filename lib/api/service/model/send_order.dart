import 'package:carwashapp/api/service/model/products.dart';

import '../../../service/items/car_item_info.dart';
import '../../../service/items/location_info.dart';

class SendOrder{
  final Products service;
  final CarItem carinfo;
  final DateTime resDateTime;
  final LocationInfo location;
  List<Products>? extra;
  SendOrder({required this.service,required this.carinfo,required this.resDateTime,required this.location, this.extra });


}