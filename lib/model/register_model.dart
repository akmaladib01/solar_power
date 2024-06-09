

import '../controller/register_controller.dart';

class SignUp {
  int id;
  String username;
  String phone;
  String address;
  String email;
  String password;
  SignUp(this.id,this.username, this.phone, this.address, this.email, this.password);

  SignUp.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        username = json['username'] as String,
        phone = json['phone'] as String,
        address = json['address'] as String,
        email = json['email'] as String,
        password = json['password'] as String;
  Map<String, dynamic> toJson() =>
      {'id': id, 'username': username, 'phone': phone,
        'address': address, 'email': email, 'password': password};

  // Future<bool> isUsernameRegistered() async {
  //   RequestController_SignUp req = RequestController_SignUp(path: "/solarpower/register.php");
  //   req.setBody({'username': username}); // Assuming 'username' is the key for the username in your API
  //   await req.post();
  //   return req.status() == 200;
  // }

  Future<bool> isEmailRegistered() async {
    RequestController_SignUp req = RequestController_SignUp(path: "/solarpower/register.php");
    req.setBody({'email': email});
    await req.post();
    return req.status() == 200;
  }

  Future<bool> save() async {
    // Check if the email is already registered
    if (await isEmailRegistered()) {
      return false; // Email is already registered
    }

    // // Check if the username is already registered
    // if (await isUsernameRegistered()) {
    //   return false; // Username is already registered
    // }

    // Proceed with saving the new user
    RequestController_SignUp req = RequestController_SignUp(path: "/solarpower/register.php");
    req.setBody(toJson());
    await req.post();
    if (req.status() == 200) {
      return true; // User saved successfully
    }
    return false; // Failed to save user
  }

  static Future<List<SignUp>> loadAll() async {
    List<SignUp> result = [];
    RequestController_SignUp req = RequestController_SignUp(path: "/solarpower/register.php");
    await req.get();
    if (req.status() == 200 && req.result() != null) {
      for (var item in req.result()) {
        result.add(SignUp.fromJson(item));
      }
    }
    return result;
  }
}