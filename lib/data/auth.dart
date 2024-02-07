
class Auth {
  late int code;
  late String ucode;

  Auth({required this.code, required this.ucode});

  factory Auth.fromJson(Map<String, dynamic>json){
    return Auth(
        code: json['code'],
        ucode: json['ucode'],
    );
  }
}