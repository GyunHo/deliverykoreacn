import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class DetailPage extends StatefulWidget {
  final String uid;
  final String apiKey;
  final String barcode;
  final Response response;

  const DetailPage(
      {Key key, this.response, this.barcode, this.apiKey, this.uid})
      : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
  String url = 'http://www.deliverykoreacn.com/openapi/change_order_status';

  List<dynamic> withWeight = [];
  List<dynamic> withoutWeight = [];
  List<List<TextEditingController>> withController;
  bool _isLoading = false;

  @override
  void initState() {
    Map<dynamic, dynamic> jsonData = jsonDecode(widget.response.data);
    List inWeight = [];
    List noWeight = [];
    if (jsonData['in_weight'] is Map) {
      List weight = jsonData['in_weight'].values.toList();
      inWeight = weight;
    } else {
      inWeight = jsonData['in_weight'];
    }
    if (jsonData['no_weight'] is Map) {
      List nweight = jsonData['no_weight'].values.toList();
      noWeight = nweight;
    } else {
      noWeight = jsonData['no_weight'];
    }

    inWeight.forEach((data) {
      List _in = data.split('|');
      withWeight.add(_in);
    });
    noWeight.forEach((data) {
      List _no = data.split('|');
      withoutWeight.add(_no);
    });

    print('무게필요 : $withWeight');
    print('무게필요 없음 : $withoutWeight');
    withController = List.generate(withWeight.length, (i) {
      return List.generate(5, (x) {
        return TextEditingController();
      });
    });
    super.initState();
  }

  Future<String> getDeliveryStatus(String idx) async {
    Dio dio = Dio();
    Response response = await dio.get(
        'http://www.deliverykoreacn.com/openapi/get_delivery',
        queryParameters: {
          'uid': widget.uid,
          'apikey': widget.apiKey,
          'order_idx': idx
        });
    Map<String, dynamic> decodeJson = json.decode(response.data);

    if (decodeJson['result'] == 'success') {
      String rackNo = decodeJson['data']['rack_no'];

      return rackNo.toString();
    }
    return '랙번호 없음';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      appBar: AppBar(
        title: Text(
          widget.barcode,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: ModalProgressHUD(
        inAsyncCall: _isLoading,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
              itemCount:
                  withWeight.isEmpty ? withoutWeight.length : withWeight.length,
              itemBuilder: (context, index) {
                return withWeight.isEmpty
                    ? withoutWeightWidget(index, context)
                    : withWeightWidget(index, context);
              }),
        ),
      ),
    );
  }

  Widget withoutWeightWidget(int index, BuildContext context) {
    List<dynamic> numbers = withoutWeight[index];
    return Container(
      margin: EdgeInsets.symmetric(vertical: 3.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.black, width: 2.0)),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('신청번호 : ${numbers[0]}'),
                Text('제품번호 : ${numbers[1]}'),
                FutureBuilder(
                  future: getDeliveryStatus(numbers[0]),
                  builder: (context, snapshot) {
                    if (snapshot.hasData ?? false) {
                      return Text('랙번호 : ${snapshot.data}');
                    }
                    return Text('랙번호 :');
                  },
                ),
              ],
            ),
            numbers[2] == 'N'
                ? Text('입고된 제품')
                : RaisedButton(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                    elevation: 10.0,
                    child: Text('입고처리'),
                    onPressed: () {
                      _onToggle();
                      Dio dio = Dio();
                      FormData data = FormData.fromMap({
                        'apikey': widget.apiKey,
                        'uid': widget.uid,
                        'd_idx': numbers[0],
                        'di_idx': numbers[1],
                        'status': '04',
                        'boxcnt': '',
                        'weight': '',
                        'volume_x': '',
                        'volume_y': '',
                        'volume_z': '',
                      });
                      internetCheck().then((internet) {
                        if (internet) {
                          _offToggle();
                          dio.post(url, data: data).then((re) {
                            Map<String, dynamic> jsonData = jsonDecode(re.data);
                            print(jsonData);
                            if (jsonData['error_code'] == '9999' ||
                                jsonData['error_code'] == '1010') {
                              showAfterSnackBar('서버 오류로 처리 되지 못했습니다.');
                            } else {
                              showAfterSnackBar(
                                  '입고 처리 완료. code:${jsonData['error_code']}');
                              setState(() {
                                withoutWeight[index][2] = 'N';
                              });
                            }
                          }).catchError((e) {
                            showAfterSnackBar('전송오류, 재시도 해주세요.');
                          });
                        } else {
                          _offToggle();
                          showAfterSnackBar('인터넷 없음');
                        }
                      });
                    },
                  )
          ],
        ),
        contentPadding: EdgeInsets.all(8.0),
      ),
    );
  }

  Widget withWeightWidget(int index, BuildContext context) {
    List<dynamic> numbers = withWeight[index];
    List<TextEditingController> controllers = withController[index];
    TextEditingController each = controllers[0];
    TextEditingController weight = controllers[1];
    TextEditingController width = controllers[2];
    TextEditingController height = controllers[3];
    TextEditingController depth = controllers[4];

    return Container(
      margin: EdgeInsets.symmetric(vertical: 3.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.black, width: 2.0)),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('신청번호 : ${numbers[0]}'),
                Text('제품번호 : ${numbers[1]}'),
                FutureBuilder(
                  future: getDeliveryStatus(numbers[0]),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text('랙번호 : ${snapshot.data}');
                    }
                    return Text('랙번호 : 없음');
                  },
                ),
              ],
            ),
            numbers[2] == 'N'
                ? Text('입고된 제품')
                : RaisedButton(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                    elevation: 10.0,
                    child: Text('입고처리'),
                    onPressed: () {
                      _onToggle();
                      if (each.text != '' &&
                          weight.text != '' &&
                          width.text != '' &&
                          height.text != '' &&
                          depth.text != '') {
                        Dio dio = Dio();
                        FormData data = FormData.fromMap({
                          'apikey': widget.apiKey,
                          'uid': widget.uid,
                          'd_idx': numbers[0],
                          'di_idx': numbers[1],
                          'status': '05',
                          'boxcnt': each.text,
                          'weight': weight.text,
                          'volume_x': width.text,
                          'volume_y': height.text,
                          'volume_z': depth.text,
                        });
                        internetCheck().then((internet) {
                          if (internet) {
                            _offToggle();
                            dio.post(url, data: data).then((re) {
                              Map<String, dynamic> jsonData =
                                  jsonDecode(re.data);
                              print(jsonData);
                              if (jsonData['error_code'] == '9999' ||
                                  jsonData['error_code'] == '1010') {
                                showAfterSnackBar('서버 오류로 처리 되지 못했습니다.');
                              } else {
                                showAfterSnackBar(
                                    '입고 처리 완료. code:${jsonData['error_code']}');
                                setState(() {
                                  withWeight[index][2] = 'N';
                                });
                              }
                            }).catchError((e) {
                              showAfterSnackBar('전송오류, 재시도 해주세요.');
                            });
                          } else {
                            _offToggle();
                            showAfterSnackBar('인터넷 없음');
                          }
                        });
                      } else {
                        _offToggle();
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text('수량,무게,사이즈는 0보다 커야 합니다.'),
                          duration: Duration(milliseconds: 1000),
                        ));
                      }
                    },
                  )
          ],
        ),
        contentPadding: EdgeInsets.all(8.0),
        subtitle: numbers[2] == 'N'
            ? SizedBox()
            : Container(
                width: double.infinity,
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: each,
                            decoration: InputDecoration(
                                labelText: '수량',
                                hintText: '박스수량',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4.0))),
                          ),
                        ),
                        Flexible(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: weight,
                            decoration: InputDecoration(
                                labelText: '무게',
                                hintText: '실제무게(Kg)',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4.0))),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: width,
                            decoration: InputDecoration(
                                labelText: '가로',
                                hintText: '가로(Cm)',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4.0))),
                          ),
                        ),
                        Flexible(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: height,
                            decoration: InputDecoration(
                                labelText: '세로',
                                hintText: '세로(Cm)',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4.0))),
                          ),
                        ),
                        Flexible(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: depth,
                            decoration: InputDecoration(
                                labelText: '너비',
                                hintText: '너비(Cm)',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4.0))),
                          ),
                        ),
                      ],
                    )
                  ],
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
}
