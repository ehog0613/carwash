import 'package:carwashapp/api/user/user_services.dart';
import 'package:carwashapp/layout/def_style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../users/userstate.dart';

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
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.grey,
            child: Text("세차 서비스", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),),
          ),
          ListTile(
            leading: const Icon(Icons.local_car_wash,size: 32),
            title: Text("접수 목록",style: Theme.of(context).textTheme.labelMedium,),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                  context, "/provider", (route) => false);
            }
          ),
          ListTile(
            leading: const Icon(Icons.content_paste_outlined,size: 32,),
            title: Text("접수 가능 서비스 조회1",style: Theme.of(context).textTheme.labelMedium,),
            onTap: (){
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, "/provider/find",(route) => false);
            }
          ),
          ListTile(
              leading: const Icon(Icons.gps_fixed_rounded,size: 32,),
              title: Text("접수 기준위치 지정",style: Theme.of(context).textTheme.labelMedium,),
              onTap: (){
                Navigator.pop(context);
                Navigator.pushNamed(context, "/provider/position");
              }
          )
        ],
      ),
    );
  }
}