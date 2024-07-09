import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';

class SupplyPaymentPage extends StatefulWidget {
  const SupplyPaymentPage({Key? key}) : super(key: key);

  @override
  State<SupplyPaymentPage> createState() => _SupplyPaymentPageState();
}

class _SupplyPaymentPageState extends State<SupplyPaymentPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSupplyFee().then((response) {
      _startTransaction(response);
    }).catchError((error) {
      print('Error fetching supply fee: $error');
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator() // Show loading indicator while payment data is being fetched
            : Text(
            "Press Back to Main Page"), // Display text when payment data is loaded
      ),
    );
  }

  Future<Map<String, dynamic>> fetchSupplyFee() async {
    final requestBody = {
      {
        "GrpCode":"SRIT",
        "ColCode":"pss",
        "CollegeId":"0001",
        "SchoolId":"1",
        "StudId":"593",
        "PaymentDt":"2024-05-29",
        "CaptchaImg":"yfghfcg",
        "AcYearId":"7",
        "FeeStructId":"113",
        "Fee":"1",
        "Fine":"0",
        "Sem":"IV/IV II SEM",
        "FYearId":"5",
        "ExamMonth":"June 2024"
      }
    };

    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPI/Flutter/SaveSupplyFeeTempData'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Response Data: $data");
      return data;
    } else {
      throw Exception(
          'Failed to load supply fee. Status code: ${response.statusCode}');
    }
  }

  Future<void> _startTransaction(Map<String, dynamic> transactionData) async {
    try {
      print(
          "MID: ${transactionData['saveSupplyFeeTempDataList'][0]['MID']}");
      print(
          "ORDER_ID: ${transactionData['saveSupplyFeeTempDataList'][0]['ORDER_ID']}");
      print(
          "TXN_AMOUNT: ${transactionData['saveSupplyFeeTempDataList'][0]['TXN_AMOUNT']}");
      print(
          "Data: ${transactionData['saveSupplyFeeTempDataList'][0]['Data']}");
      print("CALLBACK_URL: ${transactionData['saveSupplyFeeTempDataList'][0]['CALLBACK_URL']}");

      final response = await AllInOneSdk.startTransaction(
        transactionData['saveSupplyFeeTempDataList'][0]['MID'],
        transactionData['saveSupplyFeeTempDataList'][0]['ORDER_ID'],
        transactionData['saveSupplyFeeTempDataList'][0]['TXN_AMOUNT'],
        transactionData['saveSupplyFeeTempDataList'][0]['token'],
        transactionData['saveSupplyFeeTempDataList'][0]['CALLBACK_URL'],
        true,
        true, // restrictAppInvoke
      );

      print("Payment Response: $response");
    } catch (err) {
      print('Error: $err');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: SupplyPaymentPage(),
  ));
}
