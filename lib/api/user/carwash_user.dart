class CarwashUser{
  final String userId;
  final String userName;
  final String userTel;
  final String userEmail;
  final String userType;

  CarwashUser({required this.userId,required this.userName, required this.userTel, required this.userEmail, required this.userType});

  factory CarwashUser.fromJson(Map<String,dynamic>parsedJson){
    return CarwashUser(
      userId:parsedJson['userId'],
      userName:parsedJson['userName'],
      userTel:parsedJson['tel']??parsedJson['userTel']??"",
      userEmail:parsedJson['email']??parsedJson['userEmail']??"",
      userType:parsedJson['userType'],
    );
  }

  Map<String,dynamic>toJson()=>{
  "userId":userId,
  "userName":userName,
  "userTel":userTel,
  "userEmail":userEmail,
    "userType":userType,
  };
}