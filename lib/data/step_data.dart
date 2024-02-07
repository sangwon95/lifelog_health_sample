
import 'dart:io';

import 'package:health/health.dart';

class StepData{

  late String dateTime;
  List<Map<String, dynamic>> stepMap  = <Map<String, dynamic>>[];

  Map<String, dynamic> dioMap(String ucode) {
      Map<String, dynamic> toMap = {
        'os'             : Platform.isAndroid ? 'A': 'I',
        'userID'         : ucode,
        'measureDate'    : dateTime,
        'rawData'        : stepMap,
      };
    return toMap;
  }

  Map<String, dynamic> setMap(HealthDataPoint p){
   String step = p.value.toString();
   dateTime = p.dateFrom.toString().substring(0, 10);

    Map<String, dynamic> toMap = {
      'time':'${p.dateFrom.toString().substring(0, 19)} ~ ${p.dateTo.toString().substring(0, 19)}',
      'value': step
    };

    return toMap;
  }

  addStepMap(HealthDataPoint p){
    stepMap.add(setMap(p));
  }

  int getLength(){
    return stepMap.length;
  }

}

