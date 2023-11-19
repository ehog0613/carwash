import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/user/user_services.dart';
import '../users/userstate.dart';
import 'def_style.dart';

class RightMenuDrawer extends StatefulWidget {
  const RightMenuDrawer({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RightMenuDrawer createState()=>_RightMenuDrawer();
}

class _RightMenuDrawer extends State<RightMenuDrawer>{
  @override
  Widget build(BuildContext context) {
    UserState userState = Provider.of<UserState>(context, listen: false);
    return Drawer(
      child: ListView(
        // padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
              decoration: const BoxDecoration(color: Colors.indigoAccent),
              margin: const EdgeInsets.only(bottom: 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10,),
                  Text(
                      userState.name(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)
                  ),
                  const SizedBox(height: 10,),
                  Text(
                    userState.email(),style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      DefStyle.grayBtn("로그아웃", () async {
                        await UserService().logOut().then((value) {
                          userState.signOut();
                          Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
                        });})
                    ],
                  )
                ],
              )
          ),
          ListTile(
            leading: const Icon(Icons.local_car_wash,size: 32),
            title: Text("세차 서비스 요청", style: Theme.of(context).textTheme.titleMedium),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                  context, "/service", (route) => false);
            }
          ),
          ListTile(
            leading: const Icon(Icons.content_paste_outlined,size: 32),
            title: Text("서비스 요청 확인", style: Theme.of(context).textTheme.titleMedium,),
            onTap: (){
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, "/myorder",(route) => false);
            }
          )
        ],
      ),
    );
  }
}