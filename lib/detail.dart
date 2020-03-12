import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class DetailPage extends StatefulWidget {
  final Response response;

  const DetailPage({Key key, this.response}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List<dynamic> in_weight = [];
  List<dynamic> no_weight = [];

  @override
  void initState() {
    Map<dynamic, dynamic> jsonData = jsonDecode(widget.response.data);
    in_weight.addAll(jsonData['in_weight']);
    no_weight.addAll(jsonData['no_weight']);
    print(in_weight);
    print(no_weight);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
