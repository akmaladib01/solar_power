import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'device_screen.dart';
import 'model/device_model.dart';
import 'model/login_model.dart';

class DeviceListPage extends StatefulWidget {
  const DeviceListPage({Key? key}) : super(key: key);

  @override
  _DeviceListPageState createState() => _DeviceListPageState();
}

class _DeviceListPageState extends State<DeviceListPage> {
  late Future<List<DeviceModel>> _deviceListFuture;
  late int userId;

  @override
  void initState() {
    super.initState();
    LoginUser loggedInUser = Get.find<LoginUser>();
    userId = loggedInUser.id;
    _refreshDeviceList();
  }

  void _refreshDeviceList() {
    setState(() {
      _deviceListFuture = DeviceModel.fetchDevices(userId);
    });
  }

  Future<void> _deleteDevice(int deviceId) async {
    print('Deleting device with ID: $deviceId'); // Debug print
    try {
      bool success = await DeviceModel.deleteDevice(deviceId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Device deleted successfully'),
        ));
        _refreshDeviceList();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to delete device'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Devices List'),
        backgroundColor: Colors.blueAccent,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Register New Device') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Device()),
                ).then((result) {
                  if (result == true) {
                    _refreshDeviceList();
                  }
                });
              }
            },
            itemBuilder: (BuildContext context) {
              return {'Register New Device', 'Option 2'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<DeviceModel>>(
        future: _deviceListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching devices: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No devices found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                DeviceModel device = snapshot.data![index];
                return Dismissible(
                  key: Key(device.deviceId.toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _deleteDevice(device.deviceId);
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  child: _buildDeviceCard(device),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildDeviceCard(DeviceModel device) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              device.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.device_hub, color: Colors.green),
                SizedBox(width: 5),
                Text(
                  'Type: ${device.type}',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.category, color: Colors.orange),
                SizedBox(width: 5),
                Text(
                  'Category: ${device.category}',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
