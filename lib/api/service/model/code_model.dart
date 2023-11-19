class Code{
  final int cdSeq;
  final String cd;
  final String cdVal;
  final List<Code>? child;

  Code({required this.cdSeq, required this.cd, required this.cdVal,this.child});

  factory Code.fromJson(Map<String, dynamic> json){
    // ignore: prefer_null_aware_operators
    List<Code> childs = [];
    if(json["child"] != null){
      (json["child"] as Map<String,dynamic>).forEach((key,val){
        childs.add(Code.fromJson(val));
      });
      childs.sort((a,b)=>a.cdSeq.compareTo(b.cdSeq));
    }

    return Code(
      cdSeq: json["cdSeq"],
      cd:json["cd"],
      cdVal: json["cdVal"],
      child: childs
    );
  }
}