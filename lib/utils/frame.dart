import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;


class Frame{

  /// 앱바 위젯
 static AppBar myAppbar(String title, {bool isIconBtn = false, IconData? iconData = Icons.settings_rounded , Function? onPressed}){
    return AppBar(
      // systemOverlayStyle: SystemUiOverlayStyle(
      //     statusBarBrightness: Brightness.light,
      //     statusBarIconBrightness: Brightness.dark,
      //     statusBarColor: Colors.white
      // ),
      title: Text(
        title,
        textScaleFactor: 0.8,
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      centerTitle: true,
      //backgroundColor: Colors.white,
      elevation: 0.0,
      //iconTheme: IconThemeData(color: Colors.black),
      actions:
      [
        /// 채팅화면 우측 상단 아이콘 버튼
        Visibility(
          visible: isIconBtn,
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
                onPressed: () => onPressed!(),
                icon: Icon(iconData, size: 25)
            ),
          ),
        ),
      ],
    );
  }

  static TextStyle textSpanBoldStyle(){
   return TextStyle(fontWeight: FontWeight.w600, color: Colors.blueAccent, fontSize: 14);
  }

  static TextStyle textSpanNormalStyle(){
   return TextStyle(fontWeight: FontWeight.normal, fontSize: 14);
  }


  /// 텍스트
  static Text myText({
    required String text,
    double fontSize = 1.0,
    Color color = Colors.black,
    FontWeight fontWeight = FontWeight.normal,
    TextAlign align = TextAlign.start,
    TextOverflow overflow = TextOverflow.visible,
    int maxLinesCount = 1,
  }){
   return Text(
     text,
     textScaleFactor: fontSize,
     overflow: overflow,
     maxLines: maxLinesCount,
     style: TextStyle(
         color: color,
         fontWeight: fontWeight,
     ),
     textAlign: align
     ,
   );
  }


  /// Navigator 화면 이동
  static doPagePush(BuildContext context, Widget page)
  {
   return Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }


 /// Navigator 화면 이동, 바로 이전 화면 1개는 스택에서 없앰.
 static doPagePushReplace(context, Widget page)
 {
   return Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => page));
 }


 /// Navigator 화면 이동, 이전 화면 모두 삭제후 이동
 static doPageAndRemoveUntil(context, Widget page)
 {
   return Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) => page), (route) => false);
 }


 /// 입차 현황 Empty View
 static buildEmptyView(String text) {
   return Container(
     child: Center(
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.center,
         mainAxisAlignment: MainAxisAlignment.center,
         children:
         [
           SizedBox(height: 20),
           Frame.myText(text: text, fontSize: 1.2, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
         ],
       ),
     ),
   );
 }


 static buildTag({required String text, double textSize = 0.8}){
   return Container(
     margin: EdgeInsets.only(right: 5),
     padding: EdgeInsets.all(5),
     decoration: BoxDecoration(
       border: Border.all(
           color: Colors.blue,
           width: 1.5,
           style: BorderStyle.solid
       ),
       borderRadius: BorderRadius.circular(30),
     ),
     child: Center (
         child: Frame.myText(
            text: text,
            fontSize: textSize,
            fontWeight: FontWeight.bold,
            color: Colors.blue)
     )
     );
 }

 static buildOathItem(String text){
   return Padding(
     padding: const EdgeInsets.only(bottom: 5),
     child: Row(
       children: [
         Image.asset('images/check.png', width: 25, height: 25),
         SizedBox(width: 7),
         Frame.myText(
             text: '${text}',
             maxLinesCount: 2,
            fontSize: 1.1
         )
       ],
     ),
   );
 }
}