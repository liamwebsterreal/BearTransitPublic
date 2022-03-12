import 'package:bear_transit_app/models/global.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class bearADs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Stack(
        children: <Widget>[
           Container(
             color: Colors.white,
           ),
          Container(
            padding: EdgeInsets.only(top: SizeConfig.safeBlockVertical * 12, left: SizeConfig.safeBlockHorizontal * 5, right: SizeConfig.safeBlockHorizontal * 5),
            alignment: Alignment.topCenter,
            child: ListView.builder(
              padding: EdgeInsets.only(),
              itemCount: 20,
              scrollDirection: Axis.vertical,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  child: Container(
                    padding: EdgeInsets.only(top: SizeConfig.safeBlockVertical * 2),
                    alignment: Alignment.center,
                    height: SizeConfig.safeBlockVertical * 25,
                    child: newsCardBuilder(),
                  ),
                  onTap: () => Scaffold
                      .of(context)
                      .showSnackBar(SnackBar(padding: EdgeInsets.all(50), content: Text(index.toString()))),
                );
              },
            ),
            ),
          Padding(
            padding: EdgeInsets.only(top: SizeConfig.safeBlockVertical * 5, left: SizeConfig.safeBlockHorizontal * 3, right: SizeConfig.safeBlockHorizontal * 3),
            child:
            SizedBox(
              height: SizeConfig.safeBlockVertical * 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(100),
                      topLeft: Radius.circular(100),
                      bottomLeft: Radius.circular(100),
                      bottomRight: Radius.circular(100)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black38, spreadRadius: 0, blurRadius: 10),
                  ],
                ),
              ),
            ),
          ),
          Container(
            alignment: Alignment.topCenter,
            padding: EdgeInsets.only(top: SizeConfig.safeBlockVertical * 5.5, left: SizeConfig.safeBlockHorizontal * 5, right: SizeConfig.safeBlockHorizontal * 5),
            child:
            Text("BearSocial", style: bearSpecialstyle,),
          ),
        ],
      ),
    );
  }
}

Widget newsCardBuilder() {
  return Container(
    width: SizeConfig.safeBlockHorizontal * 85,
    height: SizeConfig.safeBlockVertical * 32,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      color: Colors.white,
      boxShadow: [
        new BoxShadow(
          color: Colors.grey,
          blurRadius: 5.0,
        ),
      ],
    ),
    child: Text(
        "Coming Soon"
    ),
  );
}