import 'package:intl/intl.dart';

class CarwashUtil{
  static NumberFormat curr = NumberFormat.currency(locale: "ko_KR", symbol: "");
  static int parseVersionStr(String version){
      List parseList = version.split('.');
      parseList = parseList.map((i) => int.parse(i)).toList();
      return parseList[0] * 100000 + parseList[1] * 1000 + parseList[2];
  }

  static String priceStr(int price, [String? prefix]){
    String retstr = "";
    if(prefix != null && prefix.isNotEmpty){
      retstr += "$prefix+";
    }
    retstr +=curr.format(price);
    return retstr;
  }
}