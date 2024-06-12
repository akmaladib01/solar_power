import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'register_device_screen.dart';
import 'model/device_model.dart';
import 'model/login_model.dart';

class DeviceListPage extends StatefulWidget {

  @override
  _DeviceListPageState createState() => _DeviceListPageState();
}

class _DeviceListPageState extends State<DeviceListPage> {
  late Future<List<DeviceModel>> _deviceListFuture;
  late LoginUser _loggedInUser;

  @override
  void initState() {
    super.initState();
    _loggedInUser = Get.find<LoginUser>();
    _refreshDeviceList();
  }

  void _refreshDeviceList() {
    setState(() {
      _deviceListFuture = DeviceModel.fetchDevices(_loggedInUser.id);
    });
  }

  Future<void> _deleteDevice(DeviceModel device) async {
    bool deleted = await device.deleteDeviceByName(device.name);
    if (deleted) {
      _refreshDeviceList();
      // Show success message if needed
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Device deleted successfully')));
    } else {
      // Show error message if deletion fails
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete device')));
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
                return _buildDeviceCard(device);
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
                Spacer(), // Add Spacer to push the delete button to the end
                IconButton(
                  onPressed: () => _deleteDevice(device), // Trigger delete action
                  icon: Icon(Icons.delete),
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
