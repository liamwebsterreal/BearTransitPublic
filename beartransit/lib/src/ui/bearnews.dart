import 'package:beartransit/src/resources/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../app.dart';

class bearnews extends StatefulWidget {
  @override
  _bearnewsState createState() => _bearnewsState();
}
class _bearnewsState extends State<bearnews> {

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      alignment: Alignment.center,
      color: Colors.white,
      child: Text('bearnews',style: TitleStyle),
    );
  }
}
