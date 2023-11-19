import 'package:carwashapp/api/user/carwash_user.dart';
import 'package:carwashapp/api/user/user_services.dart';
import 'package:carwashapp/layout/def_style.dart';
import 'package:carwashapp/service/items/car_item_info.dart';
import 'package:carwashapp/service/items/location_info.dart';
import 'package:carwashapp/users/userstate.dart';
import 'package:carwashapp/utils/dialogs.dart';
import 'package:carwashapp/utils/validators.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';

import 'api/service/model/login_platform.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({Key? key}) : super(key: key);

  @override
  State<LoginWidget> createState() => _LoginWidget();
}

class _LoginWidget extends State<LoginWidget> {
  late UserState _userState;
  final storage = const FlutterSecureStorage();
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final String _idlabel = '아이디';
  final String _passlabel = '비밀번호';
  final TextEditingController _idControl = TextEditingController();
  final TextEditingController _pswdControl = TextEditingController();
  bool _idSave = false;
  final FocusNode _pswdFocus = FocusNode();
  final FocusNode _submitFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      storage.read(key: "saveId").then((value) {
        if (value != null && value.isNotEmpty) {
          setState(() {
            _idSave = true;
            _idControl.text = value;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _idControl.dispose();
    _pswdControl.dispose();
    _pswdFocus.dispose();
    _submitFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _userState = Provider.of<UserState>(context, listen: false);
    // _idControl.text = "joker12344";
    // _pswdControl.text = '1234';
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _loginFormKey,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    Column(children: [
                      Text(
                        "대리세차",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                                color: DefStyle.mainColor,
                                fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      TextFormField(
                        key: const Key("userId"),
                        keyboardType: TextInputType.text,
                        controller: _idControl,
                        decoration: InputDecoration(
                          labelText: _idlabel,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) => CwValidators.userId(value),
                        onFieldSubmitted: (_) {
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
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_submitFocus);
                        },
                        decoration: InputDecoration(
                            labelText: _passlabel,
                            border: const OutlineInputBorder()),
                        validator: (value) => CwValidators.userPswd(value),
                      ),
                    ]),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text("아이디저장",
                          style: Theme.of(context).textTheme.bodyLarge),
                      value: _idSave,
                      onChanged: (bool? value) {
                        setState(() {
                          _idSave = value!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30, bottom: 20),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: DefStyle.btnActiveBackColor,
                          padding: const EdgeInsets.all(10),
                        ),
                        focusNode: _submitFocus,
                        child: Center(
                            child: Text('로그인',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(color: Colors.white))),
                        onPressed: () => _loginSubmit(),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                            width: width * 0.43,
                            height: 40,
                            child: _buildSnsLoginButton(
                                const Color.fromRGBO(252, 236, 79, 1),
                                "images/loginK.jpg")),
                        SizedBox(
                            width: width * 0.43,
                            height: 40,
                            child: _buildSnsLoginButton(
                                const Color.fromRGBO(90, 195, 102, 1),
                                "images/loginN.jpg"))
                      ],
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 30, bottom: 15),
                        child: Container(
                          height: 1,
                          color: Colors.black26,
                        )),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                            width: width * 0.29,
                            height: 40,
                            child: _buildSupportLoginButton("아이디 찾기")),
                        SizedBox(
                            width: width * 0.29,
                            height: 40,
                            child: _buildSupportLoginButton("비밀번호 찾기")),
                        SizedBox(
                            width: width * 0.29,
                            height: 40,
                            child: _buildSupportLoginButton("회원가입"))
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  ElevatedButton _buildSnsLoginButton(
    Color color,
    String imgasset,
  ) {
    return ElevatedButton(
      onPressed: () {
        (imgasset == "images/loginK.jpg") ? kakaoLogin() : naverLogin();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
      ),
      child: Image.asset(imgasset, height: 16),
    );
  }

  ElevatedButton _buildSupportLoginButton(
    String label,
  ) {
    return ElevatedButton(
        onPressed: () {
          if (label == "아이디 찾기") {
            findId();
          } else if (label == "비밀번호 찾기") {
            findPswd();
          } else {
            joinUser();
          }
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: DefStyle.btnDarkGrayBackColor,
            padding: const EdgeInsets.all(5)),
        child: Text(
          label,
          style: const TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
        ));
  }

  void kakaoLogin() async {
    await _kakaoLogin().then((value) async {
      if (kDebugMode) {
        print("retrun Type : ${value.runtimeType}");
      }
      if (value.runtimeType == OAuthToken) {
        value as OAuthToken;
        String token = value.accessToken;
        _snsLoginSubmit(LoginPlatform.kakao, token);
        //ACCESS_TOKEN
      } else {
        CwDialogs.alert(context, "카카오 로그인 처리중 오류가 발생했습니다.");
      }
    });
  }

  Future<dynamic> _kakaoLogin() async {
    if (await isKakaoTalkInstalled()) {
      try {
        debugPrint('카카오계정으로 로그인 성공');
        return await UserApi.instance.loginWithKakaoTalk();
      } catch (error) {
        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
        if (error is PlatformException && error.code == 'CANCELED') {
          debugPrint('카카오계정으로 로그인 실패 $error');
          return error;
        }
        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
        try {
          debugPrint('카카오계정으로 로그인 성공');
          return await UserApi.instance.loginWithKakaoAccount();
        } catch (error) {
          debugPrint('카카오계정으로 로그인 실패 $error');
          return error;
        }
      }
    } else {
      try {
        debugPrint('카카오계정으로 로그인 성공');
        return await UserApi.instance.loginWithKakaoAccount();
      } catch (error) {
        debugPrint('카카오계정으로 로그인 실패 $error');
        return error;
      }
    }
  }

  naverLogin() async {
    await _naverLogin().then((value) {
      if (value.runtimeType == NaverAccessToken) {
        value as NaverAccessToken;
        String token = value.accessToken;
        _snsLoginSubmit(LoginPlatform.naver, token);
        //ACCESS_TOKEN
      } else {
        CwDialogs.alert(context, "카카오 로그인 처리중 오류가 발생했습니다.");
      }
    });
  }

  Future<dynamic> _naverLogin() async {
    return await FlutterNaverLogin.logIn().then((res) async {
      NaverAccessToken res = await FlutterNaverLogin.currentAccessToken;
      return res;
    }).catchError((onError) {
      CwDialogs.alert(context, onError.toString());
      return onError;
    });
  }

  void findId() {
    if (kDebugMode) {
      print('find id');
    }
  }

  void findPswd() {
    if (kDebugMode) {
      print('find pwd');
    }
  }

  void joinUser() {
    Navigator.pushNamed(context, "/join");
  }

  void _goMain() {
    String target = _userState.provider() ? "/provider" : "/service";
    Navigator.pushNamedAndRemoveUntil(context, target, (route) => false);
  }

  void _closeModal() {
    Navigator.pop(context);
  }

  void _loginSubmit() async {
    if (_loginFormKey.currentState!.validate()) {
      CwDialogs.modalLoading(context, "로그인 처리 중입니다.");
      String retMsg = "";
      await UserService()
          .login(
        _idControl.text,
        _pswdControl.text,
        _userState.getFcmToken(),
        _userState.getPosition(),
      )
          .then(
        (json) async {
          var sessionManager = SessionManager();
          CarwashUser carwashUser = CarwashUser.fromJson(json);
          try {
            // todo : provider 로그인시 구분 필요
            if (carwashUser.userId.isNotEmpty &&
                carwashUser.userId == _idControl.text) {
              if (mounted) {
                await sessionManager.remove("user");
                await sessionManager.set("user", carwashUser);
              }
              _userState.signIn(carwashUser, LoginPlatform.carwash);
              if (json["cars"] != null) {
                (json["cars"] as List)
                    .map((val) => _userState.addCar(CarItem.fromJson(val)));
              }
              if (json["address"] != null) {
                (json["address"] as List).map((val) =>
                    _userState.addLocation(LocationInfo.fromJson(val)));
              }

              if (_idSave) {
                await storage.write(key: "saveId", value: _idControl.text);
              } else {
                await storage.delete(key: "saveId");
              }
            } else {
              await sessionManager.destroy();
              throw UnauthorizedException("로그인 정보 불일치");
            }
          } finally {
            _closeModal();
          }
          if (mounted &&
              Provider.of<UserState>(context, listen: false).isLogin()) {
            _goMain();
          } else {
            _idControl.text = "";
            _idControl.text = "";
            _pswdControl.text = "";
            await storage.delete(key: "saveId");
            if (mounted) {
              CwDialogs.alert(context, retMsg);
            }
          }
        },
      ).catchError(
        (e) async {
          _closeModal();
          if (e is UnauthorizedException) {
            retMsg = e.cause == "Bad credentials" ? "허용되지 않은 요청 입니다." : e.cause;
            if (retMsg.length > 50) {
              retMsg = "로그인 오류";
            }
          } else {
            retMsg = '로그인 오류';
          }
          if (mounted &&
              Provider.of<UserState>(context, listen: false).isLogin()) {
            _goMain();
          } else {
            _idControl.text = "";
            _idControl.text = "";
            _pswdControl.text = "";
            await storage.delete(key: "saveId");
            if (mounted) {
              CwDialogs.alert(context, retMsg);
            }
          }
        },
      );
    }
  }

  void _snsLoginSubmit(LoginPlatform loginType, String token) async {
    CwDialogs.modalLoading(context, "로그인 처리 중입니다.");
    String retMsg = "";
    await UserService()
        .loginSns(loginType, token, _userState.getFcmToken(),
            _userState.getPosition())
        .then((json) async {
      var sessionManager = SessionManager();
      CarwashUser carwashUser = CarwashUser.fromJson(json);
      try {
        if (carwashUser.userId.isNotEmpty) {
          if (mounted) {
            await sessionManager.remove("user");
            await sessionManager.set("user", carwashUser);
          }
          _userState.signIn(carwashUser, loginType);
          if (json["cars"] != null) {
            (json["cars"] as List)
                .map((val) => _userState.addCar(CarItem.fromJson(val)));
          }
          if (json["address"] != null) {
            (json["address"] as List).map(
                (val) => _userState.addLocation(LocationInfo.fromJson(val)));
          }
        } else {
          await sessionManager.destroy();
          throw UnauthorizedException("로그인 정보 불일치");
        }
      } on UnauthorizedException catch (e) {
        retMsg = e.cause == "Bad credentials" ? "허용되지 않은 요청 입니다." : e.cause;
        if (retMsg.length > 50) {
          retMsg = "로그인 오류";
        }
      } catch (e) {
        retMsg = '로그인 오류';
      } finally {
        _closeModal();
      }
      if (mounted && Provider.of<UserState>(context, listen: false).isLogin()) {
        _goMain();
      } else {
        _idControl.text = "";
        _idControl.text = "";
        _pswdControl.text = "";
        await storage.delete(key: "saveId");
        if (mounted) {
          CwDialogs.alert(context, retMsg);
        }
      }
    }).catchError((onError) {
      _closeModal();
      if (mounted) {
        CwDialogs.alert(context, retMsg);
      }
    });
  }
}
