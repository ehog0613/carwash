import 'package:carwashapp/api/user/user_services.dart';
import 'package:carwashapp/layout/def_style.dart';
//import 'package:carwashapp/users/userstate.dart';
import 'package:carwashapp/utils/dialogs.dart';
import 'package:carwashapp/utils/validators.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

class JoinWidget extends StatefulWidget {
  const JoinWidget({Key? key}) : super(key: key);

  @override
  State<JoinWidget> createState() => _JoinWidget();
}

class _JoinWidget extends State<JoinWidget> {
  // late UserState _userState;
  final GlobalKey<FormState> _joinFormKey = GlobalKey<FormState>();
  final TextEditingController _idControl = TextEditingController();
  final TextEditingController _pswdControl = TextEditingController();
  final TextEditingController _pswdConfControl = TextEditingController();
  final TextEditingController _emailControl = TextEditingController();
  final TextEditingController _nameControl = TextEditingController();
  final TextEditingController _telControl = TextEditingController();

  final FocusNode _idFocus = FocusNode();
  final FocusNode _pswdFocus = FocusNode();
  final FocusNode _pswdConfFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _telFocus = FocusNode();
  final FocusNode _submitFocus = FocusNode();
  final List<Widget> _userType = <Widget>[const Text("서비스이용자"),const Text("세차요원")];
  final List<bool> _userTypeSelected = <bool>[true,false];

  @override
  void dispose() {
    _idControl.dispose();
    _pswdControl.dispose();
    _pswdConfControl.dispose();
    _emailControl.dispose();
    _nameControl.dispose();
    _telControl.dispose();
    _idFocus.dispose();
    _pswdFocus.dispose();
    _pswdConfFocus.dispose();
    _emailFocus.dispose();
    _nameFocus.dispose();
    _telFocus.dispose();
    _submitFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _userState = Provider.of<UserState>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text("회원가입", style: TextStyle(color: Colors.blue,)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _joinFormKey,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ToggleButtons(
                      direction: Axis.horizontal,
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      selectedBorderColor: Colors.blue[700],
                      selectedColor: Colors.white,
                      fillColor: Colors.blue[200],
                      color: Colors.blue[400],
                      constraints: const BoxConstraints(minHeight: 40.0,minWidth: 120.0),
                      onPressed: (int index){
                        setState(() {
                          for(int i=0;i< _userTypeSelected.length;i++){
                            _userTypeSelected[i] = i ==index;
                          }
                        });
                      },
                        isSelected: _userTypeSelected, children: _userType),
                    _userTypeSelected[1]?
                      Container(
                        decoration:BoxDecoration(
                            border: Border.all(color:Colors.red),
                            borderRadius: BorderRadius.circular(8)
                        ),
                        alignment: AlignmentDirectional.center,
                        padding: const EdgeInsets.all(8),
                        child: const Text("세차요원은 관리자 승인 후 서비스 이용이 가능합니다.")
                      ):
                      Container(),
                    Column(children: [
                      TextFormField(
                        key:const Key("userId"),
                        keyboardType: TextInputType.text,
                        controller: _idControl,
                        focusNode: _idFocus,
                        decoration: const InputDecoration(
                            labelText: "아이디",
                        ),
                        validator: (value)=>CwValidators.userId(value),
                        onFieldSubmitted: (_){
                          FocusScope.of(context).requestFocus(_pswdFocus);
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                          key: const Key("userPswd"),
                          keyboardType: TextInputType.text,
                          controller: _pswdControl,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          focusNode: _pswdFocus,
                          onFieldSubmitted: (_){
                            FocusScope.of(context).requestFocus(_pswdConfFocus);
                          },
                          decoration: const InputDecoration(
                              labelText: "비밀번호",),
                          validator: (value)=>CwValidators.userPswd(value),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        key: const Key("userPswdConf"),
                        keyboardType: TextInputType.text,
                        controller: _pswdConfControl,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        focusNode: _pswdConfFocus,
                        onFieldSubmitted: (_){
                          FocusScope.of(context).requestFocus(_emailFocus);
                        },
                        decoration: const InputDecoration(
                          labelText: "비밀번호확인",),
                        validator: (value)=>CwValidators.userPswdConf(value,_pswdControl.text),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        key: const Key("userName"),
                        keyboardType: TextInputType.text,
                        controller: _nameControl,
                        focusNode: _nameFocus,
                        onFieldSubmitted: (_){
                          FocusScope.of(context).requestFocus(_emailFocus);
                        },
                        decoration: const InputDecoration(
                          labelText: "이름",),
                        validator: (value)=>CwValidators.checkLen(3,value),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        key: const Key("userEmail"),
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailControl,
                        focusNode: _emailFocus,
                        onFieldSubmitted: (_){
                          FocusScope.of(context).requestFocus(_telFocus);
                        },
                        decoration: const InputDecoration(
                          labelText: "이메일",),
                        validator: (value)=>CwValidators.userEmail(value),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        key: const Key("userTel"),
                        keyboardType: TextInputType.text,
                        controller: _telControl,
                        focusNode: _telFocus,
                        onFieldSubmitted: (_){
                          FocusScope.of(context).requestFocus(_submitFocus);
                        },
                        decoration: const InputDecoration(
                          labelText: "연락처",),
                        validator: (value)=>CwValidators.userTel(value),
                      ),
                    ]),

                    Padding(
                        padding: const EdgeInsets.only(top: 30,bottom: 20),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white, backgroundColor: DefStyle.btnActiveBackColor,
                              padding: const EdgeInsets.all(10),                              ),
                          focusNode: _submitFocus,
                          child: Center(
                              child: Text('회원가입', style: Theme.of(context).textTheme.titleLarge?.copyWith(color:Colors.white) )
                          ),
                          onPressed: () => _joinSubmit()
                        )),

                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  //todo : 가입후 해당 페이지 리턴
  /*void _goMain(){
    if(_userState.provider()){
      Navigator.pushNamedAndRemoveUntil(context, "/provider", (route) => false);
    }else {
      Navigator.pushNamedAndRemoveUntil(context, "/service", (route) => false);
    }
  }*/

  void _joinSubmit() async {
    if(_joinFormKey.currentState!.validate()) {
      /*
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing Data')),
      );*/

      CwDialogs.modalLoading(
        context,"서버 통신중 입니다. 잠시만 기다려 주세요."
      );
      var joindata = <String,dynamic>{};
      joindata['userId'] = _idControl.text;
      joindata['userPswd'] = _pswdControl.text;
      joindata['userName'] = _nameControl.text;
      joindata['userEmail'] = _emailControl.text;
      joindata['userTel'] = _telControl.text;
      joindata['userType'] = _userTypeSelected[1]?"provider":"customer";
      bool joinOk = false;
      String errMsg = "";
      try {
        await UserService().join(joindata);
        joinOk = true;
      }on DuplicationIdException{
        errMsg = "이미 등록된 ID 입니다.";
        FocusScope.of(context).requestFocus(_idFocus);
      }on JoinFailException catch(e){
        if (kDebugMode) {
          print("join Errro $e");
        }
        errMsg = e.cause;
      }catch(e){
        if (kDebugMode) {
          print("join Errr $e");
        }
        errMsg = "가입 처리중 오류가 발생 했습니다.";
      }finally{
        Navigator.pop(context);
      }
      if(joinOk && mounted) {
        CwDialogs.alertLogin(context, "정상처리 되었습니다. 로그인 해주세요.");
      }else{
        CwDialogs.alert(context, errMsg);
      }
    }else{

    }
  }
}
