class ResvOrderService{
  final int seq;
  final int svcSeq;
  final String title;
  final int price;

  ResvOrderService({required this.seq,required  this.svcSeq, required this.title, required this.price});
  factory ResvOrderService.fromJson(Map<String,dynamic> json){
    return ResvOrderService(
      seq: json['seq'],
      svcSeq: json['svcSeq'],
      title:json['title'],
      price:json['price']
    );
  }
}