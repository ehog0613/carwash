class RestOrderItem{
  final int seq;
  final int svcSeq;
  final String title;
  final int price;

  RestOrderItem({required this.seq, required this.svcSeq, required this.title, required this.price});
  factory RestOrderItem.fromJson(Map<String, dynamic> json){
    return RestOrderItem(
        seq:json['seq'],
        svcSeq:json['svcSeq'],
        title:json['title'],
        price:json['price']
        );
  }

  Map<String,dynamic>toJson()=>{
    "seq":seq,
    "svcSeq":svcSeq,
    "title":title,
    "price":price
  };
}