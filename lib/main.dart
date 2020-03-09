import 'dart:async';

import 'package:flutter/material.dart';

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
  DialogState _dialogState = DialogState.DISMISSED;

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
                onPressed: () => _exportData(),
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
              child: state == DialogState.LOADING
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            "Exporting...",
                            style: TextStyle(
                              fontFamily: "OpenSans",
                              color: Color(0xFF5B6978),
                            ),
                          ),
                        )
                      ],
                    )
                  : Center(
                      child: Text('Data loaded with success'),
                    ),
            ),
          );
  }
}
