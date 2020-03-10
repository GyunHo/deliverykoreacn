import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

enum DialogState {
  LOADING,
  COMPLETED,
  DISMISSED,
}

void main() {
  runApp(MaterialApp(
    home: MyScreen(),
  ));
}

class MyScreen extends StatefulWidget {
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  File image;
  String url = 'http://www.deliverykoreacn.com/openapi/orderin_photo';
  String apikey = 'bmZus5vXIDndhwFaYe3OHk2f7';
  String uid = 'dkmobilescan';
  String trackno = '20200218123456789';
  Dio dio = Dio();
  DialogState _dialogState = DialogState.DISMISSED;

  upto() async {
    image = await ImagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
//      String path = image.path;
//      String name = path.split('/').last;
      
      FormData formData = FormData.fromMap({
        "apikey": apikey,
        'uid': uid,
        'tackno': trackno,
        'photo': await MultipartFile.fromFile(image.path)
      });
      await dio.post(url, data: formData).then((response) {
        print(response.data);
      });
    }
  }

  void _exportData() {
    setState(() => _dialogState = DialogState.LOADING);
    Future.delayed(Duration(seconds: 5)).then((_) {
      setState(() => _dialogState = DialogState.DISMISSED);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              RaisedButton(
                child: Text('Show dialog'),
                onPressed: () {
                  upto();
                },
              ),
              MyDialog(
                state: _dialogState,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MyDialog extends StatelessWidget {
  final DialogState state;

  MyDialog({this.state});

  @override
  Widget build(BuildContext context) {
    return state == DialogState.DISMISSED
        ? Container()
        : AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            content: Container(
                width: 250.0,
                height: 100.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        "업로드..",
                        style: TextStyle(
                          fontFamily: "OpenSans",
                          color: Color(0xFF5B6978),
                        ),
                      ),
                    )
                  ],
                )),
          );
  }
}
