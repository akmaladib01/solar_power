import '../controller/controller.dart';

class DeviceModel {
  int deviceId;
  String name;
  String type;
  String category;
  int userId;

  DeviceModel({
    required this.deviceId,
    required this.name,
    required this.type,
    required this.category,
    required this.userId,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      deviceId: json['deviceId'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      category: json['category'] ?? '',
      userId: json['userId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'name': name,
    'type': type,
    'category': category,
    'userId': userId,
  };

  Future<bool> register() async {
    RequestController req = RequestController(path: "/solarpower/register_device.php");
    req.setBody(toJson());
    await req.post();
    return req.status() == 200;
  }

  static Future<List<DeviceModel>> fetchDevices(int userId) async {
    RequestController req = RequestController(path: "/solarpower/display_device.php?id=$userId");
    await req.get();
    if (req.status() == 200) {
      List<dynamic> jsonResponse = req.result();
      try {
        return jsonResponse.map((device) => DeviceModel.fromJson(device)).toList();
      } catch (e) {
        print("Error parsing JSON: $e");
        throw Exception('Failed to parse devices');
      }
    } else {
      print("Error fetching devices, status code: ${req.status()}");
      throw Exception('Failed to load devices');
    }
  }

  Future<bool> deleteDeviceByName(int deviceId) async {
    RequestController req = RequestController(path: "/solarpower/delete_device.php?device_id=$deviceId");
    req.setBody({'deviceId': deviceId});
    await req.post();
    return req.status() == 200;
  }
}
