class Products {
  final int seq;
  final String type;
  final String title;
  final String detail;
  final int price;
  final String? icon;
  final String? img;

  Products({required this.seq,required this.type,required this.title,required this.detail,required this.price,
      this.icon, this.img});

  factory Products.fromJson(Map<String, dynamic> json){
    return Products(
      seq:json['seq'],
         type:json['type'],
         title:json['title'],
         detail:json['detail'],
         price:json['price'],
         icon:json['icon']??="",
         img:json['img']??="");
  }

  Map<String,dynamic>toJson()=>{
    "seq":seq,
    "type":type,
    "title":title,
    "price":price
  };
}
