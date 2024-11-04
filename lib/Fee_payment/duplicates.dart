import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

import 'package:open_file/open_file.dart'; // Add this import

import '../views/MainPage.dart';

class Duplicates extends StatefulWidget {
  const Duplicates({super.key});

  @override
  State<Duplicates> createState() => _DuplicatesState();
}

class _DuplicatesState extends State<Duplicates> {
  List certificates = [];
  Map<int, int> selectedCopies = {}; // Maps certificateId to selected copies
  Map<int, List> examTypeList = {};
  Map<int, List> semList = {};
  Map<int, String> selectedExamType = {};
  Map<int, String> selectedSem = {};

  Map<int, List> monthYearList = {};
  Map<int, String> selectedMonthYear =
      {}; // Stores selected sem for each certificate

  @override
  void initState() {
    super.initState();
    fetchCertificates();
  }

  Future<void> fetchCertificates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String grpCodeValue = prefs.getString('grpCode') ?? '';
    int schoolId = prefs.getInt('schoolId') ?? 0;
    int studId = prefs.getInt('studId') ?? 0;
    String colCode = prefs.getString('colCode') ?? '';
    String collegeId = prefs.getString('collegeId') ?? '';
    const url =
        'https://mritsexams.com/CoreAPI/Flutter/CertificateDropDownForFlutter';
    final requestBody = {
      "GrpCode": grpCodeValue,
      "ColCode": colCode,
      "CollegeId": collegeId,
      "SchoolId": schoolId,
      "Flag": 0,
      "FYearId": 0,
      "CertificateIds": "",
      "Copies": "",
      "CaptchaImg": "",
      "PaymentDate": "",
      "StudId": studId,
      "ReValFee": 0,
      "ReCountFee": 0,
      "RevalFine": 0,
      "Sem": "",
      "ExamMonth": "",
      "ExamType": "",
      "AtomTransId": "",
      "MerchantTransId": "",
      "TransAmt": "0.0",
      "TransSurChargeAmt": "0.0",
      "TransDate": "",
      "BankTransId": "",
      "TransStatus": "",
      "BankName": "",
      "PaymentDonethrough": "",
      "CardNumber": "",
      "CardHolderName": "",
      "Email": "",
      "MobileNo": "",
      "Address": "",
      "TransDescription": "",
      "Success": 0,
      "NewTxnIdMain": "0",
      "AcyearId": 0,
      "StudentOnlineCertificatesVariable": [
        {
          "CertificateId": 0,
          "Copies": 0,
          "ExamType": "",
          "Sem": "",
          "MonthYear": "",
          "CopyType": 0
        }
      ]
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          certificates = data['cerificatesDropDownForFlutterList']
              .where((certificate) =>
                  certificate['certificateId'] == 4 ||
                  certificate['certificateId'] == 1)
              .toList();

          // Initialize selectedCopies with 0 for each certificate (default to 0)
          selectedCopies = {
            for (var certificate in certificates)
              certificate['certificateId']: 0,
          };
        });
      } else {
        print("Failed to fetch certificates");
      }
    } catch (e) {
      print("Error fetching certificates: $e");
    }
  }

  String generateRandomText(int length) {
    const _chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final _random = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => _chars.codeUnitAt(_random.nextInt(_chars.length))));
  }

  Future<void> showTotal(String captcha, String newTxnId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String admnNo = prefs.getString('admnNo') ?? '';
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    int schoolId = prefs.getInt('schoolId') ?? 0;
    int studId = prefs.getInt('studId') ?? 0;
    String colCode = prefs.getString('colCode') ?? '';
    String collegeId = prefs.getString('collegeId') ?? '';

    final selectedCertificates = selectedCopies.entries
        .where((entry) => entry.value > 0)
        .map((entry) => {
              "CertificateId": entry.key,
              "Copies": entry.value,
              "ExamType": selectedExamType[entry.key],
              "Sem": selectedSem[entry.key],
              "MonthYear": selectedMonthYear[entry.key],
              "CopyType": 0,
            })
        .toList();

    if (selectedCertificates.isEmpty) {
      showDialog(
          context: context,
          builder: (context) => const AlertDialog(
                title: Text("No Selection"),
                content: Text("Please select at least one certificate."),
              ));
      return;
    }

    final requestBody = {
      "GrpCode": grpCodeValue,
      "ColCode": colCode,
      "CollegeId": collegeId,
      "SchoolId": schoolId,
      "Flag": 1,
      "FYearId": 0,
      "CertificateIds": "",
      "Copies": "",
      "CaptchaImg": captcha,
      "PaymentDate": "",
      "StudId": studId,
      "ReValFee": 0,
      "AdmnNo": admnNo,
      "ReCountFee": 0,
      "RevalFine": 0,
      "Sem": "",
      "ExamMonth": "",
      "ExamType": "",
      "AtomTransId": "",
      "MerchantTransId": "",
      "TransAmt": "0.0",
      "TransSurChargeAmt": "0.0",
      "TransDate": "",
      "BankTransId": "",
      "TransStatus": "",
      "BankName": "",
      "PaymentDonethrough": "",
      "CardNumber": "",
      "CardHolderName": "",
      "Email": "",
      "MobileNo": "",
      "Address": "",
      "TransDescription": "",
      "Success": 0,
      "NewTxnIdMain": "0",
      "AcyearId": 0,
      "StudentOnlineCertificatesVariable": selectedCertificates,
    };
    print(requestBody);

    try {
      final url =
          'https://mritsexams.com/CoreAPI/Flutter/CertificateDropDownForFlutter';
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        final certificatesList =
            data['cerificatesDropDownForFlutterList'] as List<dynamic>;
        StringBuffer messageBuffer = StringBuffer();
        int grandTotal = 0;

        for (var certificate in certificatesList) {
          final certificateName =
              certificate['certificateName'] ?? "Unknown Certificate";
          final totalAmount = (certificate['totalAmount'] ?? 0) as num;
          grandTotal += totalAmount.toInt();
          messageBuffer.writeln("$certificateName: $totalAmount");
        }
        messageBuffer.writeln("\nGrand Total: $grandTotal");

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Total Amount"),
            content:
                SingleChildScrollView(child: Text(messageBuffer.toString())),
            actions: [
              TextButton(
                onPressed: () {
                  final atomTransId = data['cerificatesDropDownForFlutterList']
                      [0]['atomTransId'];
                  // Extract Paytm details for transaction
                  final paytmDetails = data['paytmDetailsList']?[0];
                  if (paytmDetails != null) {
                    final productId = paytmDetails['productId'] ?? '';
                    final ordeR_ID = paytmDetails['ordeR_ID'] ?? '';
                    final callbacK_URL = paytmDetails['callbacK_URL'] ?? '';
                    final txnToken = paytmDetails['paytmResponseCertificates']
                            ['body']['txnToken'] ??
                        '';

                    // Close the dialog
                    Navigator.of(context).pop();

                    // Proceed with Paytm payment
                    initiatePaytmTransaction(txnToken, productId, grandTotal,
                        ordeR_ID, callbacK_URL, captcha, atomTransId,newTxnId);
                  } else {
                    print("No Paytm details found");
                    Navigator.of(context)
                        .pop(); // Close the dialog if no details found
                  }
                },
                child: const Text("Proceed to Pay"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                // Close the dialog
                child: const Text("Cancel"),
              ),
            ],
          ),
        );
      } else {
        print("Failed to fetch total");
      }
    } catch (e) {
      print("Error fetching total: $e");
    }
  }

  Future<void> Tempsave() async {
    String paymentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String admnNo = prefs.getString('admnNo') ?? '';
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    int schoolId = prefs.getInt('schoolId') ?? 0;
    int studId = prefs.getInt('studId') ?? 0;
    String colCode = prefs.getString('colCode') ?? '';
    String collegeId = prefs.getString('collegeId') ?? '';
    var captcha = generateRandomText(6).toString();
    final selectedCertificates = selectedCopies.entries
        .where((entry) => entry.value > 0)
        .map((entry) => {
              "CertificateId": entry.key,
              "Copies": entry.value,
              "ExamType": selectedExamType[entry.key],
              "Sem": selectedSem[entry.key],
              "MonthYear": selectedMonthYear[entry.key],
              "CopyType": 0,
            })
        .toList();

    if (selectedCertificates.isEmpty) {
      showDialog(
          context: context,
          builder: (context) => const AlertDialog(
                title: Text("No Selection"),
                content: Text("Please select at least one certificate."),
              ));
      return;
    }
    final requestBody = {
      "GrpCode": grpCodeValue,
      "ColCode": colCode,
      "CollegeId": collegeId,
      "SchoolId": schoolId,
      "Flag": 4,
      "FYearId": 0,
      "CertificateIds": "",
      "Copies": "",
      "CaptchaImg": captcha,
      "PaymentDate": paymentDate,
      "StudId": studId,
      "ReValFee": 0,
      "AdmnNo": admnNo,
      "ReCountFee": 0,
      "RevalFine": 0,
      "Sem": "",
      "ExamMonth": "",
      "ExamType": "",
      "AtomTransId": "",
      "MerchantTransId": "",
      "TransAmt": "0.0",
      "TransSurChargeAmt": "0.0",
      "TransDate": "",
      "BankTransId": "",
      "TransStatus": "",
      "BankName": "",
      "PaymentDonethrough": "",
      "CardNumber": "",
      "CardHolderName": "",
      "Email": "",
      "MobileNo": "",
      "Address": "",
      "TransDescription": "",
      "Success": 0,
      "NewTxnIdMain": "0",
      "AcyearId": 0,
      "StudentOnlineCertificatesVariable": selectedCertificates,
    };
    print("zzz" + requestBody.toString());

    final url =
        'https://mritsexams.com/CoreAPI/Flutter/CertificateDropDownForFlutter';
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      print("1234" + data.toString());
      if (data['tempSavingList'] != null && data['tempSavingList'].length > 1) {
        String newTxnId = data['tempSavingList'][1]['newTxnId'].toString();
        print("NewTxnId: " + newTxnId);

        // Pass newTxnId and captcha to showTotal
        showTotal(captcha, newTxnId);
      } else {
        print("tempSavingList is null or doesn't have enough entries.");
      }



    }
  }

  Future<void> initiatePaytmTransaction(
      txnToken, productId, grandTotal,
      ordeR_ID, callbacK_URL, captcha, atomTransId,newTxnId, // Use newTxnId instead of atomTransId
  ) async {
    try {
      print("Initiating Paytm transaction with:");
      print("Product ID: $productId");
      print("Transaction Token: $txnToken");
      print("Amount: $grandTotal");
      print("Order ID: $ordeR_ID");
      print("Callback URL: $callbacK_URL");

      var response = AllInOneSdk.startTransaction(productId, ordeR_ID,
          grandTotal.toString(), txnToken, callbacK_URL, false, false);

      response.then((value) {
        print("Transaction Successful: $value");
        String txnId = value?['TXNID'];
        String txnAmount = value?['TXNAMOUNT'];
        String paymentMode = value?['PAYMENTMODE'];
        String bankTxnId = value?['BANKTXNID'];
        String txnDate = value?['TXNDATE'];

        // Call the API again with Flag = 5
        callApiWithFlag5(txnId, ordeR_ID, txnAmount, paymentMode, bankTxnId,
            txnDate, captcha, newTxnId, productId, atomTransId);
      }).catchError((onError) {
        print("Transaction failed: $onError");
      });
    } catch (e) {
      print("Error in initiating Paytm transaction: $e");
    }
  }

  Future<void> callApiWithFlag5(
      String txnId,
      String orderId,
      String txnAmount,
      String paymentMode,
      String bankTxnId,
      String txnDate,
      String captcha,

      String productId,
      newTxnId, atomTransId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String admnNo = prefs.getString('admnNo') ?? '';
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    int schoolId = prefs.getInt('schoolId') ?? 0;
    int studId = prefs.getInt('studId') ?? 0;
    int fYearId = prefs.getInt('fYearId') ?? 0;
    String betSem = prefs.getString('betSem') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String collegeId = prefs.getString('collegeId') ?? '';

    final selectedCertificates = selectedCopies.entries
        .where((entry) => entry.value > 0)
        .map((entry) => {
              "CertificateId": entry.key,
              "Copies": entry.value,
              "ExamType": selectedExamType[entry.key],
              "Sem": selectedSem[entry.key],
              "MonthYear": selectedMonthYear[entry.key],
              "CopyType": 0,
            })
        .toList();

    final requestBody = {
      "GrpCode": grpCodeValue,
      "ColCode": colCode,
      "CollegeId": collegeId,
      "SchoolId": schoolId,
      "Flag": 5,
      "FYearId": fYearId,
      "CertificateIds": "",
      "Copies": "",
      "CaptchaImg": captcha,
      "PaymentDate": txnDate,
      "StudId": studId,
      "ReValFee": 0,
      "AdmnNo": admnNo,
      "ReCountFee": 0,
      "RevalFine": 0,
      "Sem": betSem,
      "ExamMonth": "",
      "ExamType": "",
      "AtomTransId": atomTransId.toString(),
      "MerchantTransId": productId,
      "TransAmt": txnAmount,
      "TransSurChargeAmt": "0.0",
      "TransDate": txnDate,
      "BankTransId": bankTxnId,
      "TransStatus": "TXN_SUCCESS",
      "BankName": paymentMode,
      "PaymentDonethrough": "",
      "CardNumber": "",
      "CardHolderName": "",
      "Email": "",
      "MobileNo": "",
      "Address": "",
      "TransDescription": "Certificate Payment",
      "Success": 0,
      "NewTxnIdMain": newTxnId,
      "AcyearId": 0,
      "StudentOnlineCertificatesVariable": selectedCertificates,
    };
    print(requestBody);


      final url =
          'https://mritsexams.com/CoreAPI/Flutter/CertificateDropDownForFlutter';
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

    if (response.statusCode == 200) {
      print(response.body);
      final responseData = jsonDecode(response.body);
      print("API called successfully with Flag 5");

      // Check if tempSavingList exists and is not empty
      if (responseData.containsKey('tempSavingList') &&
          responseData['tempSavingList'] is List &&
          responseData['tempSavingList'].isNotEmpty) {

        final tempSavingData = responseData['tempSavingList'][0]; // Get the first item

        if (tempSavingData.containsKey('recId')) {
          int receiptId = tempSavingData['recId']; // Extract recId
          print('Receipt ID: $receiptId');

          // Call _fetchFeeReceiptsReport with the extracted recId
          await _fetchFeeReceiptsReport(receiptId, context);
        } else {
          print('recId key not found in tempSavingData');
          throw Exception('recId key not found in tempSavingData');
        }
      } else {
        print('tempSavingList is empty or does not exist');
      }
    } else {
      print("Failed to call API with Flag 5. Status code: ${response.statusCode}");
      print(response.body);
    }
  }
  Future<void> _fetchFeeReceiptsReport(int receiptId, BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String grpCodeValue = prefs.getString('grpCode') ?? '';
      String colCode = prefs.getString('colCode') ?? '';
      int schoolId = prefs.getInt('schoolId') ?? 0;

      // Create the request body as a Map
      final requestBody = {
        "GrpCode": grpCodeValue,
        "CollegeId": "0001",
        "ColCode": "PSS",
        "SchoolId": schoolId,
        "RecId": receiptId,

        "Words": "rupees Only",
        "CertifcateId":0
      };

      // Print the request body before sending it
      print('Request Body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse('https://mritsexams.com/CoreApi/Android/TranscriptReports'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        print('Response body: ${response.body}');

        final fileName = 'preview_receipt.pdf';
        Directory tempDir = await getTemporaryDirectory();
        String filePath = '${tempDir.path}/$fileName';
        File pdfFile = File(filePath);
        await pdfFile.writeAsBytes(response.bodyBytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF downloaded successfully.')),
        );

        // Launch the PDF
        _launchPDF(context, filePath);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download PDF. Status code: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

// Method to launch PDF using open_file package
  void _launchPDF(BuildContext context, String filePath) async {
    final result = await OpenFile.open(filePath);

    if (result.type == ResultType.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening PDF: ${result.message}')),
      );
    }
  }

  Future<void> selectCopies(int certificateId, int copies) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String grpCodeValue = prefs.getString('grpCode') ?? '';
    int schoolId = prefs.getInt('schoolId') ?? 0;
    int studId = prefs.getInt('studId') ?? 0;
    String colCode = prefs.getString('colCode') ?? '';
    String collegeId = prefs.getString('collegeId') ?? '';

    setState(() {
      selectedCopies[certificateId] = copies;
    });
    final requestBody = {
      "GrpCode": grpCodeValue,
      "ColCode": colCode,
      "CollegeId": collegeId,
      "SchoolId": schoolId,
      "Flag": 3,
      "FYearId": 0,
      "CertificateIds": "",
      "Copies": "",
      "CaptchaImg": "",
      "PaymentDate": "",
      "StudId": studId,
      "ReValFee": 0,
      "ReCountFee": 0,
      "RevalFine": 0,
      "Sem": "",
      "ExamMonth": "",
      "ExamType": "",
      "AtomTransId": "",
      "MerchantTransId": "",
      "TransAmt": "0.0",
      "TransSurChargeAmt": "0.0",
      "TransDate": "",
      "BankTransId": "",
      "TransStatus": "",
      "BankName": "",
      "PaymentDonethrough": "",
      "CardNumber": "",
      "CardHolderName": "",
      "Email": "",
      "MobileNo": "",
      "Address": "",
      "TransDescription": "",
      "Success": 0,
      "NewTxnIdMain": "0",
      "AcyearId": 0,
      "StudentOnlineCertificatesVariable": [
        {
          "CertificateId": certificateId, // Use selected certificateId
          "Copies": copies, // Use selected copies
          "ExamType": "",
          "Sem": "",
          "MonthYear": "",
          "CopyType": 0
        }
      ]
    };
    print(requestBody);

    try {
      final url =
          'https://mritsexams.com/CoreAPI/Flutter/CertificateDropDownForFlutter';
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Update examTypeList and semList based on the response
        setState(() {
          examTypeList[certificateId] = data['examTypeList'];
          semList[certificateId] = data['semList'];
        });

        print("Copies updated successfully");
      } else {
        print("Failed to update copies");
      }
    } catch (e) {
      print("Error updating copies: $e");
    }
  }

  Future<void> fetchMonthYear(int certificateId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    int schoolId = prefs.getInt('schoolId') ?? 0;
    int studId = prefs.getInt('studId') ?? 0;
    String colCode = prefs.getString('colCode') ?? '';
    String collegeId = prefs.getString('collegeId') ?? '';
    final selectedExamTypeValue = selectedExamType[certificateId] ?? '';
    final selectedSemValue = selectedSem[certificateId] ?? '';

    if (selectedExamTypeValue.isNotEmpty && selectedSemValue.isNotEmpty) {
      final requestBody = {
        "GrpCode": grpCodeValue,
        "ColCode": colCode,
        "CollegeId": collegeId,
        "SchoolId": schoolId,
        "Studid": studId.toString(),
        "Sem": selectedSemValue,
        "ExamType": selectedExamTypeValue
      };
      print(requestBody);

      try {
        final url =
            'https://mritsexams.com/CoreAPI/Flutter/MonthYearDropdownForCertificates';
        final response = await http.post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print(data);
          final List<dynamic>? monthYearListData =
              data['monthYearDropdownForCertificatesList'];

          if (monthYearListData != null && monthYearListData.isNotEmpty) {
            setState(() {
              monthYearList[certificateId] = monthYearListData;
            });
          } else {
            print("MonthYear list is empty or null");
          }
        } else {
          print("Failed to fetch Month/Year data");
        }
      } catch (e) {
        print("Error fetching Month/Year: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: certificates.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: certificates.length,
                    itemBuilder: (context, index) {
                      final certificate = certificates[index];
                      final certificateId = certificate['certificateId'];
                      final certificateName = certificate['certificateName'];

                      return Column(
                        children: [
                          ListTile(
                            title: Text(certificateName),
                            trailing: DropdownButton<int>(
                              value: selectedCopies[certificateId] ?? 0,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    selectCopies(certificateId, value);
                                  });
                                }
                              },
                              items: List.generate(
                                      11, (i) => i) // Generates from 0 to 10
                                  .map<DropdownMenuItem<int>>(
                                    (int value) => DropdownMenuItem<int>(
                                      value: value,
                                      child: Text(value.toString()),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),

                          // Dropdown for examType if available
                          if (examTypeList[certificateId] != null)
                            DropdownButton<String>(
                              value: selectedExamType[certificateId],
                              hint: const Text('Select Exam Type'),
                              onChanged: (value) {
                                setState(() {
                                  selectedExamType[certificateId] = value!;
                                });
                                fetchMonthYear(certificateId);
                              },
                              items: examTypeList[certificateId]!
                                  .map<DropdownMenuItem<String>>(
                                    (exam) => DropdownMenuItem<String>(
                                      value: exam['examType'],
                                      child: Text(exam['examType']),
                                    ),
                                  )
                                  .toList(),
                            ),

                          // Dropdown for semester if available
                          if (semList[certificateId] != null)
                            DropdownButton<String>(
                              value: selectedSem[certificateId],
                              hint: const Text('Select Semester'),
                              onChanged: (value) {
                                setState(() {
                                  selectedSem[certificateId] = value!;
                                });
                                fetchMonthYear(certificateId);
                              },
                              items: semList[certificateId]!
                                  .map<DropdownMenuItem<String>>(
                                    (sem) => DropdownMenuItem<String>(
                                      value: sem['sem'],
                                      child: Text(sem['sem']),
                                    ),
                                  )
                                  .toList(),
                            ),
                          if (monthYearList[certificateId] != null)
                            DropdownButton<String>(
                              value: selectedMonthYear[certificateId],
                              hint: const Text('Select Month/Year'),
                              onChanged: (value) {
                                setState(() {
                                  selectedMonthYear[certificateId] = value!;
                                });
                              },
                              items: monthYearList[certificateId]!
                                  .map<DropdownMenuItem<String>>(
                                    (monthYear) => DropdownMenuItem<String>(
                                      value: monthYear['monthYear'],
                                      child: Text(monthYear['monthYear']),
                                    ),
                                  )
                                  .toList(),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: Container(
                    width: 220,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen,
                      ),
                      onPressed: areAllSelectionsValid()
                          ? () async {
                              await Tempsave();
                            }
                          : null, // Disable the button if selections are incomplete
                      child: const Text(
                        'Show Total',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  bool areAllSelectionsValid() {
    for (var certificate in certificates) {
      final certificateId = certificate['certificateId'];
      if (examTypeList[certificateId] != null &&
          (selectedExamType[certificateId] == null ||
              selectedSem[certificateId] == null ||
              selectedMonthYear[certificateId] == null)) {
        return false;
      }
    }
    return true;
  }
}
