import 'package:async/async.dart';
import 'package:carwashapp/service/invoices.dart';
import 'package:carwashapp/api/service/model/products.dart';
import 'package:carwashapp/service/service_order_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carwashapp/layout/def_style.dart';

import 'extra_item_btn.dart';
import 'model/product_model.dart';

class ServiceExtra extends StatefulWidget {
  const ServiceExtra({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _ServiceExtra();
}

class _ServiceExtra extends State<ServiceExtra> {
  final AsyncMemoizer<List<Products>> _memoizer = AsyncMemoizer<List<Products>>();
  late ServiceOrder _orderProvider;
  final ScrollController _scrollController = ScrollController();
  final _listModel = ProductModel();
  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<Products>> _getExtraService(){
    return _memoizer.runOnce(() async {
      List<Products>? services = await _listModel.extraServices();
      return services;
    });
  }

  @override
  Widget build(BuildContext context) {
    _orderProvider = Provider.of<ServiceOrder>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: Text("추가서비스 선택",style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.indigo),),centerTitle: true),
      body: SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                DefStyle.subTitle("추가서비스 선택"),
                Flexible(
                  child:FutureBuilder<List<Products>>(
                    future: _getExtraService(),
                    builder: (context,snapshot){
                        if (snapshot.hasData) {
                          if(snapshot.data != null){
                            List<Products> extraServices = snapshot.data!;
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const ScrollPhysics(),
                              controller: _scrollController,
                              scrollDirection: Axis.vertical,
                              padding: const EdgeInsets.only(left:10, right: 10),
                              itemCount: extraServices.length,
                              itemBuilder: (BuildContext context, int index) {
                                final Products service = extraServices[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: ServiceSelButton(service: service,
                                    borderColor: DefStyle.listViewlightBack,
                                    activeBorderColor: DefStyle.listViewlightBackActive,
                                    backgroundColor: DefStyle.listViewlightBack,
                                    activeBackgroundColor: DefStyle.listViewlightBackActive,
                                    textStyle: TextStyle(color: DefStyle.listViewlightText , fontSize: 17, fontWeight: FontWeight.w700),
                                    activeTextStyle: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
                                    isSelected: _orderProvider.findExtra(service),
                                    onSelect: (service){
                                      setState(() {
                                        _orderProvider.addExtra(service);
                                      });
                                    },
                                    onDisSelect: (service){
                                      _orderProvider.removeExtrs(service);
                                      setState(() {
                                      });
                                    },
                                  ),
                                );
                              },
                            );
                          }else{
                            return const Text("부가 서비스가 없습니다.");
                          }
                        }else if(snapshot.hasError){
                          return const Text("호출 오류");
                        }else{
                          return const SizedBox( height: 400, child: Center(child: CircularProgressIndicator(),),);
                        }
                    },
                  )
                ,
                ),
              const SizedBox(height: 10,)]),
        ),
      ),
    bottomNavigationBar: Material(
    child: ElevatedButton(
    style: ElevatedButton.styleFrom(
    backgroundColor: const Color.fromRGBO(54, 104, 170, 1),
    padding: const EdgeInsets.all(20)),
    child: Text("다음",style: Theme.of(context).textTheme.titleMedium?.copyWith(color:Colors.white),
    ),
    onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (BuildContext context) => const ServiceInvoices(),
          ));
        }),
      ),
    );
  }
}
