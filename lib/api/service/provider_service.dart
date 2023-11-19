
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../api.dart';

class ProviderServices{
  static ProviderServices? _instance;
  factory ProviderServices()=> _instance??=ProviderServices._();
  ProviderServices._();

 Future<int> uploadFile(int ordSeq,XFile file) async {
   int seq = 0;
   try {
     String fileName = file.path.split('/').last;
     FormData formData = FormData.fromMap({
       "file": await MultipartFile.fromFile(file.path,filename: fileName)
     });

     var response = await Api().dio.post(
         "${Api.providerOrderPhoto}/$ordSeq", data: formData);

     Map<String, dynamic> body = response.data;
     if (response.statusCode == 200 && body["data"] != null) {
      // upfile = body["data"]['fileNm'];
       seq = body["data"]['seq'];
     }

   } catch (e) {
     if (kDebugMode) {
       print(e);
     }
   }
   return seq;
 }


}