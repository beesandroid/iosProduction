import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Appdrawer/Notifications_view.dart';
import '../Appdrawer/customDrawer.dart';
import '../Receipts/Halltickets.dart';
import '../Receipts/receipts.dart';
import '../response/downloadListResponse.dart';


class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({Key? key}) : super(key: key);

  @override
  _DownloadsScreenState createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  late Future<List<downloadlistdetails>> _downloadListFuture;

  @override
  void initState() {
    super.initState();
    _downloadListFuture = fetchDownloadList();
  }

  Future<List<downloadlistdetails>> fetchDownloadList() async {


    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? grpCode = prefs.getString('grpCode');
    String? colCode = prefs.getString('colCode');
    String? collegeId = prefs.getString('collegeId');


    String apiUrl = 'https://beessoftware.cloud/CoreAPI/Flutter/MenuDetails';
    Map<String, dynamic> requestBody = {
      'grpCode': grpCode,
      "ColCode": collegeId,
      "CollegeId": collegeId,
      "Category": "Downloads"
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final dynamic data = jsonDecode(response.body);

      print(response.body.toString());
      if (data is List) {
        return data.map((e) => downloadlistdetails.fromJson(e)).toList();
      } else if (data is Map<String, dynamic>) {
        final List<dynamic> downloads = data['menuDetailsList'];
        return downloads.map((e) => downloadlistdetails.fromJson(e)).toList();
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      throw Exception('Failed to load download details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Downloads',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 29,
            color: Color(0xFF13497B),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const notification_screen(),
                ),
              );
            },
            icon: const Icon(Icons.notifications_active),
          ),
        ],
      ),
      drawer: CustomDrawer(),
      body: FutureBuilder<List<downloadlistdetails>>(
        future: _downloadListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            final List<downloadlistdetails> downloadList = snapshot.data!;
            print("sssssss" + downloadlistdetails.fromJson.toString());

            return ListView.builder(
              itemCount: downloadList.length,
              itemBuilder: (context, index) {
                final download = downloadList[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(9.00),
                    ),
                    child: Center(
                      child: ListTile(
                        leading: Image.network(
                          download.imagePath ?? '',
                          // Use the imagePath from your data
                          width: 50, // Set width as needed
                          height: 50, // Set height as needed
                        ),
                        title: Text(
                          download.subCategory ?? '',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        onTap: () {
                          if (index == 0) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ReceiptsPage()));
                          } else if (index == 1) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HallTickets()));
                          }
                          // Handle download item tap
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(
              child: Text('No data available'),
            );
          }
        },
      ),
    );
  }
}
