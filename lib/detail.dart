import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

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
  String url = 'http://www.deliverykoreacn.com/openapi/change_order_status';
  List<dynamic> withWeight = [];
  List<dynamic> withoutWeight = [];
  List<List<TextEditingController>> withController;

  @override
  void initState() {
    Map<dynamic, dynamic> jsonData = jsonDecode(widget.response.data);
    withWeight.addAll(jsonData['in_weight']);
    withoutWeight.addAll(jsonData['no_weight']);
    print('무게필요 : $withWeight');
    print('무게필요 없음 : $withoutWeight');
    withController = List.generate(withWeight.length, (i) {
      return List.generate(5, (x) {
        return TextEditingController();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.barcode,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
            itemCount: withWeight.isEmpty ? withoutWeight.length : withWeight
                .length,
            itemBuilder: (context, index) {
              return withWeight.isEmpty
                  ? withoutWeightWidget(index, context)
                  : withWeightWidget(index, context);
            }),
      ),
    );
  }

  Widget withoutWeightWidget(int index, BuildContext context) {
    List<dynamic> numbers = withoutWeight[index].split('|');
    return numbers[2] == 'N' ? SizedBox() : Container(
      margin: EdgeInsets.symmetric(vertical: 3.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.black, width: 2.0)),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: <Widget>[
                Text('신청번호 : ${numbers[0]}'),
                Text('제품번호 : ${numbers[1]}')
              ],
            ),
            numbers[2] == 'N' ? Text('이미 입고된 제품'):RaisedButton(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              elevation: 10.0,
              child: Text('일부입고처리'),
              onPressed: () {
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
                dio.post(url, data: data).then((re) {
                  setState(() {
                    numbers[2]='N';
                  });
                  print(re.data);
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
    List<dynamic> numbers = withWeight[index].split('|');
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
              children: <Widget>[
                Text('신청번호 : ${numbers[0]}'),
                Text('제품번호 : ${numbers[1]}')
              ],
            ),
            numbers[2] == 'N' ? Text('이미 입고된 제품') : RaisedButton(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              elevation: 10.0,
              child: Text('입고완료처리'),
              onPressed: () {
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
                  dio.post(url, data: data).then((re) {
                    print(re.data);
                  });
                } else {
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
        subtitle: numbers[2]=='N'?SizedBox():Container(
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
}
