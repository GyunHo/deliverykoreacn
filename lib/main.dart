import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:DeliveryKorea/detail.dart';
import 'package:connectivity/connectivity.dart';

import 'package:qrscan/qrscan.dart' as scan;

void main() {
  runApp(MaterialApp(
    home: MyScreen(),
  ));
}

class MyScreen extends StatefulWidget {
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
  List<File> images = [];
  TextEditingController barcodeController = TextEditingController();
  String url = 'http://www.deliverykoreacn.com/openapi/orderin_photo';
  String apikey = 'bmZus5vXIDndhwFaYe3OHk2f7';
  String uid = 'dkmobilescan';

  Dio dio = Dio();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    FocusScopeNode currentFocus = FocusScope.of(context);
    return Scaffold(
      key: _globalKey,
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
                                    hintText: "바코드를 스캔하세요...",
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
                                  scan.scan().then((code) {
                                    setState(() {
                                      barcodeController.text = code;
                                    });
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
                                onPressed: () {
                                  addImage(ImageSource.camera);
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
                                onPressed: () {
                                  addImage(ImageSource.gallery);
                                },
                              ),
                            ],
                          ),
                          images.length == 0
                              ? SizedBox()
                              : Column(
                                  children: <Widget>[
                                    Container(
                                      width: double.infinity,
                                      height: size.height * 0.2,
                                      child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: images.length,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Stack(
                                                children: <Widget>[
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    child: Image.file(
                                                      images[index],
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    child: IconButton(
                                                      icon: Icon(Icons.cancel),
                                                      onPressed: () {
                                                        setState(() {
                                                          images
                                                              .removeAt(index);
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
                                        onPressed: () {
                                          _onToggle();

                                          internetCheck().then((internet) {
                                            if (internet) {
//                                              String barcode = barcodeController.text;
                                              String barcode = '8806011615408';
                                              upLoad(barcode).then((rep) {
                                                Map<dynamic, dynamic> res =
                                                    jsonDecode(rep.data);
                                                if (res['error_code'] ==
                                                    '000') {
                                                  _clearInfo();
                                                  _offToggle();

                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(builder:
                                                          (BuildContext con) {
                                                    return DetailPage(
                                                      response: rep,
                                                      barcode: barcode,
                                                      apiKey: apikey,
                                                      uid: uid,
                                                    );
                                                  }));
                                                } else {
                                                  showAfterSnackBar(
                                                      res['error_detail']);
                                                }
                                              }).catchError((e) {
                                                showAfterSnackBar('어플 오류');
                                              });
                                            } else {
                                              showAfterSnackBar('인터넷 연결상태 확인');
                                            }
                                          });
                                        },
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

  Future<bool> internetCheck() async {
    ConnectivityResult result = await (Connectivity().checkConnectivity());
    if (result == ConnectivityResult.mobile) {
      return true;
    } else if (result == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  Future<Response> upLoad(String barcode) async {
    Map<String, dynamic> entry = {
      "apikey": apikey,
      'uid': uid,
      'trackno': barcode
    };
    for (int i = 0; i < images.length; i++) {
      entry['photo_$i'] = MultipartFile.fromFileSync(images[i].path);
    }
    FormData formData = FormData.fromMap(entry);
    return await dio.post(url, data: formData);
  }

  void _clearInfo() {
    images.clear();
    barcodeController.text = '';
  }

  void _onToggle() {
    setState(() {
      _isLoading = true;
    });
  }

  void _offToggle() {
    setState(() {
      _isLoading = false;
    });
  }

  void showAfterSnackBar(String message) {
    _offToggle();
    _globalKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(milliseconds: 1000),
    ));
  }

  void addImage(ImageSource source) async {
    await ImagePicker.pickImage(source: source).then((image) {
      if (image != null) {
        setState(() {
          images.add(image);
        });
      }
    });
  }
}
