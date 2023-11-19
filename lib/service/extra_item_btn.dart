import 'package:carwashapp/api/service/model/products.dart';
import 'package:flutter/material.dart';
import 'package:carwashapp/utils/carwash_util.dart';
import 'package:carwashapp/layout/def_style.dart';

typedef ItemTapCallback = void Function(Products service);

// ignore: must_be_immutable
class ServiceSelButton extends StatelessWidget {
  ServiceSelButton({
    Key? key,
    required this.service,
    required this.onSelect,
    required this.onDisSelect,
    required this.isSelected,
    this.borderColor,
    this.activeBorderColor,
    this.backgroundColor,
    this.activeBackgroundColor,
    this.textStyle,
    this.activeTextStyle,
  }) : super(key: key);

  final Products service;
  final ItemTapCallback onSelect;
  final ItemTapCallback onDisSelect;
  bool isSelected=false;
  final Color? borderColor;
  final Color? activeBorderColor;
  final Color? backgroundColor;
  final Color? activeBackgroundColor;
  final TextStyle? textStyle;
  final TextStyle? activeTextStyle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        if(!isSelected){
          onSelect(service);
        }else {
          onDisSelect(service);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color: isSelected
              ? activeBackgroundColor ?? Theme.of(context).primaryColor
              : backgroundColor ?? Theme.of(context).colorScheme.background,
        //  borderRadius: BorderRadius.circular(0),
          //border: Border(bottom: BorderSide(width: 1,color: Colors.white),          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              children: [
                SizedBox(
                  height: 40,
                  child:
                ListTile(
                  title: Text(service.title,style: isSelected? activeTextStyle: textStyle, maxLines: 1,),
                  trailing: const Icon(Icons.check,color: Colors.white),
                  visualDensity: const VisualDensity(vertical: -3),

                )),
                if(isSelected)
        SizedBox(
        height: 35,
        child:
                  ListTile(
                    horizontalTitleGap: -8,
                    leading: const Icon(Icons.add,color:Color.fromRGBO(211, 226, 239, 1) ),
                    title: Text(CarwashUtil.priceStr(service.price,service.detail), style: TextStyle(color: DefStyle.listViewlightText2, fontSize: 17, fontWeight: FontWeight.w700)),
                      visualDensity: const VisualDensity(vertical: -4),
                  ),

                )
              ],
          ),
        ),
      ),
    );
  }
}
