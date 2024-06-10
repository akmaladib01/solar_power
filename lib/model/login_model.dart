import '../controller/controller.dart';

class LoginUser {
  int id;
  String username;
  String phone;
  String address;
  String email;
  String password;

  LoginUser(this.id, this.username, this.phone, this.address, this.email, this.password);

  LoginUser.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        username = json['username'],
        phone = json['phone'],
        address = json['address'],
        email = json['email'],
        password = json['password'];

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'phone': phone,
    'address': address,
    'email': email,
    'password': password,
  };

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
    } else {
      return false;
    }
  }
}
