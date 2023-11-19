import 'package:carwashapp/api/service/model/resv_order_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';

import '../api/api.dart';
import '../layout/def_style.dart';
import '../utils/photo_viewer.dart';

class OrderDetail extends StatefulWidget {
  final ResvOrderItem _orderItem;

  const OrderDetail(ResvOrderItem order, {Key? key})
      : _orderItem = order,
        super(key: key);

  @override
  State<OrderDetail> createState() => _OrderDetail();
}

class _OrderDetail extends State<OrderDetail> {
  var curr = NumberFormat.currency(locale: "ko_KR", symbol: "");
  late Map<String, String> _myheaders;
  late final Future<bool> _initHeader;

  @override
  void initState() {
    super.initState();
    _initHeader = Api().getMyheader().then((Map<String, String> value) {
      _myheaders = value;
      return true;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ResvOrderItem order = widget._orderItem;
    ToastContext().init(context);
    return Scaffold(
      appBar: AppBar(
          title: Text(
            "예약신청 정보 확인",
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.indigo),
          ),
          centerTitle: true),
      body: SafeArea(
        child: Center(
            child: Column(children: [
          DefStyle.liBottomLine("차량", "${order.carinfo} ${order.carNum}"),
          DefStyle.liBottomLine(
              "예약일시", order.resDate.toString().substring(0, 16)),
          DefStyle.liBottomLine("예약장소", order.addr),
          DefStyle.liBottomLine("기본서비스", order.service.title),
          // DefStyle.liBottomLine("세차종류", order.title),
          order.extra != null && order.extra!.isNotEmpty
              ? DefStyle.liBottomLineWidget("추가서비스", [
                  Text(
                    (order.extra ?? List.empty())
                        .map((e) => e.title)
                        .join(', '),
                  )
                ])
              : const SizedBox(
                  height: 0,
                ),
          DefStyle.liBottomLine("서비스 금액", curr.format(order.price)),
          DefStyle.liBottomLine("상태", DefStyle.orderText(order.status)),
          order.photos!.isNotEmpty
              ? FutureBuilder<bool>(
                  future: _initHeader,
                  builder:
                      (BuildContext context, AsyncSnapshot<bool> snapshot) {
                    if (snapshot.hasData && snapshot.data == true) {
                      return Expanded(
                          child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      mainAxisSpacing: 0,
                                      crossAxisSpacing: 0),
                              itemCount: order.photos!.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => PhotoViewer(
                                                ordSeq: order.seq,
                                                photoSeq:
                                                    order.photos![index])));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: NetworkImage(
                                                "${Api.baseOption.baseUrl}/provider/order/thumb/${order.seq}/${order.photos![index]}",
                                                headers: _myheaders))),
                                  ),
                                );
                              }));
                    } else if (snapshot.hasError) {
                      return const SizedBox();
                    } else {
                      return const SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(),
                      );
                    }
                  })
              : const SizedBox()
        ])),
      ),
    );
  }
}
