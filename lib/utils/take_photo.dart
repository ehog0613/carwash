import 'dart:io';

import 'package:carwashapp/layout/def_style.dart';
import 'package:carwashapp/utils/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../api/service/provider_service.dart';

class TakePhoto extends StatefulWidget{
  final int _seq;
  const TakePhoto(int seq,{Key? key}) :_seq = seq,super(key: key);

  @override
  State<TakePhoto> createState() =>_TakePhoto();
}

class _TakePhoto extends State<TakePhoto>{
  XFile? image;
  final ImagePicker _picker = ImagePicker();
  late int _seq;
  @override
  Widget build(BuildContext context) {
    _seq = widget._seq;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('사진 등록',style: Theme.of(context).textTheme.titleMedium,),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final img = await _picker.pickImage(source: ImageSource.gallery);
                  setState(() {
                    image = img;
                  });
                },
                label: const Text('겔러리에서 가져 오기'),
                icon: const Icon(Icons.image),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    var status = await Permission.camera.status;
                    if(status.isDenied){
                      if(await Permission.contacts.request().isGranted){

                      }
                    }
                    final img = await _picker.pickImage(source: ImageSource.camera);
                    setState(() {
                      image = img;
                    });
                  }on PlatformException{
                    CwDialogs.alert(context,"카메라를 사용 할 수 없습니다.");
                  }
                },
                label: const Text('사진찍기'),
                icon: const Icon(Icons.camera_alt_outlined),
              ),
            ],
          ),
          if (image != null)
            Expanded(
              child: Column(
                children: [
                  Expanded(child: Image.file(File(image!.path))),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            image = null;
                          });
                        },
                        label: const Text('취소'),
                        icon: const Icon(Icons.close),
                        style: DefStyle.grayBtnStyle,
                      ),ElevatedButton.icon(
                        onPressed: () async {
                          /*setState(() {
                            image = null;
                          });*/
                          CwDialogs.modalLoading(context,"전송중");
                          await ProviderServices().uploadFile(_seq,image!).then((seq){
                            Navigator.pop(context);
                            image=null;
                            Navigator.pop(context,seq);
                          });
                        },
                        label: const Text('전송'),
                        icon: const Icon(Icons.send),
                        style: DefStyle.blueBtnStyle,
                      ),
                    ],
                  )
                ],
              ),
            )
          else
            const SizedBox(),
        ],
      ),
    );
  }
}
// // A widget that displays the picture taken by the user.
// class DisplayPictureScreen extends StatelessWidget {
//   final String imagePath;
//
//   const DisplayPictureScreen({super.key, required this.imagePath});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Display the Picture')),
//       // The image is stored as a file on the device. Use the `Image.file`
//       // constructor with the given path to display the image.
//       body: Image.file(File(imagePath)),
//     );
//   }
// }
