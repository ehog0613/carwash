import 'dart:async';
import 'dart:convert';

import 'package:carwashapp/api/service/model/sys_info.dart';
import 'package:carwashapp/login.dart';
import 'package:carwashapp/provider/find_order.dart';
import 'package:carwashapp/provider/provider_order_list.dart';
import 'package:carwashapp/provider/provider_position.dart';
import 'package:carwashapp/service/extra.dart';
import 'package:carwashapp/service/items/car_item_info.dart';
import 'package:carwashapp/service/items/location_info.dart';
import 'package:carwashapp/service/service.dart';
import 'package:carwashapp/service/service_order_info.dart';
import 'package:carwashapp/users/join.dart';
import 'package:carwashapp/users/my_order_list.dart';
import 'package:carwashapp/users/userstate.dart';
import 'package:carwashapp/utils/carwash_util.dart';
import 'package:carwashapp/utils/constant.dart';
import 'package:carwashapp/utils/dialogs.dart';
import 'package:carwashapp/utils/geo_util.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'api/api.dart';
import 'api/service/model/login_platform.dart';
import 'api/user/carwash_user.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
bool _refreshAllChildrenAfterWakeup = false;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await setupFlutterNotifications();
  showFlutterNotification(message);
  if (kDebugMode) {
    print("Background Message : ${message.messageId}");
  }
}

late AndroidNotificationChannel channel;
bool isFlutterLocalNotificationsInitialized = false;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }

  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null && !kIsWeb) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          // TODO add a proper drawable resource to android, for now using
          //      one that already exists in example app.
          icon: 'launch_background',
        ),
      ),
    );
  }
}

late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
late FirebaseMessaging messaging;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (kDebugMode) {
    print('User granted permission: ${settings.authorizationStatus}');
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  if (!kIsWeb) {
    await setupFlutterNotifications();
  }
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  KakaoSdk.init(
    nativeAppKey: KakaoKey.NATIVE_KEY,
    javaScriptAppKey: KakaoKey.JS_KEY,
  );
  AuthRepository.initialize(appKey: KakaoKey.JS_KEY);

  // if (Platform.isAndroid) {
  //   await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  //   var swAvailable = await AndroidWebViewFeature.isFeatureSupported(
  //       AndroidWebViewFeature.SERVICE_WORKER_BASIC_USAGE);
  //   var swInterceptAvailable = await AndroidWebViewFeature.isFeatureSupported(
  //       AndroidWebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);
  //
  //   if (swAvailable && swInterceptAvailable) {
  //     AndroidServiceWorkerController serviceWorkerController =
  //     AndroidServiceWorkerController.instance();
  //
  //     await serviceWorkerController
  //         .setServiceWorkerClient(AndroidServiceWorkerClient(
  //       shouldInterceptRequest: (request) async {
  //         if (kDebugMode) {
  //           print(request);
  //         }
  //         return null;
  //       },
  //     ));
  //   }
  // }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserState()),
        ChangeNotifierProvider(create: (_) => ServiceOrder()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'CarWash Default',
        navigatorKey: navigatorKey,
        theme: ThemeData(
            primarySwatch: Colors.lightBlue,
            fontFamily: "NanumBarunGothic",
            // textTheme: const TextTheme(
            //   headline1: TextStyle(fontSize: 113, fontWeight: FontWeight.w300, letterSpacing: -1.5),
            //   headline2: TextStyle(fontSize: 71, fontWeight: FontWeight.w300, letterSpacing: -0.5),
            //   headline3: TextStyle(fontSize: 57, fontWeight: FontWeight.w400),
            //   headline4: TextStyle(fontSize: 40, fontWeight: FontWeight.w400, letterSpacing: 0.25),
            //   headline5: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
            //   headline6: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, letterSpacing: 0.15),
            //   subtitle1: TextStyle(fontSize: 19, fontWeight: FontWeight.w400, letterSpacing: 0.15),
            //   subtitle2: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.1),
            //   labelMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, letterSpacing: 1.0),
            //   bodyText1: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, letterSpacing: 0.5),
            //   bodyText2: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, letterSpacing: 0.25),
            //   button: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 1.25),
            //   caption: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, letterSpacing: 0.4),
            //   overline: TextStyle(fontSize: 9, fontWeight: FontWeight.w400, letterSpacing: 1.5),
            // ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Color.fromRGBO(31, 94, 190, 1),
              titleTextStyle: TextStyle(fontSize: 24, letterSpacing: 0.15),
            )),
        initialRoute: "/",
        routes: {
          "/": (context) => const Intro(),
          "/login": (context) => const LoginWidget(),
          "/join": (context) => const JoinWidget(),
          "/service": (context) => const ServiceMainApp(),
          "/service/extra": (context) => const ServiceExtra(),
          "/myorder": (context) => const MyOrderList(),
          //   "/kakaomap": (context) => const KakaoMapTest(),
          "/provider": (context) => const ProviderOrderList(),
          "/provider/find": (context) => const FindOrder(),
          "/provider/position": (context) => const ProviderPosition(),
          //"/provider":(context)=>const ProviderMain()
        });
  }
}

class Intro extends StatefulWidget {
  const Intro({Key? key}) : super(key: key);

  @override
  State<Intro> createState() => _Intro();
}

class _Intro extends State<Intro> {
  late PackageInfo _packageInfo;
  final storage = const FlutterSecureStorage();
  String _statusText = "로딩중";
  late UserState _userState;

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  // todo 메시지 오픈 처리
  void _handleMessage(RemoteMessage message) {
    /*
    if (message.data['type'] == 'chat') {
      Navigator.pushNamed(context, '/chat',
        arguments: ChatArguments(message),
      );
    }*/
    if (kDebugMode) {
      print("$message");
    }
  }

  @override
  void initState() {
    super.initState();
    setupInteractedMessage();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _initedApp(context);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _userState = Provider.of<UserState>(context, listen: false);
    // if(_refreshAllChildrenAfterWakeup == true) {
    //   _refreshAllChildrenAfterWakeup = false;
    //   _rebuildAllChildren(context);
    // }
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("images/loading1.gif"),
            const SizedBox(
              height: 60,
            ),
            Text(_statusText)
          ],
        ),
      ),
    );
  }

  void _initedApp(BuildContext context) {
    if (_statusText == '로딩중') {
      messaging.getToken().then((token) {
        _userState.setFcmToken(token ?? "");
      });
      _needVersionUpdate().then((needUpdate) async {
        if (needUpdate) {
          CwDialogs.exitAlert(context, "새로운 버전이 있습니다. 업데이트 후 다시 시도해주세요.");
          return;
        }
        await _getLocation();
        await _userInfo().then((userType) {
          if (userType == "PROVIDER") {
            Navigator.pushNamedAndRemoveUntil(
                context, "/provider", (route) => false);
          } else if (userType == "CUSTOMER") {
            Navigator.pushNamedAndRemoveUntil(
                context, "/service", (route) => false);
          } else {
            Navigator.pushNamedAndRemoveUntil(
                context, "/login", (route) => false);
          }
        }).catchError((error) {
          CwDialogs.exitAlert(context, "서버통신 오류 uchk.");
        });
      }).catchError((error) {
        CwDialogs.exitAlert(context, error.toString());
      });
    }
  }

  Future<bool> _needVersionUpdate() async {
    setState(() {
      _statusText = "기본 정보 확인중";
    });

    return await _getLastVersion().then((appInfo) async {
      _packageInfo = await PackageInfo.fromPlatform();
      return (CarwashUtil.parseVersionStr(_packageInfo.version) <
          CarwashUtil.parseVersionStr(appInfo.memo));
    });
  }

  Future<SysInfo> _getLastVersion() async {
    return await Api().dio.get("/init/current").then((response) {
      final Map<String, dynamic> body = response.data;
      if (response.statusCode == 200 && body["data"] != null) {
        return SysInfo.fromJson(body['data'][0]);
      } else {
        throw Exception("서버통신중 오류가 발생했습니다. 네트웤 상태를 확인 하신 후 다시 시도해주세요.");
      }
    }).catchError((onError) {
      throw Exception("서버통신중 오류가 발생했습니다. 네트웤 상태를 확인 하신 후 다시 시도해주세요.");
    });
  }

  Future<void> _getLocation() async {
    try {
      Position? position = await GeoUtil.determinePosition();
      _userState.setPosition(position);
    } on PermissionDeniedException {
      CwDialogs.exitAlert(context, "위치정보 확인 권한을 허용해주셔야 합니다.");
    } on LocationServiceDisabledException {
      CwDialogs.exitAlert(context, "위치정보를 활성화 후 다시 시도해주세요.");
    }
  }

  Future<dynamic> _userInfo() async {
    setState(() {
      _statusText = "이용자 정보 확인";
    });
    Position? pos = _userState.getPosition();
    dynamic _data = {
      "fcmToken": _userState.getFcmToken(),
      "lat": pos?.latitude ?? "",
      "lng": pos?.longitude ?? ""
    };
    late LoginPlatform loginPlatform;
    try {
      String? platform = await storage.read(key: "loginPlatform");
      if (platform != null) {
        loginPlatform = LoginPlatform.fromString(platform);
      } else {
        loginPlatform = LoginPlatform.carwash;
      }
    } catch (error) {
      if (kDebugMode) {
        print("$error");
      }
      loginPlatform = LoginPlatform.carwash;
    }

    return await Api()
        .dio
        .post(Api.userInfonUrl, data: _data)
        .then((response) async {
      if (response.statusCode == 200 && response.data != null) {
        Map<String, dynamic> body = response.data;
        CarwashUser user = CarwashUser.fromJson(body['data']);
        storage.write(key: "userInfo", value: jsonEncode(user));
        var sessionManager = SessionManager();
        await sessionManager.remove("user");
        await sessionManager.set("user", user);

        _userState.signIn(user, loginPlatform);
        if (body['data']["cars"] != null) {
          (body['data']["cars"] as List)
              .map((val) => _userState.addCar(CarItem.fromJson(val)));
        }
        if (body['data']["address"] != null) {
          (body['data']["address"] as List)
              .map((val) => _userState.addLocation(LocationInfo.fromJson(val)));
        }
        return user.userType;
      } else {
        return false;
      }
    }).catchError((error) {
      return false;
    });
  }

//
// @override
// void reassemble() {
//   super.reassemble();
//   setState(() { _refreshAllChildrenAfterWakeup = true; });
//
// }
//
// void _rebuildAllChildren(BuildContext context) {
//   void rebuild(Element el) {
//     el.markNeedsBuild();
//     el.visitChildren(rebuild);
//   }
//   (context as Element).visitChildren(rebuild);
// }
}
