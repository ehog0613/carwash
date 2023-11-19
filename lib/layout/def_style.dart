import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DefStyle{
  static Color mainColor = const Color.fromRGBO(85, 182, 219, 1);
  static Color btnActiveBackColor = const Color.fromRGBO(54, 104, 170, 1);
  static Color btnDarkGrayBackColor = const Color.fromRGBO(68, 68, 68, 1);
  static Color importColor1 = const Color.fromRGBO(31, 94, 190, 1);
  static Color listViewlightBack = const Color.fromRGBO(227, 236, 244, 1);
  static Color listViewlightBackActive =const Color.fromRGBO(79, 138, 192, 1);
  static Color listViewlightText = const Color.fromRGBO(89, 89, 89, 1);
  static Color listViewlightText2 = const Color.fromRGBO(211, 226, 239, 1);

  static TextStyle textLiHead = const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15);
  static TextStyle textLibody = const TextStyle(fontSize: 15, letterSpacing: 0.15);

  static ButtonStyle grayBtnStyle = ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(128, 128, 128, 1),fixedSize: const Size.fromWidth(120), padding: const EdgeInsets.only(top:10, bottom: 10) );
  static ButtonStyle blueBtnStyle = ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(54, 104, 170, 1),fixedSize: const Size.fromWidth(120), padding: const EdgeInsets.only(top:10, bottom: 10) );

  static Widget subTitle(String title){
    return Padding(padding: const EdgeInsets.all(10),
      child:
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset("images/contTit.png"),
          const SizedBox(width: 10,),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)
        ],
      ),
    );
  }

  static Widget liBottomLine(String leading,String title){
    return
      Padding(
          padding: const EdgeInsets.only(left: 20,right: 10),
          child:
          Container(
            decoration: const BoxDecoration(border: Border(bottom: BorderSide( color: Colors.black12,width: 0.7))),
            padding: const EdgeInsets.only(top: 15,),
            height: 60,
            child:
                Row(                  
                  children: [
                    SizedBox(
                        width: 100,
                        child: Text(leading, style: textLiHead,)),
                    Text(title,style: textLibody,)
                  ],
                )
            )
      );
  }

  static Widget liBottomLineWidget(String leading,List<Widget> widget){
    List<Widget> childrens = [SizedBox(
        width: 100,
        child: Text(leading, style: textLiHead,))];
    childrens.addAll(widget);
    return
      Padding(
          padding: const EdgeInsets.only(left: 20,right: 10),
          child:
          Container(
            decoration: const BoxDecoration(border: Border(bottom: BorderSide( color: Colors.black12,width: 0.7))),
            height: 60,
            padding: const EdgeInsets.only(top:15),
            child: Row(
              children: childrens,
            ),
          )
      );
  }

  static Widget okBtn(String text, VoidCallback onPress){
    return ElevatedButton(onPressed: onPress,
        style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(54, 104, 170, 1),fixedSize: const Size.fromWidth(120), padding: const EdgeInsets.only(top:10, bottom: 10) ),
        child: Text(text, style: const TextStyle(fontSize: 15,color: Colors.white),));
  }

  static Widget grayBtn(String text, VoidCallback onPress ){
    return ElevatedButton(onPressed: onPress,
        style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(128, 128, 128, 1),fixedSize: const Size.fromWidth(120), padding: const EdgeInsets.only(top:10, bottom: 10) ),
        child: Text(text, style: const TextStyle(fontSize: 15,color: Colors.white),));
  }

  static Widget deopBox(List<String> dropItems){
    return Padding(
      padding: const EdgeInsets.only(left: 10,right: 10),
      child:
      Container(
        decoration: const BoxDecoration(border: Border(bottom: BorderSide())),
        child:
        Row(
          children: [
            const SizedBox(
                width: 100,
                child: Text("제조사")),
            DropdownButton<String?>(
              onChanged: (String? newValue) {
                if (kDebugMode) {
                  print(newValue);
                }
              },
              items: dropItems.map<DropdownMenuItem<String>>((value){
                return DropdownMenuItem(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  static Color statusColor(String? status){
    switch(status){
      case "ready":
        return Colors.orange.shade100;
      case "washing":
        return Colors.orange.shade200;
      case "return":
        return Colors.orange.shade300;
      case "complete":
        return Colors.blue.shade300;
      case "cancel":
        return Colors.grey.shade500;
      case "order":
      default:
        return Colors.white;
    }
  }

  static String orderText(orderState){
    if(orderState == null) return "--";
    switch(orderState){
      case 'order':
        return "접수대기";
      case 'ready':
        return "접수완료";
      case 'washing':
        return "세차중";
      case 'return':
        return "세차완료";
      case 'complete':
        return "서비스종료";
      default:
        return "--";
    }
  }
}