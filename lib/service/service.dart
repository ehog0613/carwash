import 'package:carwashapp/layout/def_app_bar.dart';
import 'package:carwashapp/api/service/model/products.dart';
import 'package:carwashapp/layout/right_menu_drawer.dart';
import 'package:carwashapp/service/model/product_model.dart';
import 'package:carwashapp/service/service_order_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../layout/def_style.dart';

import '../users/userstate.dart';
import 'detail.dart';
import 'items/car_item_info.dart';

class ServiceMainApp extends StatefulWidget{
  const ServiceMainApp({Key? key}) : super(key: key);


  @override
  State<ServiceMainApp> createState() => _ServiceMain();
}

class _ServiceMain extends State<ServiceMainApp>{

  var curr = NumberFormat.currency(locale: "ko_KR",symbol: "");
  final _listModel = ProductModel();
  //List<Products> services = List.empty(growable: true);
  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState(){
    /*
    services.add(Products(icon: "images/servIcon1.png",img:"images/servImg1.jpg", title: "물세차", desc: "차량내외부 클린세차", itemCd: "00",price:35000));
    services.add(Products(icon: "images/servIcon2.png",img:"images/servImg1.jpg", title: "스팀세차", desc: "차량내외부 고급세차", itemCd: "01",price:45000));
    services.add(Products(icon: "images/servIcon3.png",img:"images/servImg1.jpg", title: "외부물세차+내부스팀세차", desc: "차량외부/내부 고급세차", itemCd: "02",price:60000));*/

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        appBar: const DefAppBar(),
        endDrawer: const RightMenuDrawer(),
        body:
        SafeArea(
          child: Center(
              child: ListView(
                  children: [
                    Image.asset("images/mainImg.jpg"),
                    const SizedBox(height: 20,),
                    DefStyle.subTitle("서비스선택"),
                    Container(
                      padding: const EdgeInsets.only(left: 10.0,right: 10.0),
                      child: FutureBuilder<List<Products>>(
                        future: _listModel.defaultServices(),
                        builder: (context, snapshot){
                          if (snapshot.hasData) {
                            if (kDebugMode) {
                              print(snapshot.data);
                            }
                            //print(snapshot.error);
                            if(snapshot.data != null) {
                              return listviewSep(snapshot.data!);
                            }else{
                              return const Text("정보 조회 불가");
                            }
                          } else if (snapshot.hasError) {
                            if (kDebugMode) {
                              print(snapshot.data);
                              print(snapshot.error); // 에러메세지 ex) 사용자 정보를 확인할 수 없습니다.
                            } // null
                            return const Text("에러");
                          } else {
                            return const Text("로딩중");
                          }
                        },
                      )
                    )
                  ]
              )
          ),
        )
    );
  }
  Widget listviewSep(List<Products> products){
    return ListView.separated(itemBuilder: (BuildContext context,int index){
      return
        GestureDetector(
            onTap: (){
              serviceSelect(products[index]);
            },
            child:
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: Container(
                        color: const Color.fromRGBO(242, 242, 242, 1),
                        child: Image.asset(products[index].icon!, width: 120, height: 120, ),
                      ),
                    ),
                    const SizedBox(width: 10,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(products[index].title, style: Theme.of(context).textTheme.labelMedium ),
                        const SizedBox(height: 8),
                        Text(products[index].detail,style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 8),
                        Text("${curr.format(products[index].price)} ~",style: Theme.of(context).textTheme.labelMedium?.copyWith(color: DefStyle.importColor1))
                      ],
                    )
                  ]
              ),
            )
        );
    },
      shrinkWrap: true, separatorBuilder: (BuildContext context,int index)=> const Divider(height: 10.0, color: Color.fromRGBO(212, 212, 212, 1)),
      itemCount: products.length,
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,);
  }

  void serviceSelect(Products? item) {
    if(item != null) {
      if(Provider.of<UserState>(context, listen: false).countCar() > 0){
        CarItem? userCar = Provider.of<UserState>(context, listen: false).getCar();
        if(userCar != null){
          Provider.of<ServiceOrder>(context, listen: false).carInfo(userCar);
        }
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ServiceDetail(item),
        ),
      );
    }
  }
}