class CarItem{
  final int carSeq;
  final String vendorType;
  final String vendor;
  final String model;
  final String carNo;
  // private Integer seq;
  // private Integer userSeq;
  // private Integer vendorType;
  // private Integer vendor;
  // private Integer carSeq;
  // private String prodNm;
  // private String carNum;

  CarItem({required this.carSeq, required this.vendorType,required this.vendor,required this.model, required this.carNo});
  factory CarItem.fromJson(Map<String,dynamic> json){
    return CarItem(carSeq: json['carSeq'],
        vendorType: json["vendorType"]??"",
        vendor: json["vendor"]??"",
        model: json["model"]??"",
        carNo: json["carNo"]??"");
  }

  Map<String,dynamic>toJson()=>{
    "carSeq":carSeq,
    "vendorType":vendorType,
    "vendor":vendor,
    "model":model,
    "carNo":carNo
  };
}