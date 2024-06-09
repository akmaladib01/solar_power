

import '../controller/controller.dart';

class LoginUser {
  int id;
  String username;
  String phone;
  String address;
  String email;
  String password;
  LoginUser(this.id,this.username, this.phone, this.address, this.email, this.password);

  LoginUser.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        username = json['username'] as String,
        phone = json['phone'] as String,
        address = json['address'] as String,
        email = json['email'] as String,
        password = json['password'] as String;

  Map<String, dynamic> toJson() =>
      {'id': id, 'username': username, 'phone': phone,
        'address': address, 'email': email, 'password': password};

  Future<bool> login() async {
    RequestController req = RequestController(path: "/solarpower/login.php");
    req.setBody(toJson());
    await req.post();

    if (req.status() == 200) {
      id = req.result()['id'];
      username = req.result()['username'];
      phone = req.result()['phone'];
      address = req.result()['address'];
      email = req.result()['email'];
      password = req.result()['password'];
      return true;
    }
    else{
      return false;
    }
  }

  static Future<List<LoginUser>> loadByEmail(String email) async {
    List<LoginUser> result = [];
    RequestController req = RequestController(path: "/solarpower/login.php");
    req.setBody({'email': email}); // Set the email in the request body
    await req.get();
    if (req.status() == 200 && req.result() != null) {
      for (var item in req.result()) {
        result.add(LoginUser.fromJson(item));
      }
    }
    return result;
  }
}