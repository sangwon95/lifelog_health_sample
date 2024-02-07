import 'package:flutter/material.dart';
import 'package:toast/toast.dart';


class Etc {


  // static settingImageCircle(UserDetails userDetails){
  //   final String imagePath = 'images/man_d.png';
  //   final String baseProfileUrl = 'http://106.251.70.71:50006/profile/';
  //
  //   return userDetails.profileImg == '-' ?
  //   SizedBox(width: 60.0, height: 60.0, child: Image.asset(imagePath, fit: BoxFit.fill)):
  //   CircleAvatar(
  //     radius: 45.0,
  //     backgroundImage: NetworkImage(baseProfileUrl + userDetails.userID +'/'+userDetails.profileImg),
  //     backgroundColor: Colors.transparent,
  //   );
  // }
  /// font size fixation
  static MediaQueryData getScaleFontSize(BuildContext context, {double fontSize = 1.0}){
    final mqData = MediaQuery.of(context);
    return mqData.copyWith(textScaleFactor: fontSize);
  }

  // Map() print
  static void getValuesFromMap(Map map) {
    // Get all values
    print('----------');
    print('Get values:');
    map.values.forEach((value) {
      print(value);
    });
  }
  static newShowSnackBar(String meg, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(meg, textScaleFactor: 0.9, style: TextStyle(color: Colors.black),), backgroundColor: Colors.white));
  }

  // static showToast(String msg, BuildContext context) {
  //   Toast.show(msg, context, duration: 2, gravity: Toast.BOTTOM);
  // }

  static showMyDialog(
      {required String title, required String text, required BuildContext mainContext, required bool isCancelBtn}) {
    return showDialog(
        context: mainContext,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            title: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.indigoAccent, size: 35),
                  SizedBox(height: 10),
                  Text(title, textScaleFactor: 0.95, style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            content: SizedBox(
              height: 135,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
                    child: SizedBox(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              width: 220,
                              child: Text(text, textAlign: TextAlign.center, textScaleFactor: 0.85, style: TextStyle(fontWeight: FontWeight.w500))),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  Expanded(
                    child: Container(
                      width: double.infinity,
                      child: TextButton(
                          style: TextButton.styleFrom(
                              elevation: 5.0,
                              backgroundColor: Colors.indigoAccent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(10.0),
                                      bottomLeft: Radius.circular(10.0))
                              )),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('확인', textScaleFactor: 1.1, style: TextStyle(color: Colors.white))
                      ),
                    ),
                  ),
                ],
              ),
            ),
            contentPadding: EdgeInsets.all(0),
            actionsAlignment: MainAxisAlignment.end,
            actionsPadding: EdgeInsets.all(0),
          );
        });
  }
}

