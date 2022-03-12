import 'package:bear_transit_app/models/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;

import '../main.dart';

class bearnews extends StatefulWidget {
  @override
  _bearnewsState createState() => _bearnewsState();
}

class _bearnewsState extends State<bearnews> {

  bool pressed = false;
  bool pressed2 = true;
  late int storyIndex;
  late List<String> data = [];

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Stack(
        children: <Widget>[

          Container(
            color: Colors.white,
          ),
          pressed2 ? FutureBuilder(builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // If we got an error
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    '${snapshot.error} occured',
                    style: TextStyle(fontSize: 18),
                  ),
                );

                // if we got our data
              } else if (snapshot.hasData) {
                // Extracting data from snapshot object
                data = snapshot.data as List<String>;
                return Container(
                  padding: EdgeInsets.only(top: SizeConfig.safeBlockVertical * 6, bottom: SizeConfig.safeBlockVertical * 5, left: SizeConfig.safeBlockHorizontal * 5, right: SizeConfig.safeBlockHorizontal * 5),
                  alignment: Alignment.topCenter,
                  child: ListView.builder(
                    itemCount: 8,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        child: Container(
                            padding: EdgeInsets.only(top: SizeConfig.safeBlockVertical * 2),
                            alignment: Alignment.center,
                            height: SizeConfig.safeBlockVertical * 25,
                            child: newsCardBuilder(index, data)
                        ),
                        onTap: () {
                          setState(() {
                            pressed = true;
                            pressed2 = false;
                            storyIndex = index;
                          });
                        }
                      );
                    },
                  ),
                );
              }
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
            future: extractData(),
          ) : Container(),
          pressed ? Container(alignment: Alignment.bottomCenter, child: detailStorycard(storyIndex, data)) : Container(),
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
            padding: EdgeInsets.only(top: SizeConfig.safeBlockVertical * 5),
            child: Text(
              "BearNews", style: bearMapstyle,
            ),
          ),
       ],
      ),
    );
  }
  Widget newsCardBuilder(int index, List<String> titles) {
    return Container(
      alignment: Alignment.center,
      child: Stack(
        children: [
          Opacity(opacity: 1,
            child: Container(
              width: SizeConfig.safeBlockHorizontal * 85,
              height: SizeConfig.safeBlockVertical * 32,
              decoration: BoxDecoration(
                image: DecorationImage(
                  colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.9), BlendMode.dstATop),
                  fit: BoxFit.fill,
                  image: NetworkImage(titles[index + 8]),
                ),
              borderRadius: BorderRadius.all(Radius.circular(20)),
              boxShadow: [
                new BoxShadow(
                  color: Colors.grey,
                  blurRadius: 5.0,
                ),
              ],
              ),
              child: Container(
                alignment: Alignment.bottomLeft,
                padding: EdgeInsets.all( SizeConfig.safeBlockHorizontal * 2),
                  child: Stack(
                  children: <Widget>[
                  // Stroked text as border.
                  Text(
                    titles[index],
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: 'Gotham',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 2
                        ..color = Color(0xff003262),
                    ),
                  ),
                  // Solid text as fill.
                  Text(
                    titles[index],
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: 'Gotham',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
              ),
            ),
          ),
        ],
    ),
    );
  }
  Widget detailStorycard(int index, List<String> titles) {
    return Padding(
            padding: EdgeInsets.only(top: SizeConfig.safeBlockVertical * 14, bottom: SizeConfig.safeBlockVertical * 9, left: SizeConfig.safeBlockHorizontal * 1, right: SizeConfig.safeBlockHorizontal * 1),
            child: Container(
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
              child: Stack(
                children: [Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: SizeConfig.safeBlockVertical * 2, left: SizeConfig.safeBlockHorizontal * 1, right: SizeConfig.safeBlockHorizontal * 1),
                      child:
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: SizeConfig.safeBlockHorizontal * 1, right: SizeConfig.safeBlockHorizontal * 1),
                            child: Container(
                              child: IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    pressed = false;
                                    pressed2 = true;
                                    storyIndex = 0;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: SizeConfig.safeBlockHorizontal * 1, right: SizeConfig.safeBlockHorizontal * 1),
                      child:
                      Opacity(opacity: 1,
                        child: Container(
                          width: SizeConfig.safeBlockHorizontal * 90,
                          height: SizeConfig.safeBlockVertical * 25,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.9), BlendMode.dstATop),
                              fit: BoxFit.fill,
                              image: NetworkImage(titles[index + 8]),
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            boxShadow: [
                              new BoxShadow(
                                color: Colors.grey,
                                blurRadius: 5.0,
                              ),
                            ],
                          ),
                          child: Container(
                              alignment: Alignment.bottomLeft,
                              padding: EdgeInsets.all( SizeConfig.safeBlockHorizontal * 2),
                              child: Stack(
                                children: <Widget>[
                                  // Stroked text as border.
                                  Text(
                                    titles[index],
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontFamily: 'Gotham',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      foreground: Paint()
                                        ..style = PaintingStyle.stroke
                                        ..strokeWidth = 2
                                        ..color = Color(0xff003262),
                                    ),
                                  ),
                                  // Solid text as fill.
                                  Text(
                                    titles[index],
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontFamily: 'Gotham',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              )
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(top: SizeConfig.safeBlockVertical * 35, bottom: SizeConfig.safeBlockVertical * 1, left: SizeConfig.safeBlockHorizontal * 5, right: SizeConfig.safeBlockHorizontal * 5),
                  child: Expanded(
                    //contains a single child which is scrollable
                    child: SingleChildScrollView(
                      //for horizontal scrolling
                      scrollDirection: Axis.vertical,
                      child: Text(
                        'hellp',
                        style: techCardBodyStyle,
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ),
                ),
              ],
              ),
            ),
        );
  }

}
Future<List<String>> extractData() async {
//Getting the response from the targeted url
  final response =
  await http.Client().get(Uri.parse('https://news.berkeley.edu/'));
  //Status Code 200 means response has been received successfully
  if (response.statusCode == 200) {
    //Getting the html document from the response
    var document = parser.parse(response.body);
    try {
      //Scraping the first article title
      var responseString1 = document
          .getElementsByClassName('story-grid')[0]
          .children[0]
          .children[0]
          .children[0]
          .children[0]
          .children[0]
          .children[1]
          .children[1];

      var responseString2 = document
          .getElementsByClassName('story-grid')[0]
          .children[0]
          .children[0]
          .children[0]
          .children[1]
          .children[0]
          .children[1]
          .children[1];

      var responseString3 = document
          .getElementsByClassName('story-grid')[0]
          .children[0]
          .children[0]
          .children[0]
          .children[2]
          .children[0]
          .children[1]
          .children[1];

      var responseString4 = document
          .getElementsByClassName('story-grid')[0]
          .children[0]
          .children[0]
          .children[0]
          .children[3]
          .children[0]
          .children[1]
          .children[1];

      var responseString5 = document
          .getElementsByClassName('story-grid')[0]
          .children[0]
          .children[0]
          .children[0]
          .children[4]
          .children[0]
          .children[1]
          .children[1];

      var responseString6 = document
          .getElementsByClassName('story-grid')[0]
          .children[0]
          .children[0]
          .children[0]
          .children[5]
          .children[0]
          .children[1]
          .children[1];

      var responseString7 = document
          .getElementsByClassName('story-grid')[0]
          .children[0]
          .children[0]
          .children[0]
          .children[6]
          .children[0]
          .children[1]
          .children[1];

      var responseString8 = document
          .getElementsByClassName('story-grid')[0]
          .children[0]
          .children[0]
          .children[0]
          .children[7]
          .children[0]
          .children[1]
          .children[1];

      var responseString9 = document
          .getElementsByClassName('story-grid')[0]
          .children[0]
          .children[0]
          .children[0]
          .children[0]
          .children[0]
          .children[0]
          .getElementsByTagName('img')[0].attributes['src'];

      var responseString10 = document
          .getElementsByClassName('story-grid')[0]
          .children[0]
          .children[0]
          .children[0]
          .children[1]
          .children[0]
          .children[0]
          .getElementsByTagName('img')[0].attributes['src'];

      var responseString11 = document
          .getElementsByClassName('story-grid')[0]
          .children[0]
          .children[0]
          .children[0]
          .children[2]
          .children[0]
          .children[0]
          .getElementsByTagName('img')[0].attributes['src'];

      var responseString12 = document
          .getElementsByClassName('story-grid')[0]
          .children[0]
          .children[0]
          .children[0]
          .children[3]
          .children[0]
          .children[0]
          .getElementsByTagName('img')[0].attributes['src'];

      var responseString13 = document
          .getElementsByClassName('story-grid')[0]
          .children[0]
          .children[0]
          .children[0]
          .children[4]
          .children[0]
          .children[0]
          .getElementsByTagName('img')[0].attributes['src'];

      var responseString14 = document
          .getElementsByClassName('story-grid')[0]
          .children[0]
          .children[0]
          .children[0]
          .children[5]
          .children[0]
          .children[0]
          .getElementsByTagName('img')[0].attributes['src'];

      var responseString15 = document
          .getElementsByClassName('story-grid')[0]
          .children[0]
          .children[0]
          .children[0]
          .children[6]
          .children[0]
          .children[0]
          .getElementsByTagName('img')[0].attributes['src'];

      var responseString16 = document
          .getElementsByClassName('story-grid')[0]
          .children[0]
          .children[0]
          .children[0]
          .children[7]
          .children[0]
          .children[0]
          .getElementsByTagName('img')[0].attributes['src'];



      //Converting the extracted titles into string and returning a list of Strings
      return [
        responseString1.text.trim(),
        responseString2.text.trim(),
        responseString3.text.trim(),
        responseString4.text.trim(),
        responseString5.text.trim(),
        responseString6.text.trim(),
        responseString7.text.trim(),
        responseString8.text.trim(),
        responseString9.toString(),
        responseString10.toString(),
        responseString11.toString(),
        responseString12.toString(),
        responseString13.toString(),
        responseString14.toString(),
        responseString15.toString(),
        responseString16.toString(),
      ];
    } catch (e) {
      return ['', '', 'ERROR!'];
    }
  } else {
    return ['ERROR: ${response.statusCode}.'];
  }
}



