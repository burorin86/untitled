// import 'package:flutter/material.dart';
//
// // image_picker
// import 'package:image_picker/image_picker.dart';
//
// // image_gallery_saver
// import 'package:image_gallery_saver/image_gallery_saver.dart';
//
// import 'dart:io'; //File
// import 'dart:typed_data'; // Uint8List
//
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: MyHomePage(title: 'image_gallery_saver'),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key? key, required this.title}) : super(key: key);
//
//   final String title;
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   late File _image;
//   final picker = ImagePicker();
//
//   // 画像の読み込み
//   Future _getImage() async {
//     //final pickedFile = await picker.getImage(source: ImageSource.camera);//カメラ
//     final pickedFile = await picker.getImage(source: ImageSource.gallery);//アルバム
//
//     if(pickedFile != null) {
//       setState((){
//         _image = File(pickedFile.path);
//       });
//     }
//   }
//
//   // 画像の保存
//   Future _saveImage() async {
//     if(_image != null) {
//       Uint8List _buffer = await _image.readAsBytes();
//       final result = await ImageGallerySaver.saveImage(_buffer);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             _image == null
//                 ? Text('No image selected.')
//                 : Image.file(_image),
//             RaisedButton(
//               child: Text('Save'),
//               onPressed: _saveImage,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _getImage,
//         tooltip: 'Pick',
//         child: Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Save image to gallery',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _requestPermission();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("画像保存練習"),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Column(
              children: <Widget>[
                RepaintBoundary(
                  key: _globalKey,
                  child: Image.asset('images/main.png;compress=true.png'),
                ),
                Container(
                  padding: EdgeInsets.only(top: 15),
                  child: RaisedButton(
                    onPressed: _saveScreen,
                    child: Text("本当に保存しますか？"),
                  ),
                  width: 200,
                  height: 44,
                ),
                // Container(
                //   padding: EdgeInsets.only(top: 15),
                //   child: RaisedButton(
                //     onPressed: _getHttp,
                //     child: Text("Save network image"),
                //   ),
                //   width: 200,
                //   height: 44,
                // ),
                // Container(
                //   padding: EdgeInsets.only(top: 15),
                //   child: RaisedButton(
                //     onPressed: _saveVideo,
                //     child: Text("Save network video"),
                //   ),
                //   width: 200,
                //   height: 44,
                // ),
                // Container(
                //   padding: EdgeInsets.only(top: 15),
                //   child: RaisedButton(
                //     onPressed: _saveGif,
                //     child: Text("Save Gif to gallery"),
                //   ),
                //   width: 200,
                //   height: 44,
                // ),
              ],
            ),
          ),
        ));
  }

  _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    final info = statuses[Permission.storage].toString();
    print(info);
    _toastInfo(info);
  }

  _saveScreen() async {
    RenderRepaintBoundary boundary =
    _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await (image.toByteData(format: ui.ImageByteFormat.png) as FutureOr<ByteData?>);
    if (byteData != null) {
      final result =
      await ImageGallerySaver.saveImage(byteData.buffer.asUint8List());
      print(result);
      _toastInfo(result.toString());
    }
  }

  // _getHttp() async {
    //   var response = await Dio().get(
    //       "https://ss0.baidu.com/94o3dSag_xI4khGko9WTAnF6hhy/image/h%3D300/sign=a62e824376d98d1069d40a31113eb807/838ba61ea8d3fd1fc9c7b6853a4e251f94ca5f46.jpg",
    //       options: Options(responseType: ResponseType.bytes));
    //   final result = await ImageGallerySaver.saveImage(
    //       Uint8List.fromList(response.data),
    //       quality: 60,
    //       name: "hello");
    //   print(result);
    //   _toastInfo("$result");
    // }
    //
    // _saveGif() async {
    //   var appDocDir = await getTemporaryDirectory();
    //   String savePath = appDocDir.path + "/temp.gif";
    //   String fileUrl =
    //       "https://hyjdoc.oss-cn-beijing.aliyuncs.com/hyj-doc-flutter-demo-run.gif";
    //   await Dio().download(fileUrl, savePath);
    //   final result = await ImageGallerySaver.saveFile(savePath);
    //   print(result);
    //   _toastInfo("$result");
    // }
    //
    // _saveVideo() async {
    //   var appDocDir = await getTemporaryDirectory();
    //   String savePath = appDocDir.path + "/temp.mp4";
    //   String fileUrl =
    //       "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4";
    //   await Dio().download(fileUrl, savePath, onReceiveProgress: (count, total) {
    //     print((count / total * 100).toStringAsFixed(0) + "%");
    //   });
    //   final result = await ImageGallerySaver.saveFile(savePath);
    //   print(result);
    //   _toastInfo("$result");
    // }

  _toastInfo(String info) {
    Fluttertoast.showToast(msg: info, toastLength: Toast.LENGTH_LONG);
  }
}
