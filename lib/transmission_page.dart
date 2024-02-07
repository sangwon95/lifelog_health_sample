
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:lifelog_health/utils/dio_clinet.dart';
import 'package:lifelog_health/utils/etc.dart';
import 'package:lifelog_health/utils/frame.dart';

import 'data/heart_data.dart';
import 'data/sleep_data.dart';
import 'data/step_data.dart';
import 'main.dart';
import 'package:dio/dio.dart';

enum AppState {
  DATA_NOT_FETCHED,
  FETCHING_DATA,
  DATA_READY,
  NO_DATA,
  AUTH_NOT_GRANTED,
  DATA_ADDED,
  DATA_NOT_ADDED,
  STEPS_READY,
}

/// 헬스데이터 전송
class TransmissionPage extends StatefulWidget {
  TransmissionPage({super.key, required this.userID});
  final String userID;

  @override
  State<TransmissionPage> createState() => _TransmissionPageState();
}

class _TransmissionPageState extends State<TransmissionPage> {
  HealthFactory health = HealthFactory();

  /// STEPS HealthDataPoint 리스트
  List<HealthDataPoint> _healthStepsList= [];

  /// HEART_RATE  HealthDataPoint 리스트
  List<HealthDataPoint> _healthHeartList= [];

  /// SLEEP_IN_BED  HealthDataPoint 리스트
  List<HealthDataPoint> _healthSleepList= [];

  /// StepData 객체
  StepData stepData = StepData();

  /// HeartData 객체
  HeartData heartData = HeartData();

  /// SleepData 객체
  SleepData sleepData = SleepData();

  /// 데이터가 준비가 되었는지/보낼수 있는지
  bool isPossible = false;

  bool isOnceRun = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 100),
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/background.jpg'),
              fit: BoxFit.cover
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
                Icons.check_circle_outline,
                color: Colors.greenAccent,
                size: 70
            ),
            SizedBox(height: 12),
            Frame.myText(
              text: '라이프 로그에 오신걸 \n환영합니다.',
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 1.8,
              maxLinesCount: 2,
              align: TextAlign.center
            ),
            SizedBox(height: 54),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Frame.myText(
                  text:'ID: ',
                  fontSize: 1.4,
                  color: Colors.white,
                ),
                SizedBox(width: 6),

                Container(
                  width: 150,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.white, width: 1.5),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: Frame.myText(
                      text: '${widget.userID}',
                      fontSize: 1.4,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            FutureBuilder(
              future: fetchData(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if(snapshot.hasError){
                  print('${snapshot.error}');
                  return Container(
                      child: Center(
                          child: Text('데이터를 불러오지 못했습니다.',
                              textScaleFactor: 1.1, style: TextStyle(color: Colors.white))));
                }

                if (!snapshot.hasData) {
                  return Container(
                      child: Center(
                          child: SizedBox(height: 40.0, width: 40.0,
                              child: CircularProgressIndicator(strokeWidth: 5))));
                }
                if (snapshot.connectionState == ConnectionState.done) {
                  if(isOnceRun){
                    isOnceRun = false;
                    isPossible = snapshot.data;
                  }
                }

              return _buildSendButton();
            },
            )
          ],
        ),
      ),
    );
  }

  /// Fetch data points from the health plugin and show them in the app.
  Future<bool> fetchData() async {
    final permissions = [ HealthDataAccess.READ, HealthDataAccess.READ, HealthDataAccess.READ];// with coresponsing permissions

    final now = DateTime.now();
    final today24Hour = DateTime(now.year, now.month, now.day, 0, 0);  // 오늘 // get data within the last 24 hours

    bool requested = await health.requestAuthorization([
      HealthDataType.STEPS,
      HealthDataType.HEART_RATE,
      HealthDataType.SLEEP_IN_BED
    ], permissions: permissions);    // needed, since we only want READ access.

    print('requested: ${requested}');
    if (requested) {
      try {
        List<HealthDataPoint> healthStepData = await health.getHealthDataFromTypes(today24Hour, now, [HealthDataType.STEPS,HealthDataType.HEART_RATE, HealthDataType.SLEEP_IN_BED]);        // fetch health data
        List<HealthDataPoint> healthHeartData = await health.getHealthDataFromTypes(today24Hour, now, [HealthDataType.HEART_RATE]);  // fetch health data
        List<HealthDataPoint> healthSleepData = await health.getHealthDataFromTypes(today24Hour, now, [HealthDataType.SLEEP_IN_BED]); // fetch health data

          _healthStepsList.addAll((healthStepData.length < 300)
              ? healthStepData
              : healthStepData.sublist(0, 300));
          _healthStepsList = HealthFactory.removeDuplicates(_healthStepsList);// filter out duplicates
          _contentDataReady(_healthStepsList);
        _healthStepsList.forEach((x) {
          print("_healthStepsList Data point: ${x.value}");
        });

        _healthHeartList.addAll((healthHeartData.length < 300)
              ? healthHeartData
              : healthHeartData.sublist(0, 300));
          _healthHeartList = HealthFactory.removeDuplicates(_healthHeartList);// filter out duplicates
        print('_healthHeartList length: ${_healthHeartList.length}');
          _contentDataReady(_healthHeartList);
        _healthHeartList.forEach((x) {
          print("_healthHeartList Data point: ${x.value.toString()}");
        });

          _healthSleepList.addAll((healthSleepData.length < 300)
              ? healthSleepData
              : healthSleepData.sublist(0, 300));
          _healthSleepList = HealthFactory.removeDuplicates(_healthSleepList);// filter out duplicates
          _contentDataReady(_healthSleepList);
        _healthSleepList.forEach((x) {
          print("_healthSleepList Data point: ${x.value}");
        });

        //
        if(_healthStepsList.isEmpty&&_healthSleepList.isEmpty&&_healthHeartList.isEmpty){
          Etc.showMyDialog(
              title: '헬스 데이터',
              mainContext: context,
              isCancelBtn: false,
              text: '저장된 데이터가 없습니다.'
          );
          return false;
        } else {
          print('통과');
          return true;
        }
      } catch (error) {
        /// 데이터를 가져오는데 실패했습니다.
        Etc.showMyDialog(
            title: '헬스 데이터',
            mainContext: context,
            isCancelBtn: false,
            text: '데이터를 가져오는데 실패했습니다.'
        );
        print("Exception in getHealthDataFromTypes: $error");
        return false;
      }
    } else {
      /// 계정 인증이 실패했습니다.
      Etc.showMyDialog(
          title: '인증',
          mainContext: context,
          isCancelBtn: false,
          text: '계정 인증이 실패했습니다.'
      );
      return false;
    }
  }

  _sendHealthDataHttp(BuildContext context) async {
    bool isSuccess = true;
   if(stepData.stepMap.length > 0){
     Response responseStep = await client.dioPost(URL_STEP_COUNT, stepData.dioMap(widget.userID), context);
     isSuccess = responseStep.data['status']['message'] == 'Success'? true : false;
   }
   if(heartData.heartMap.length > 0){
     Response responseHeart = await client.dioPost(URL_HEART_RATE, heartData.dioMap(widget.userID), context);
     isSuccess = responseHeart.data['status']['message'] == 'Success'? true : false;

   }
   if(sleepData.sleepMap.length > 0){
     Response responseSleep = await client.dioPost(URL_SLEEP_TIME, sleepData.dioMap(widget.userID), context);
     isSuccess = responseSleep.data['status']['message'] == 'Success'? true : false;
   }
   if(isSuccess){
     Etc.showMyDialog(
         title: '헬스 데이터',
         mainContext: context,
         isCancelBtn: false,
         text: '헬스 데이터 전송이 완료 되었습니다.'
     );
   } else {
     Etc.showMyDialog(
         title: '헬스 데이터',
         mainContext: context,
         isCancelBtn: false,
         text: '헬스 데이터 전송이 실패했습니다. 다시 시도바랍니다.'
     );
   }
  }

  /// 헬스 데이터 전송
  _buildSendButton() {
    return  Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        height: 60,
        width: double.infinity,
        child: Padding(padding: EdgeInsets.all(4.0),
          child: TextButton(
              style: TextButton.styleFrom(
                  elevation: 2,
                  backgroundColor: isPossible ? Colors.white : Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0))),
              onPressed: () {
                if(isPossible){
                  _sendHealthDataHttp(context);
                } else {
                  print('onPressed ${isPossible}');
                  Etc.showMyDialog(
                      title: '헬스 데이터',
                      mainContext: context,
                      isCancelBtn: false,
                      text: '저장된 데이터가 없습니다.'
                  );
                }
              },
              child: Frame.myText(
                  text: isPossible? '데이터 전송하기' :'저장된 데이터가 없습니다.',
                  fontSize: 1.1,
                  color: Colors.black,
                  fontWeight: FontWeight.bold
              )),
        )
    );
  }

  _contentDataReady(var list) {
    print('_contentDataReady list length: ${list.length}');
    for(int i = 0 ; i<list.length ; i++){
      HealthDataPoint p = list[i];

      print('p.typeString: ${p.typeString}');
      if(p.typeString == 'STEPS') {
        stepData.addStepMap(p);
      }
      else if(p.typeString == 'HEART_RATE')
      {
        heartData.addHeartMap(p);
      }
      else{ //SLEEP_IN_BED
        sleepData.addSleepMap(p);
      }
    }
  }
}
