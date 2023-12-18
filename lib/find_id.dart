import 'package:carwashapp/api/api.dart';
import 'package:carwashapp/layout/def_style.dart';
import 'package:flutter/material.dart';

class FindId extends StatelessWidget {
  // controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telController = TextEditingController();

  FindId({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("아이디 찾기",
            style: TextStyle(
              color: Colors.blue,
            )),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // user id input
          Container(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '이름',
              ),
              keyboardType: TextInputType.name,
            ),
          ),
          // user email input
          Container(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '이메일',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          // user telnumber input
          Container(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _telController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '전화번호',
              ),
              keyboardType: TextInputType.phone,
            ),
          ),
          const Spacer(),
          // find id button width full
          Container(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: DefStyle.btnActiveBackColor,
                padding: const EdgeInsets.all(10),
              ),
              child: Center(
                child: Text(
                  '아이디 찾기',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ),
              onPressed: () {
                // url : /api/auth/search/userid
                // param : userId , userEmail, userTel
                // method : POST
                var param = {
                  "userId": _nameController.text,
                  "userEmail": _emailController.text,
                  "userTel": _telController.text,
                };
                Api().dio.post(Api.findId, data: param).then((value) {
                  if (value.statusCode == 200) {
                    final Map<String, dynamic> body = value.data;
                    debugPrint("asdfjklasdfjaklds: " + value.data.toString());
                    if (body["data"] == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(body["message"]),
                        ),
                      );
                    } else {
                      // 아이디 찾기 성공, 아이디 보여주는 다이얼로그 띄우고 복사, 확인 버튼. 복사 누르면 클립보드 복사, 확인 버튼 누르면 Navigator pop
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("아이디 찾기 성공"),
                            content: Text("아이디 : ${body["data"]["userId"]}"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.popUntil(context, ModalRoute.withName('/login'));
                                },
                                child: const Text("확인"),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("아이디 찾기에 실패하였습니다."),
                      ),
                    );
                  }
                }).catchError((error, stackTrace) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("아이디 찾기에 실패하였습니다."),
                    ),
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
