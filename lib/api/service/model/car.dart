class Car {
  final int carSeq;
  final int cdSeq;
  final String vendor;
  final String prodNm;
  final String? descMsg;


  Car({required this.carSeq,required this.cdSeq,required this.vendor,required this.prodNm, this.descMsg});

  factory Car.fromJson(Map<String, dynamic> json){
    return Car(
        carSeq:json['carSeq'],
         cdSeq:json['cdSeq'],
         vendor: json['vendor'],
         prodNm:json['prodNm'],
         descMsg:json['descMsg']??"");
  }
}
