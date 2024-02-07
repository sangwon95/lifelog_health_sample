
import 'dart:io';
import 'package:health/health.dart';

class HeartData{

  late String dateTime;
  List<Map<String, dynamic>> heartMap  = <Map<String, dynamic>>[];

  Map<String, dynamic> dioMap(String ucode) {
      Map<String, dynamic> toMap = {
        'os'           : Platform.isAndroid ? 'A': 'I',
        'userID'       : ucode,
        'measureDate'  : dateTime,
        'rawData'      : heartMap,
      };
    return toMap;
  }

  Map<String, dynamic> setMap(HealthDataPoint p){
    String heart = p.value.toString();
    print('heartMap.length : ${heartMap.length}');
   dateTime = p.dateFrom.toString().substring(0, 10);

    Map<String, dynamic> toMap = {
      'time': p.dateFrom.toString().substring(0, 19),
      'value': heart
    };

    return toMap;
  }

  addHeartMap(HealthDataPoint p){
    print('addHeartMap 실행');
    heartMap.add(setMap(p));
    print(heartMap);
  }
}

