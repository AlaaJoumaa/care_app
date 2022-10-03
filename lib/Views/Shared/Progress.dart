import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class Progress extends StatefulWidget {

  bool _shown = false;
  double _height = 0;

  Progress(this._shown,this._height);

  @override
  _ProgressState createState() => _ProgressState();
}

class _ProgressState extends StateMVC<Progress> {

  @override
  void initState() {
    super.initState();
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

      return new Visibility(child: new Column(children: <Widget>[
                                                 new Container(child: new Padding(child: new CircularProgressIndicator(
                                                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                                                      strokeWidth: 4),
                                                                      padding: EdgeInsets.only(top: 20),
                                                                    ),
                                                                    alignment: Alignment.center,
                                                                    color: Color(0xFF5F9F5).withOpacity(0.6),
                                                                    width: MediaQuery.of(context).size.width,
                                                                    height: widget._height
                                                              )
                                             ]),
                             visible: widget._shown);
  }
}