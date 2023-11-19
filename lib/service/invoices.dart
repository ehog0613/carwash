import 'package:carwashapp/api/api.dart';
import 'package:carwashapp/service/service_order_info.dart';
import 'package:carwashapp/utils/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../layout/def_style.dart';

class ServiceInvoices extends StatefulWidget {
  const ServiceInvoices({Key? key}) : super(key: key);

  @override
  State<ServiceInvoices> createState() => _ServiceInVoices();
}

class _ServiceInVoices extends State<ServiceInvoices> {
  late ServiceOrder _orderProvider;
  var curr = NumberFormat.currency(locale: "ko_KR", symbol: "");
  bool _agree1 = false;

  // bool _agree2 = false;
  // bool _agree3 = false;
  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    _orderProvider = Provider.of<ServiceOrder>(context, listen: false);
    _orderProvider.solvPrice();
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
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                DefStyle.liBottomLine("차량", _orderProvider.carInfoTxt()),
                DefStyle.liBottomLine("예약일시", _orderProvider.dateTime()),
                DefStyle.liBottomLine("예약장소", _orderProvider.address()),
                DefStyle.liBottomLine("세차종류", _orderProvider.serviceName()),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "서비스 비용 : ",
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            curr.format(_orderProvider.price()),
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        const Color.fromRGBO(11, 124, 230, 1)),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "- 세차 : ",
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            curr.format(_orderProvider.servicePrice()),
                            style: Theme.of(context).textTheme.titleSmall,
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "- 추가서비스 : ",
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            curr.format(_orderProvider.extraPrice),
                            style: Theme.of(context).textTheme.titleSmall,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("서비스 이용약관",
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      GestureDetector(
                        child: ListTile(
                          title: Text(
                            "[필수] 본 서비스 이용을 위하여...",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                    color:
                                        _agree1 ? Colors.blue : Colors.black45),
                          ),
                          visualDensity: const VisualDensity(vertical: -3),
                        ),
                        onTap: () {
                          _showAgree1();
                        },
                      )
                    ],
                  ),
                )
              ])),
        ),
        bottomNavigationBar: Material(
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(54, 104, 170, 1),
                    padding: const EdgeInsets.all(20)),
                child: Text("세차호출",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.white)),
                onPressed: () async {
                  if (!_agree1) {
                    Toast.show("필수 약관에 동의 하셔야 합니다.",
                        gravity: Toast.center, duration: Toast.lengthLong);
                  } else {
                    //Toast.show("후속 기능 작업중 ", gravity: Toast.center, duration: Toast.lengthLong);
                    CwDialogs.modalLoading(context, "요청 정보 전송중");
                    // todo : Serverside : 차량 정보 전송 정보 등록
                    var data = _orderProvider.toJson();
                    await Api()
                        .dio
                        .post(Api.requestOrderUrl, data: data)
                        .then((value) {
                      _orderProvider.clear();
                      Navigator.pop(context);
                      Navigator.pushNamedAndRemoveUntil(
                          context, "/myorder", (route) => false);
                    }).onError((error, stackTrace) {
                      Toast.show("오류가 발생 했습니다. 잠시후 다시 시도해주세요.",
                          gravity: Toast.center, duration: Toast.lengthLong);
                      Navigator.pop(context);
                    });
                  }
                })));
  }

  void agree1(bool agree1) {
    setState(() {
      _agree1 = agree1;
    });
  }

  void _showAgree1() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("필수 약관 1"),
          content: SingleChildScrollView(
              child: Text(
            "약관 내용.약관 내용약관 내용약관 내용약관 내용약관 내용약관 내용\n약관 내용.약관 내용약관 내용약관 내용약관 내용약관 내용약관 내용"
            "\n약관 내용.약관 내용약관 내용약관 내용약관 내용약관 내용약관 내용\n약관 내용.약관 내용약관 내용약관 내용약관 내용약관 내용약관 내용\n"
            "약관 내용.약관 내용약관 내용약관 내용약관 내용약관 내용약관 내용\n",
            style: Theme.of(context).textTheme.bodyLarge,
          )),
          actions: <Widget>[
            TextButton(
              child: const Text("동의함"),
              onPressed: () {
                Navigator.pop(context);
                agree1(true);
              },
            ),
            TextButton(
              child: const Text("동의하지 않음"),
              onPressed: () {
                Navigator.pop(context);
                agree1(false);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
