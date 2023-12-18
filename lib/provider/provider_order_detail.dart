import 'package:carwashapp/api/api.dart';
import 'package:carwashapp/api/service/model/resv_order_item.dart';
import 'package:carwashapp/utils/dialogs.dart';
import 'package:carwashapp/utils/photo_viewer.dart';
import 'package:carwashapp/utils/take_photo.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../layout/def_style.dart';
import '../users/userstate.dart';

class ProviderOrderDetail extends StatefulWidget {
  final ResvOrderItem _orderItem;

  const ProviderOrderDetail(ResvOrderItem order, {Key? key})
      : _orderItem = order,
        super(key: key);

  @override
  State<ProviderOrderDetail> createState() => _OrderDetail();
}

class _OrderDetail extends State<ProviderOrderDetail> {
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
    UserState userState = Provider.of<UserState>(context, listen: false);
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
              : const SizedBox(height: 0),
          DefStyle.liBottomLine("서비스 금액", curr.format(order.price)),
          order.provider == 0
              ? DefStyle.liBottomLineWidget("상태", <Widget>[
                  Text(DefStyle.orderText(order.status)),
                  const SizedBox(
                    width: 20,
                  ),
                  DefStyle.okBtn("접수", () async {
                    CwDialogs.modalLoading(context, "요청중");
                    await Api().dio.post(Api.providerOrderResv,
                        data: {"seq": order.seq}).then((response) {
                      final Map<String, dynamic> body = response.data;
                      Navigator.pop(context);
                      if (response.statusCode == 200 && body["data"] != null) {
                        if (mounted) {
                          CwDialogs.alert(context, "접수 되었습니다.", () {
                            Navigator.pushReplacementNamed(
                                context, "/provider");
                          });
                        }
                      } else {
                        if (mounted) {
                          CwDialogs.alert(context, "이미 접수된 요청 입니다.", () {
                            Navigator.pop(context);
                          });
                        }
                      }
                    }).catchError((onError) {
                      Navigator.pop(context);
                      if (mounted) {
                        CwDialogs.alert(context, "요청중 오류가 발생했습니다.", () {
                          Navigator.pop(context);
                        });
                      }
                    });
                  })
                ])
              : order.providerId == userState.id() && order.status == "ready"
                  ? DefStyle.liBottomLineWidget("상태", <Widget>[
                      Text(DefStyle.orderText(order.status)),
                      const SizedBox(
                        width: 20,
                      ),
                      DefStyle.okBtn("진행", () async {
                        CwDialogs.modalLoading(context, "상태 등록중");
                        await Api().dio.post(Api.providerOrderStatus, data: {
                          "seq": order.seq,
                          "status": "washing"
                        }).then((response) {
                          final Map<String, dynamic> body = response.data;
                          Navigator.pop(context);
                          if (response.statusCode == 200 &&
                              body["data"] != null) {
                            if (mounted) {
                              setState(() {
                                order.status =
                                    body["data"]['status'] ?? order.status;
                              });
                            }
                          }
                        }).catchError((onError) {
                          Navigator.pop(context);
                          if (mounted) {
                            CwDialogs.alert(context, "요청중 오류가 발생했습니다.", () {
                              Navigator.pop(context);
                            });
                          }
                        });
                      })
                    ])
                  : order.providerId == userState.id() &&
                          order.status == "washing"
                      ? Column(children: [
                          DefStyle.liBottomLine(
                              "상태", DefStyle.orderText(order.status)),
                          DefStyle.liBottomLineWidget("진행", <Widget>[
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff3668AA),
                              ),
                              onPressed: () async {
                                final returnData = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TakePhoto(order.seq),
                                  ),
                                );
                                if (returnData != null) {
                                  setState(() {
                                    order.photos!.add(returnData);
                                  });
                                }
                              },
                              child: const Text(
                                '사진등록',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff3668AA),
                              ),
                              onPressed: () async {
                                CwDialogs.modalLoading(context, "전송중");
                                await Api().dio.post(Api.providerOrderStatus,
                                    data: {
                                      "seq": order.seq,
                                      "status": "return"
                                    }).then((response) {
                                  final Map<String, dynamic> body = response.data;
                                  Navigator.pop(context);
                                  if (response.statusCode == 200 &&
                                      body["data"] != null) {
                                    if (mounted) {
                                      setState(() {
                                        order.status = body["data"]['status'] ??
                                            order.status;
                                      });
                                    }
                                  }
                                }).catchError((onError) {
                                  Navigator.pop(context);
                                  if (mounted) {
                                    CwDialogs.alert(context, "요청중 오류가 발생했습니다.",
                                            () {
                                          Navigator.pop(context);
                                        });
                                  }
                                });
                              },
                              child: const Text(
                                '마감처리',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ])
                        ])
                      : DefStyle.liBottomLine(
                          "상태", DefStyle.orderText(order.status)),
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
