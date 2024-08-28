import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../views/PROVIDER.dart';

class CertificateFeePayments extends StatefulWidget {
  const CertificateFeePayments({Key? key}) : super(key: key);

  @override
  State<CertificateFeePayments> createState() => _CertificateFeePaymentsState();
}

class CertificateInfo {
  final int certificateId;
  int selectedCopies;

  CertificateInfo({required this.certificateId, this.selectedCopies = 0});
}

class _CertificateFeePaymentsState extends State<CertificateFeePayments> {
  List<Map<String, dynamic>> _certificates = [];
  Map<int, CertificateInfo> _selectedCopies = {};

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.post(
      Uri.parse(
          'https://mritsexams.com/CoreApi/Flutter/CertificateDropDownForFlutter'),
      body: json.encode({
        "GrpCode": "bees",
        "ColCode": "pss",
        "CollegeId": "0001",
        "SchoolId": "1",
        "Flag": "0",
        "CertificateIds": "",
        "Copies": ""
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        _certificates = List<Map<String, dynamic>>.from(
            jsonData['cerificatesDropDownForFlutterList']);
        _selectedCopies = Map.fromIterable(_certificates,
            key: (certificate) => certificate['certificateId'],
            value: (certificate) =>
                CertificateInfo(certificateId: certificate['certificateId']));
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchBottomSheet() async {
    final userDetails =
        Provider.of<UserProvider>(context, listen: false).userDetails;
    // Filter _selectedCopies to include only checked values
    final checkedCertificates = _selectedCopies.entries
        .where((entry) => entry.value.selectedCopies > 0);

    final List<int> selectedCertificateIds = [];
    final List<int> selectedCopies = [];
    checkedCertificates.forEach((entry) {
      selectedCertificateIds.add(entry.key);
      selectedCopies.add(entry.value.selectedCopies);
    });

    final requestBody = json.encode({
      "GrpCode": userDetails?.grpCode,
      "ColCode": userDetails?.colCode,
      "CollegeId": userDetails?.collegeId,
      "SchoolId": "1",
      "Flag": "1",
      "CertificateIds": selectedCertificateIds.join(","),
      "Copies": selectedCopies.join(","),
    });

    print("Request Body: $requestBody");

    final response = await http.post(
      Uri.parse(
          'https://mritsexams.com/CoreApi/Flutter/CertificateDropDownForFlutter'),
      body: requestBody,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print("Response Body: ${response.body}");

      _showBottomSheet(jsonData);
    } else {
      throw Exception('Failed to load data');
    }
  }

  void _showBottomSheet(dynamic responseData) {
    final List<dynamic> certificatesData =
        responseData['cerificatesDropDownForFlutterList'];
    int grandTotal = 0;

    for (final certificateData in certificatesData) {
      grandTotal +=
          certificateData['totalAmount'] as int; // No need to cast to String
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: certificatesData.length,
                  itemBuilder: (context, index) {
                    final certificateData = certificatesData[index];
                    final certificateName = certificateData['certificateName'];
                    final amount = certificateData['amount'];
                    final totalAmount = certificateData['totalAmount'];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Certificate Name: $certificateName',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Amount: $amount',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Total Amount: $totalAmount',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          Divider(), // Add a divider between certificates
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Grand Total: $grandTotal',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Certificates',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.lightGreen,
      ),
      body: ListView.builder(
        itemCount: _certificates.length,
        itemBuilder: (context, index) {
          final certificate = _certificates[index];
          final certificateId = certificate['certificateId'];
          final selectedCopiesInfo = _selectedCopies[certificateId]!;
          final selectedCopiesCount = selectedCopiesInfo.selectedCopies;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                title: Row(
                  children: [
                    Checkbox(
                      value: selectedCopiesCount > 0,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value != null && value) {
                            selectedCopiesInfo.selectedCopies = 1;
                          } else {
                            selectedCopiesInfo.selectedCopies = 0;
                          }
                        });
                      },
                    ),
                    SizedBox(width: 8.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            certificate['certificateName'],
                            style: TextStyle(fontSize: 16.0),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            'Certificate ID: $certificateId',
                            style:
                                TextStyle(fontSize: 12.0, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 20),
                    DropdownButton<int>(
                      value: selectedCopiesCount,
                      onChanged: (int? value) {
                        setState(() {
                          if (value != null && value >= 0) {
                            selectedCopiesInfo.selectedCopies = value;
                          }
                        });
                      },
                      items: List.generate(
                              11,
                              (index) =>
                                  index) // Adjusted to start from 0 to 10
                          .map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          fetchBottomSheet();
          // Display selected names, certificateIds, and copies
          _selectedCopies.forEach((certificateId, copyInfo) {
            final certificate = _certificates
                .firstWhere((c) => c['certificateId'] == certificateId);
            print(
                '${certificate['certificateName']} (ID: $certificateId) - ${copyInfo.selectedCopies} copies');
          });
        },
        child: Icon(Icons.done),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CertificateFeePayments(),
  ));
}
