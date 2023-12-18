import 'package:carwashapp/users/userstate.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/user/user_services.dart';
import '../main.dart';

// ignore: must_be_immutable
class DefAppBar extends StatefulWidget implements PreferredSizeWidget {
  const DefAppBar({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AppBar();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(80);
}

class _AppBar extends State<DefAppBar> {
  double _statusBarHeight = 0.0;
  final int _notiCount = 0;
  late UserState _userState;
  ScaffoldState? _scaffoldState;

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen(showFlutterNotification);
  }

  @override
  Widget build(BuildContext context) {
    _userState = Provider.of<UserState>(context, listen: false);
    _statusBarHeight = MediaQuery.of(context).padding.top;
    _scaffoldState ??= context.findRootAncestorStateOfType<ScaffoldState>()!;
    return Container(
        padding: EdgeInsets.only(top: _statusBarHeight + 10, left: 20),
        color: Colors.blue,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "안녕하세요.",
                  style: TextStyle(fontSize: 15),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${_userState.name()} 님",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                _notiCount > 0
                    ? IconButton(
                        icon: const Icon(Icons.notifications_none_outlined,
                            color: Colors.black26),
                        onPressed: () async {
                          await UserService().logOut().then((value) {
                            _userState.signOut();
                            Navigator.pushNamedAndRemoveUntil(
                                context, "/login", (route) => false);
                          });
                        })
                    : const SizedBox(
                        width: 0,
                      ),
                const SizedBox(
                  width: 5,
                ),
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    _scaffoldState!.openEndDrawer();
                  },
                ),
                const SizedBox(
                  width: 10,
                )
                // IconButton(onPressed: (){}, icon: Image.asset("images/hdBell.png")),
                // IconButton(onPressed: (){}, icon: Image.asset("images/gnbOpn.png"))
              ],
            )
          ],
        ));
  }
}
