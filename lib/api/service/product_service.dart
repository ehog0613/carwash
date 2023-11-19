import 'package:carwashapp/api/service/model/products.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api.dart';

class ProductServices{
  static ProductServices? _instance;
  final storage = const FlutterSecureStorage();
  factory ProductServices()=> _instance??=ProductServices._();
  ProductServices._();

 Future<List<Products>> getProduct(String type) async {
   List<Products> services = List.empty(growable: true);
   try {
     if (type != "extra") {
       type = "default";
     }
     final response = await Api().dio.post(
         Api.productListUrl, data: {"type": type});

     Map<String, dynamic> body = response.data;
     if (response.statusCode == 200 && body["data"] != null) {
       var list = body['data'] as List;
       services = list.map((i) => Products.fromJson(i)).toList();
     }

   } catch (e) {
     if (kDebugMode) {
       print(e);
     }
   }
   return services;
 }


}