class SysInfo{
  final String keyNm;
  final int seq;
  final String memo;
  final DateTime regDate;

  SysInfo({ required this.keyNm,required this.seq,required this.memo,required this.regDate});
  factory SysInfo.fromJson(Map<String, dynamic> json){
    return SysInfo(keyNm: json['keyNm'],
        seq: json['seq'], memo: json['memo'], regDate: DateTime.parse(json['regDate'])
    );
  }



}