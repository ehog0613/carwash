import 'package:flutter/material.dart';

class ImageWidgetApp extends StatefulWidget{
  const ImageWidgetApp({super.key});

  @override
  State<ImageWidgetApp> createState() => _ImageWidgetApp();

}

class _ImageWidgetApp extends State<ImageWidgetApp>{
  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      appBar: AppBar(title: const Text("Image Widget")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset("images/servImg1.jpg",width:200,height: 200, fit: BoxFit.contain),
            const Text("Hello Flutter",
                style: TextStyle(fontFamily: 'NanumSquare',fontSize: 30,color: Colors.blue),)
          ],
        ),
      ),
    );
  }
  
}
    