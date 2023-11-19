import 'package:carwashapp/api/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewer extends StatefulWidget{
 final int ordSeq;
 final int photoSeq;
 const PhotoViewer({required this.ordSeq,required this.photoSeq,Key? key}) :super(key:key);

  @override
  State<PhotoViewer> createState()=>_PhotoViewer();
}

class _PhotoViewer extends State<PhotoViewer>{
  late final Future<bool> _headerInit;
  late Map<String,String> _myheader;
  late PhotoViewScaleStateController _scaleStateController;

  @override
  void initState() {
    super.initState();
    _scaleStateController = PhotoViewScaleStateController();
    _headerInit = Api().getMyheader().then((Map<String,String> header){
      _myheader = header;
      return true;
    });
  }

  @override
  void dispose() {
    _scaleStateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("사진보기",style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.indigo),),centerTitle: true),
      body:
        FutureBuilder(
          future: _headerInit,
          builder: (BuildContext context,snapshot){
            List<Widget> children;

            if(snapshot.hasData) {
              return Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: PhotoView(
                          imageProvider: NetworkImage("${Api.baseOption.baseUrl}/provider/order/photo/${widget.ordSeq}/${widget.photoSeq}",headers: _myheader),
                          scaleStateController: _scaleStateController,
                          )
                    ),

                  ],
                  );
            }else if(snapshot.hasError){
              children = <Widget>[
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text('Error: ${snapshot.error}'),
                ),
              ];
            }else{
              children = const <Widget>[
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text('Awaiting result...'),
                ),
              ];
            }
            return Center(
              child: Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: children,
                ),
              ),
            );
          },
        )

    );
  }
}