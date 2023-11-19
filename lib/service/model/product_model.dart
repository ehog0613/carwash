import 'package:carwashapp/api/service/model/car.dart';
import 'package:carwashapp/api/service/product_service.dart';
import 'package:carwashapp/api/service/model/products.dart';

import '../../api/service/code_service.dart';
import '../../api/service/model/code_model.dart';

class ProductModel{
  final _service = ProductServices();
  final _vendorService = CodeServices();

  Future<List<Products>> defaultServices(){
    return _service.getProduct("default");
  }

  Future<List<Products>> extraServices(){
    return _service.getProduct("extra");
  }

  Future<List<Code>> getVendor(){
    return _vendorService.getVendors();
  }

  Future<Map<String,List<Car>>> getCarInfo(){
    return _vendorService.getCarList();

  }
}