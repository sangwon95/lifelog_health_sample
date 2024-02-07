import 'dart:async';

import 'package:flutter/material.dart';

import 'package:lifelog_health/transmission_page.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'id_input_page.dart';

const String URL_BASE = 'http://ws/wearable/lifelogop.ghealth.or.kr/';
const String URL_STEP_COUNT = '$URL_BASE/stepcount';
const String URL_SLEEP_TIME = '$URL_BASE/sleeptime';
const String URL_HEART_RATE = '$URL_BASE/heartrate';
String? ucode = null;

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized(); // 플랫폼 채널의 위젯 바인딩을 보장해야한다.

  await Permission.activityRecognition.request();
  await getUcode();

  runApp(MyApp());
}


/// 저장된 ucode 가져오기
getUcode() async {
  var pref = await SharedPreferences.getInstance();
  ucode = pref.getString('ucode') ?? null;
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Data',
      debugShowCheckedModeBanner: false,
      home: ucode == null ? IdInputPage() : TransmissionPage(userID: ucode!),
    );
  }
}