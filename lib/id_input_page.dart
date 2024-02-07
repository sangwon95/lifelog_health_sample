
import 'package:flutter/material.dart';
import 'package:lifelog_health/transmission_page.dart';
import 'package:lifelog_health/utils/dio_clinet.dart';
import 'package:lifelog_health/utils/etc.dart';
import 'package:lifelog_health/utils/frame.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/auth.dart';

class IdInputPage extends StatefulWidget {
  IdInputPage({super.key});

  @override
  State<IdInputPage> createState() => _IdInputPageState();
}

class _IdInputPageState extends State<IdInputPage> {
  final telController = TextEditingController();
  final certificationController = TextEditingController();

  /// 포커스노트 선언
  FocusNode certificationFocusNode = FocusNode();

  Duration _duration = Duration(minutes: 3);
  late int _minutes = 3;
  late int _seconds = 0;
  late bool _isActive;

  var isShowCertificationWidget = false;

  String btnTextState = '인증번호 전송';

  bool isShowSpinner = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: ()=> FocusScope.of(context).unfocus(),
        child: ModalProgressHUD(
          opacity: 0.4,
          inAsyncCall: isShowSpinner,
          child: Container(
            padding: EdgeInsets.only(top: 80),
                decoration: BoxDecoration(
                  //color: Colors.indigoAccent
                  image: DecorationImage(
                      image: AssetImage('images/background.jpg'),
                      fit: BoxFit.cover
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Frame.myText(
                      text: '라이프로그 건강\n관리서비스',
                      fontWeight: FontWeight.bold,
                      fontSize: 2.3,
                      maxLinesCount: 2,
                      color: Colors.white,
                      align: TextAlign.center
                    ),
                    SizedBox(height: 40),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Frame.myText(
                              text: '휴대폰 인증',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 1.4
                          ),
                        ),
                        SizedBox(height: 5),

                        PhoneTextField(
                            hintLabel: '아이디',
                            hint: '휴대폰번호를 입력해주세요.(-제외)',
                            controller: telController
                        ),

                        Visibility(
                          visible: isShowCertificationWidget,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CertificationTextField(
                                  hintLabel: '인증번호',
                                  hint: '인증번호를 입력해주세요.',
                                  controller: certificationController,
                                  minutes: _minutes,
                                  seconds: _seconds,
                                  focusNode: certificationFocusNode,
                                  voidCallback: ()=> againSendAuthMessage(),
                              ),

                              Padding(
                                padding: const EdgeInsets.only(left: 35, top: 5),
                                child: Frame.myText(
                                  text: '* 3분 이내로 인증번호(5자리)를 입력해주세요.',
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold
                                ),
                              )
                            ],
                          ),
                        )

                      ],
                    ),
                    SizedBox(height: 20),

                    _buildNextButton()
                  ],
                ),
              ),
        ),
      ),
    );
  }


  /// 다음 화면 버튼
  _buildNextButton(){
    return  Container(
        height: 50,
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: TextButton(
            style: TextButton.styleFrom(
                elevation: 5,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0))),
            onPressed: () {
              // 키보드 내리기
              FocusScope.of(context).unfocus();

              if(btnTextState == '인증번호 전송'){
                /// 전화번호 유효성 체크 후
                /// 인증 번호 메시지 발송
                if(isValidTelNumber(telController, context)){
                  sendAuthMessage(telController.text, context);
                }
              }
              else if(btnTextState == '인증 하기'){
                /// 인증번호 자리수 유효검사 필요
                /// 인증 API 호출
                if(isValidTelNumber(telController, context)
                  && isValidCertificationCode(certificationController, context))
                {
                  loginAuth(telController.text, certificationController.text);
                }
              }
            },
            child: Frame.myText(
                text: '${btnTextState}',
                fontSize: 1.1,
                color: Colors.black,
                fontWeight: FontWeight.bold
            ))
    );
  }

  void _resetTimer() {
    setState(() {
      _isActive = false;
      _minutes = _duration.inMinutes;
      _seconds = _duration.inSeconds % 60;
    });
  }

  void _startTimer() {
    setState(() {
      _isActive = true;
    });

    Future.delayed(Duration(seconds: 1), _updateTimer);
  }

  void _updateTimer() {
    if (_isActive) {
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          if (_minutes > 0) {
            _minutes--;
            _seconds = 59;
          } else {
            _isActive = false;
            _minutes = 0;
            _seconds = 0;
          }
        }
      });

      if (_minutes > 0 || _seconds > 0) {
        Future.delayed(Duration(seconds: 1), _updateTimer);
      } else {
        _isActive = false;
      }
    }
  }

  /// 휴대폰 번호 유효성 체크
  bool isValidTelNumber(TextEditingController controller, BuildContext context){
    // 한국 휴대폰 번호 정규식 패턴
    RegExp regExp = RegExp(r'^01[0-9]-?\d{3,4}-?\d{4}$');
    if(controller.text.isEmpty){
      Etc.showMyDialog(
          title: '휴대폰 번호',
          mainContext: context,
          isCancelBtn: false,
          text: '휴대폰 번호를 입력해 주세요.'
      );
      return false;
    }
    else if(controller.text.length <10){
      Etc.showMyDialog(
          title: '휴대폰 번호',
          mainContext: context,
          isCancelBtn: false,
          text: '휴대폰 번호 10~11자리 입력해주세요.'
      );
      return false;
    }
    else if(!regExp.hasMatch(controller.text)){
      Etc.showMyDialog(
          title: '휴대폰 번호',
          mainContext: context,
          isCancelBtn: false,
          text: '유효하지 않는 휴대폰 번호 입니다.'
      );
      return false;
    }
    return true;
  }

  /// 인증코드 유효성 체크
  bool isValidCertificationCode(TextEditingController controller, BuildContext context){
    // 한국 휴대폰 번호 정규식 패턴
    if(controller.text.isEmpty){
      Etc.showMyDialog(
          title: '인증 코드',
          mainContext: context,
          isCancelBtn: false,
          text: '인증코드를 입력해주세요.'
      );
      return false;
    }
    else if(controller.text.length < 5){
      Etc.showMyDialog(
          title: '인증 코드',
          mainContext: context,
          isCancelBtn: false,
          text: '인증코드 5자리 입력해주세요.'
      );
      return false;
    } else {
      return true;
    }
  }

  /// 인증 번호 전송
  sendAuthMessage(String tel, BuildContext context) async {
    setState(() {
      isShowSpinner = true;
    });
    int responseCode = await client.dioSandAuthMessagePost(tel);
    if(responseCode == 200){
      Etc.newShowSnackBar('인증번호가 발송되었습니다. ', context);
      setState(() {
        isShowSpinner = false;
        isShowCertificationWidget = true;
        btnTextState = '인증 하기';
        _startTimer();

        // 인증번호 입력란 포커스
        FocusScope.of(context).requestFocus(certificationFocusNode);
      });
    } else {
      print('responseCode: ${responseCode}');
      Etc.newShowSnackBar('인증번호가 발송이 실패했습니다.', context);
      setState(() {
        isShowSpinner = false;
      });
    }
  }

  /// 인증번호를 작성하고 로그인
  loginAuth(String tel, String authCode) async {
    Auth responseAuth = await client.dioLoginAuthPost(tel, authCode);
    if(responseAuth.code == 200){
      print('responseAuth.ucode: ${responseAuth.ucode}');
      saveUCode(responseAuth.ucode);

      Navigator.pop(context);
      Frame.doPagePush(
          context, TransmissionPage(userID: responseAuth.ucode));
    } else {
      Etc.showMyDialog(
          title: '인증번호',
          mainContext: context,
          isCancelBtn: false,
          text: '인증번호가 유효하지 않습니다.\n다시 시도바랍니다.'
      );
    }
  }

  /// 인증번호 재전송
  againSendAuthMessage() async {
    if(isValidTelNumber(telController, context)){
      setState(() {
        isShowSpinner = true;
      });
      int responseCode = await client.dioSandAuthMessagePost(telController.text);
      if(responseCode == 200){
        Etc.newShowSnackBar('인증번호가 재발송되었습니다. ', context);
        setState(() {
          isShowSpinner = false;
          certificationController.text = '';
          _resetTimer();
          _startTimer();

          // 인증번호 입력란 포커스
          FocusScope.of(context).requestFocus(certificationFocusNode);
        });
      } else {
        print('responseCode: ${responseCode}');
        Etc.newShowSnackBar('인증번호가 발송이 실패했습니다.', context);
        setState(() {
          isShowSpinner = false;
        });
      }
    }

  }

  saveUCode(String ucode) async {
    var pref = await SharedPreferences.getInstance();
    pref.setString('ucode', ucode);
  }
}


class PhoneTextField extends StatelessWidget {
  PhoneTextField({
    required this.hint,
    required this.controller,
    required this.hintLabel
  });

  final String hint;
  final String hintLabel;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
        alignment: Alignment.centerLeft,
        height: 60.0,
        child: MediaQuery(
          data: Etc.getScaleFontSize(context, fontSize: 0.9),
          child: TextField(
            autofocus: false,
            controller: controller,
            keyboardType: TextInputType.number,
            maxLength: 11,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
                counterText:'',
                labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 1.5),
                    borderRadius:  BorderRadius.all( Radius.circular(20.0))),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 1.5),
                    borderRadius:  BorderRadius.all( Radius.circular(20.0))),
                contentPadding: EdgeInsets.only(top: 14.0, left: 20),
                hintText: hint,
                hintStyle: TextStyle(color: Colors.white)
            ),
          ),
        )
    );
  }
}

/// 인증번호 입력란
class CertificationTextField extends StatelessWidget {
  CertificationTextField({
    required this.hint,
    required this.controller,
    required this.hintLabel,
    required this.minutes,
    required this.seconds,
    required this.focusNode,
    required this.voidCallback,
  });

  final String hint;
  final String hintLabel;
  final TextEditingController controller;
  final int minutes;
  final int seconds;
  final FocusNode focusNode;
  final VoidCallback voidCallback;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
        alignment: Alignment.centerLeft,
        height: 60.0,
        child: MediaQuery(
          data: Etc.getScaleFontSize(context, fontSize: 0.9),
          child: Stack(
            children: [
              TextField(
                autofocus: false,
                focusNode: focusNode,
                controller: controller,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 1.5),
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 1.5),
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  contentPadding: EdgeInsets.only(top: 14.0, left: 20),
                  hintText: hint,
                  hintStyle: TextStyle(color: Colors.white),
                ),
              ),
              Positioned(
                right: 20.0,
                top: 14,
                child: GestureDetector(
                    onTap: ()=>{
                      if(minutes ==0 && seconds == 0){
                        print('재전송!'),
                        /// 재전송 function()
                        voidCallback()
                      }
                    },
                  child: Frame.myText(
                    text:(minutes == 0 && seconds == 0)? '재전송' : '$minutes:${seconds.toString().padLeft(2, '0')}',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 1.2,
                    ),
                ),
                )
            ],
          )
        )
    );
  }

}
