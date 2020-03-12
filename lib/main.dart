import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:com/detail.dart';

void main() {
  runApp(MaterialApp(
    home: MyScreen(),
  ));
}

class MyScreen extends StatefulWidget {
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  Response res;
  List<File> images = [];
  TextEditingController barcodeController = TextEditingController();
  File image;
  String url = 'http://www.deliverykoreacn.com/openapi/orderin_photo';
  String apikey = 'bmZus5vXIDndhwFaYe3OHk2f7';
  String uid = 'dkmobilescan';
  String trackno = '20204857457455';
  Dio dio = Dio();
  bool _isLoading = false;

  Future<Response> upto() async {
//    List<MultipartFile> uploadImages = [];
//    images.forEach((file) {
//      uploadImages.add(MultipartFile.fromFileSync(file.path));
//    });
//
//    print(uploadImages);

    Map<dynamic, dynamic> respon;
    FormData formData = FormData.fromMap({
      "apikey": apikey,
      'uid': uid,
      'tackno': trackno,
      'photo': MultipartFile.fromFileSync(images[0].path)
    });
    return await dio.post(url, data: formData);
  }

  void _toggle() {
    setState(() {
      _isLoading = true;
    });
    Future.delayed(Duration(seconds: 5)).then((_) {
      setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    FocusScopeNode currentFocus = FocusScope.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          '입고',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _isLoading,
        child: GestureDetector(
          onTap: () {
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: TextFormField(
                                  controller: barcodeController,
                                  decoration: InputDecoration(
                                    hintText: "바코드...",
                                    border: InputBorder.none,
                                  ),
                                  enabled: false,
                                ),
                              ),
                              RaisedButton(
                                elevation: 8.0,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)),
                                child: Text(
                                  '스캔',
                                ),
                                onPressed: () {
                                  upto().then((rep) {
                                    Map<dynamic, dynamic> res =
                                        jsonDecode(rep.data);
                                    if (res['error_code'] == '000') {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (BuildContext con) {
                                        return DetailPage(response: rep);
                                      }));
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text('사진 첨부'),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            children: <Widget>[
                              RaisedButton(
                                elevation: 8.0,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)),
                                child: Text(
                                  '카메라',
                                ),
                                onPressed: () async {
                                  await ImagePicker.pickImage(
                                          source: ImageSource.camera)
                                      .then((image) {
                                    setState(() {
                                      images.add(image);
                                    });
                                  });
                                },
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              RaisedButton(
                                elevation: 8.0,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)),
                                child: Text(
                                  '파일',
                                ),
                                onPressed: () async {
                                  await ImagePicker.pickImage(
                                          source: ImageSource.gallery)
                                      .then((image) {
                                    setState(() {
                                      images.add(image);
                                    });
                                  });
                                },
                              ),
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Container(
                                width: double.infinity,
                                height: size.height * 0.2,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: images.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Stack(
                                          children: <Widget>[
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              child: Image.file(
                                                images[index],
                                              ),
                                            ),
                                            Positioned(
                                              child: IconButton(
                                                icon: Icon(Icons.cancel),
                                                onPressed: () {
                                                  setState(() {
                                                    images.removeAt(index);
                                                  });
                                                },
                                              ),
                                              top: 0.0,
                                              right: 0.0,
                                            )
                                          ],
                                        ),
                                      );
                                    }),
                              ),
                              SizedBox(height: 5.0),
                              Container(
                                width: double.infinity,
                                height: size.height * 0.05,
                                child: RaisedButton(
                                  elevation: 10.0,
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  child: Text('전송'),
                                  onPressed: () {},
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
