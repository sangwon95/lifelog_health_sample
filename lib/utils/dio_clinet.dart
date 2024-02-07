
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lifelog_health/data/auth.dart';
import 'package:lifelog_health/utils/etc.dart';


Client client = Client();
class Client {

  Dio _createDio() {
    Dio dio = Dio();
    dio.options.connectTimeout =  Duration(seconds: 4000); // 4초
    dio.options.receiveTimeout =  Duration(seconds: 4000); // 4초

    // dio.options.headers = {
    //   'Content-Type': 'application/json',
    //   'Authorization': 'authorizationToken'
    // };

    return dio;
  }

  Dio _createMsgDio() {
    Dio dio = Dio();
    dio.options.connectTimeout = Duration(seconds: 10000) ; // 10초
    dio.options.receiveTimeout = Duration(seconds: 10000) ; // 10초

    return dio;
  }

  /// Dio post method
  /// [Login], [Sign],
  /// @param path : 서버 경로
  /// @param data : Map data
  /// @param context
  Future<Response> dioPost(String path, Map<String, dynamic> data, BuildContext context) async {
   Etc.getValuesFromMap(data);
    try {
      final response = await _createDio().post(path, data: data);

      if (response.statusCode == 200) {
        final statusMessage = response.data['status']['message'];

        if (statusMessage == 'Success') {
          return response;
        } else {
          return response;
        }
      } else {
        // Etc.newShowSnackBar('서버 오류로 재시도 바랍니다.', context);
        // 서버 오류 처리를 위한 로직 추가
        Etc.showMyDialog(
            title: '헬스 데이터',
            mainContext: context,
            isCancelBtn: false,
            text: '헬스 데이터 전송이 실패했습니다. 다시 시도바랍니다.'
        );
        throw Exception('서버 오류'); // 적절한 예외 던지기
      }
    } on DioError catch (e) {
      print(' >>>>[DioError] : ' + e.toString());
      // Etc.newShowSnackBar('서버 연결 오류로 재시도 바랍니다.', context);
      // 서버 연결 오류 처리를 위한 로직 추가
      Etc.showMyDialog(
          title: '헬스 데이터',
          mainContext: context,
          isCancelBtn: false,
          text: '헬스 데이터 전송이 실패했습니다. 다시 시도바랍니다.'
      );
      throw Exception('서버 연결 오류'); // 적절한 예외 던지기
    } catch (e) {
      print(e.toString());
      // 예상치 못한 예외 처리
      // Etc.newShowSnackBar('예상치 못한 오류가 발생했습니다.', context);
      // 예상치 못한 오류 처리를 위한 로직 추가
      Etc.showMyDialog(
          title: '헬스 데이터',
          mainContext: context,
          isCancelBtn: false,
          text: '헬스 데이터 전송이 실패했습니다. 다시 시도바랍니다.'
      );
      throw Exception('예상치 못한 오류'); // 적절한 예외 던지기
    }
  }

  /// Dio get method
  /// [User Info], [Chat List], [User List], [Recent Chat List Data]
  /// @param path : 서버 경로
  /// @param data : Map data
  /// @param context
  Future<Response> dioGet(String path, Map<String, dynamic> data,
      BuildContext context) async {
    late Response response;
    try {
      response = await _createDio().get(
          path, queryParameters: data);

      if (response.statusCode == 200) {
        if (response.data['status']['message'] == 'Success') {
          response.statusMessage = response.data['status']['message'];
          return response;
        }
        else {
          response.statusMessage = response.data['status']['message'];
          return response;
        }
      }
      else {
       // Etc.newShowSnackBar('서버 오류로 재시도 바랍니다.', context);
      }
    } on DioError catch (e) {
      throw Exception('서버 연결 오류');
    } catch (e) {
      print(e.toString());
    }
    return response;
  }



  /// 라이프로그 인증 메시지 전송
  /// @param path : 서버 경로
  /// @param data : Map data
  Future<int> dioSandAuthMessagePost(String tel) async {
    late Response response;
    final formData = FormData.fromMap({
      'tel': tel
    });

    try {
      response = await _createMsgDio().post(
        'http://lifelogop.ghealth.or.kr/ws/send/auth/message',
          data: formData
      );

      if (response.statusCode == 200) {
        if (response.data['code'] == '200') {
          return response.data['code'];
        }
        else {
          return response.data['code'];
        }
      }
      else {
        return response.data['code'];
      }
    } on DioError catch (e) {
      print(' >>>>[DioError] : ' + e.toString());
      // Etc.newShowSnackBar('서버 연결 오류로 재시도 바랍니다.', context);
      throw Exception('서버 연결 오류');
    } catch (e) {
      print(e.toString());
    }
    return 40;
  }


  /// 라이프로그 로그인
  /// @param tel: 전화번호
  /// @param authCode: 인증 코드
  Future<Auth> dioLoginAuthPost(String tel, String authCode) async {
    try {
      final formData = FormData.fromMap({
        'tel': tel,
        'authCode': authCode,
      });

      final response = await _createMsgDio().post(
        'https://lifelogop.ghealth.or.kr/ws/user/login', // Using HTTPS
        data: formData,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['code'] == 200) {
          return Auth.fromJson(responseData);
        } else {
          return Auth(code: responseData['code'], ucode: 'error');
        }
      } else {
        return Auth(code: 404, ucode: 'error');
      }
    } on DioError catch (e) {
      print(' >>>>[DioError] : ' + e.toString());
      throw Exception('서버 연결 오류');
    } catch (e) {
      print(e.toString());
      throw Exception('알 수 없는 오류 발생');
    }
  }
}