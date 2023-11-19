import 'package:carwashapp/api/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../api/service/model/resv_order_list.dart';
import '../layout/def_app_bar.dart';
import '../layout/def_style.dart';
import '../layout/right_menu_drawer_provider.dart';
import 'provider_order_detail.dart';
import '../utils/dialogs.dart';
import '../utils/geo_util.dart';

class FindOrder extends StatefulWidget {
  const FindOrder({Key? key}) : super(key: key);

  @override
  State<FindOrder> createState() => _FindOrder();
}

class _FindOrder extends State<FindOrder> {
  bool _isInit = false;
  ResvOrderList _orderList = ResvOrderList(totalCount: 0, page: 0, perRow: 10, orders: []);
  String _loadText = "조회중";

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero,() async{
      await _findOrders();
    });

  }

  Future<void> _findOrders() async{
    await _getLocation().then((position) async{
      bool findOk = false;
      for(int i = 1;i < 4;i++) {
        if(i > 1){
          setState(() {
            _loadText = "${i*10} Km 이내 조회중";
          });
        }
        findOk = await _findByDistance(position!, i * 10);
        if (findOk) {
          setState(() {
            _isInit = true;
          });
          break;
        }
      }
      setState(() {
        _isInit = true;
      });
    });
  }

  Future<bool> _findByDistance(Position position,int distance) async {
    return await Api().dio.post(Api.providerOrderFindUrl,
        data: {"lat": position.latitude, "lng": position.longitude,"distance":distance}).then((response) {
          final Map<String, dynamic> body = response.data;
          if (response.statusCode == 200) {
            Map<String, dynamic> result = body['data'];
            _orderList = ResvOrderList.fromJson(result);
            return true;
          }
          return false;
        }).catchError((onError){
          if(onError is DioError){
            if (kDebugMode) {
              print(onError.response);
            }
          }
          if (kDebugMode) {
            print(onError);
          }
          return false;
        }
    );
  }


  Future<Position?> _getLocation() async{
    try {
      Position? position = await GeoUtil.determinePosition();
      return position;
    }on PermissionDeniedException{
      CwDialogs.exitAlert(context, "위치정보 확인 권한을 허용해주셔야 합니다.");
    }on LocationServiceDisabledException{
      CwDialogs.exitAlert(context, "위치정보를 활성화 후 다시 시도해주세요.");
    }
    return null;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: DefAppBar(),
      endDrawer: const RightMenuDrawer(),
      body: RefreshIndicator(
        onRefresh: _findOrders,
        child: Center(
          child: SafeArea(
            child:
            !_isInit?
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset("images/loading1.gif"),
                const SizedBox(
                  height: 30,
                ),
                Text(_loadText)
              ],
            )
            :_orderList.totalCount >0 && _orderList.orders.isNotEmpty?
            Container(
              color: Colors.black12,
              child: ListView(
                padding: const EdgeInsets.only(left: 10, right: 10,top: 20),
                children: [
                  _listViewSep()
                ],
              ),
            ):Text("가능한 목록이 없습니다.",style: Theme.of(context).textTheme.labelMedium,),
          ),
        ),
      ),
    );
  }



  Widget _listViewSep(){
    return ListView.separated(itemBuilder: (BuildContext context,index){
      return GestureDetector(
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProviderOrderDetail(_orderList.orders[index]),
            ),
          );

        },
        child:Container(
          decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),color: Colors.white),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_orderList.orders[index].title, style: Theme.of(context).textTheme.titleLarge ),
              const SizedBox(height: 5,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_orderList.orders[index].resDate.toString().substring(0,16),style: Theme.of(context).textTheme.titleSmall,),
                      const SizedBox(height: 5,),
                      Text("차량 번호 : ${_orderList.orders[index].carNum}",style: Theme.of(context).textTheme.titleSmall,),
                    ],
                  ),
                  Text("${_orderList.orders[index].distance}Km", style: Theme.of(context).textTheme.labelMedium?.copyWith(color: DefStyle.importColor1)),
                ],
              ),
            ],
          ),
        )
        ,
      );
    },
        separatorBuilder: (BuildContext context,int index)=> const Divider(height: 10.0, color: Color.fromRGBO(212, 212, 212, 1)),
        itemCount: _orderList.orders.length,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.vertical
    );

  }
}