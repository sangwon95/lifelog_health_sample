
import 'dart:io';

import 'package:health/health.dart';

class SleepData{

  late String dateTime;
  List<Map<String, dynamic>> sleepMap  = <Map<String, dynamic>>[];

  Map<String, dynamic> dioMap(String ucode) {
      Map<String, dynamic> toMap = {
        'os'          : Platform.isAndroid ? 'A': 'I',
        'userID'      : ucode,
        'measureDate' : dateTime,
        'rawData'     : sleepMap,
      };
    return toMap;
  }

  Map<String, dynamic> setMap(HealthDataPoint p){
   String sleep =  p.value.toString();
   dateTime = p.dateFrom.toString().substring(0, 10);
    Map<String, dynamic> toMap = {
      'time':'${p.dateFrom.toString().substring(0, 16)} ~ ${p.dateTo.toString().substring(0, 16)}',
      'value': sleep
    };

    return toMap;
  }

  addSleepMap(HealthDataPoint p){
    sleepMap.add(setMap(p));
    print(sleepMap);
  }

}

