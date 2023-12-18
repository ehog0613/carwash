import 'package:carwashapp/api/service/model/resv_order_list.dart';
import 'package:carwashapp/api/user/user_services.dart';
import 'package:carwashapp/layout/def_app_bar.dart';
import 'package:carwashapp/layout/def_style.dart';
import 'package:carwashapp/layout/right_menu_drawer.dart';
import 'package:carwashapp/utils/dialogs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'my_order_detail.dart';
class MyOrderList extends StatefulWidget {
  const MyOrderList({Key? key}) : super(key: key);

  @override
  State<MyOrderList> createState() => _MyOrderList();
}

class _MyOrderList extends State<MyOrderList> {
  var curr = NumberFormat.currency(locale: "ko_KR",symbol: "");
  //final AsyncMemoizer<List<RestOrder>> _memoizer = AsyncMemoizer<List<RestOrder>>();
  final UserService _userService = UserService();
  bool _isInit = false;
  ResvOrderList _orderList = ResvOrderList(totalCount: 0, page: 0, perRow: 10, orders: []);
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero,(){
      _getList();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _getList() async{

      setState(() {
        _isInit = false;
      });
      await _userService.myOrder({}).then((value) {
        _orderList = ResvOrderList.fromJson(value);
        setState(() {
          _isInit = true;
          if (kDebugMode) {
            print(_orderList);
          }
        });
      }).catchError((error) {
        if (kDebugMode) {
          print("$error");
        }
        CwDialogs.alert(context, "네트웤 지연으로 조회에 실패 했습니다. \n 잠시후 다시 시도해주세요");
      });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefAppBar(),
      endDrawer: const RightMenuDrawer(),
      body: RefreshIndicator(

        onRefresh: _getList,
        child: SafeArea(
          child: Center(
            child:
            !_isInit? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset("images/loading1.gif"),
                const SizedBox(
                  height: 30,
                ),
                const Text("조회중")
              ],
            ):_orderList.totalCount > 0 && _orderList.orders.isNotEmpty?
            Container(
              color: Colors.black12,
              child: ListView(
                padding:const EdgeInsets.only(left: 10, right: 10, top: 20),
                children: [
                  _listViewSep()
                ],
              ),
            ):
            const Text("주문 목록이 없습니다."),
          )

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
              builder: (context) => OrderDetail(_orderList.orders[index]),
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
                crossAxisAlignment: CrossAxisAlignment.end,
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
                  Column(
                    children: [
                      Text(DefStyle.orderText(_orderList.orders[index].status),style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),),
                      const SizedBox(height: 5,),
                      Text(curr.format(_orderList.orders[index].price), style: Theme.of(context).textTheme.titleLarge?.copyWith(color: DefStyle.importColor1)),
                    ],
                  ),
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