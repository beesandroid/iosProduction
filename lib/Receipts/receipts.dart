import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';

class ReceiptsPage extends StatefulWidget {
  const ReceiptsPage({Key? key}) : super(key: key);

  @override
  _ReceiptsPageState createState() => _ReceiptsPageState();
}

class _ReceiptsPageState extends State<ReceiptsPage> {
  List<dynamic> receipts = [];
  List<dynamic> filteredReceipts = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchReceipts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: const Text(
          'Receipts',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              height: 50, // Take full width of the screen
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search receipts',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      searchController.clear();
                      _filterReceipts('');
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (query) {
                  _filterReceipts(query);
                },
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : _buildReceiptsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptsList() {
    if (filteredReceipts.isEmpty) {
      return Center(
        child: Text('No receipts found.'),
      );
    }

    return ListView.builder(
      itemCount: filteredReceipts.length,
      itemBuilder: (context, index) {
        var receipt = filteredReceipts[index];
        return Container(
          margin: const EdgeInsets.all(8.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'RecNo',
                    style: TextStyle(
                        color: Color(0xFFFF9800), fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () {
                      _downloadReceipt(
                        receipt['recId'].toString(),
                        receipt['recType'].toString(),
                        receipt['recTypeId'].toString(),
                        context, // Include context here
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Downloading receipt...'),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.download,
                      size: 35,
                      color: Color(0xFFFF9800),
                    ),
                  )
                ],
              ),
              Text(
                '${receipt['recNo']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Divider(
                color: Colors.grey,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Payment Date',
                    style: TextStyle(
                        color: Colors.yellow[800], fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Sem',
                    style: TextStyle(
                        color: Colors.yellow[800], fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${receipt['recDate']}', // Convert to string explicitly
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '${receipt['sem']}', // Convert to string explicitly
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Divider(
                color: Colors.grey,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Exam Type',
                    style: TextStyle(
                        color: Colors.yellow[800], fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Exam Month',
                    style: TextStyle(
                        color: Colors.yellow[800], fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${receipt['recType'.toString()]}',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${receipt['examMonth'.toString()]}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _filterReceipts(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredReceipts = receipts;
      });
    } else {
      setState(() {
        filteredReceipts = receipts
            .where((receipt) => receipt['recNo']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  Future<void> _fetchReceipts() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String grpCodeValue = prefs.getString('grpCode') ?? '';
      int schoolId = prefs.getInt('schoolId') ?? 0;
      int studId = prefs.getInt('studId') ?? 0;

      String apiUrl =
          'https://beessoftware.cloud/CoreAPI/Android/StudFeeReceiptsDetails';
      Map<String, dynamic> requestBody = {
        'GrpCode': grpCodeValue,
        'ColCode': 'PSS',
        'CollegeId': '0001',
        'SchoolId': schoolId,
        'StudId': studId,
        'Str': '',
        'Flag': '0'
      };

      http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        print("Response Body of StudFeeReceiptsDetails: $responseBody");

        if (responseBody.containsKey('studFeeReceiptDetailsList')) {
          List<dynamic> receiptList = responseBody['studFeeReceiptDetailsList'];
          setState(() {
            receipts = receiptList;
            filteredReceipts = receipts;
            isLoading = false;
          });
        } else {
          print('studFeeReceiptDetailsList not found in response');
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _downloadReceipt(String recId, String recType, String recTypeId,
      BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String grpCodeValue = prefs.getString('grpCode') ?? '';
      int schoolid = prefs.getInt('schoolId') ?? 00;

      String apiUrl =
          'https://beessoftware.cloud/CoreAPI/Android/FeeReceiptsReports';

      int recIdInt = int.parse(recId);

      Map<String, dynamic> requestBody = {
        "GrpCode": grpCodeValue,
        "CollegeId": "0001",
        "ColCode": "PSS",
        "SchoolId": schoolid,
        "RecId": recIdInt,
        "Type": recType,
        "Words": "rupees only",
        "Flag": recTypeId
      };

      http.Response downloadResponse = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      print('Response status code: ${downloadResponse.statusCode}');
      print('Response body: ${downloadResponse.body}');

      if (downloadResponse.statusCode == 200) {
        String fileName = 'preview_receipt.pdf';
        Directory tempDir = await getTemporaryDirectory();
        String filePath = '${tempDir.path}/$fileName';
        File pdfFile = File(filePath);

        await pdfFile.writeAsBytes(downloadResponse.bodyBytes);

        _launchPDF(context, filePath);
       } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to download PDF. Status code: ${downloadResponse.statusCode}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _launchPDF(BuildContext context, String path) async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFView(
            filePath: path,
            enableSwipe: true,
            swipeHorizontal: true,
          ),
        ),
      );

      // Show a bottom sheet or dialog with share options
      showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.phone_android),
                  title: Text('Share via WhatsApp'),
                  onTap: () {
                    _shareFile(path, 'WhatsApp');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.mail_outline),
                  title: Text('Share via Gmail'),
                  onTap: () {
                    _shareFile(path, 'Gmail');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening PDF: $e')),
      );
    }
  }

  Future<void> _shareFile(String filePath, String appName) async {
    try {
      File file = File(filePath);

      switch (appName) {
        case 'WhatsApp':
          String message = 'Check out this PDF file';
          String url =
              'https://wa.me/?text=${Uri.encodeQueryComponent(message)}';
          if (await canLaunch(url)) {
            await launch(url);
          } else {
            throw 'Could not launch WhatsApp';
          }
          break;
        case 'Gmail':
          await OpenFile.open(file.path);
          break;
      }
    } catch (e) {
      print('Error sharing file: $e');
    }
  }

  void main() {
    runApp(
      MaterialApp(
        home: ReceiptsPage(),
      ),
    );
  }
}
