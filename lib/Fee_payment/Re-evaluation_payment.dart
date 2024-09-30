import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../views/MainPage.dart';
import '../views/PROVIDER.dart';
import '../views/betprovider.dart';

class Reevaluation extends StatefulWidget {
  const Reevaluation({Key? key}) : super(key: key);

  @override
  State<Reevaluation> createState() => _ReevaluationState();
}

class _ReevaluationState extends State<Reevaluation> {
  bool _isLoading = true;
  Map<String, dynamic> _feeDetails = {};
  List<String> _semesters = [];
  List<String> _examTypes = [];
  List<Map<String, dynamic>> _subjects = [];
  String? _selectedSemester;
  String? _selectedExamType;
  String _responseMessage = '';
  List<Map<String, dynamic>> _revalTypes = [];
  String? _selectedRevalType;
  bool _showButton = false;
  String? _monthYear;

  get captcha => generateRandomText(6);

  String generateRandomText(int length) {
    const String chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final Random random = Random();

    return String.fromCharCodes(Iterable.generate(
      length,
          (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ));
  }

  @override
  void initState() {
    super.initState();
    fetchRevalFeeDetails();
    fetchSemesters();
    fetchRevalTypes(_semesters.toString());
  }
  Future<void> _showRevalDetails(BuildContext context, String semester,
      String examType, String captcha) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String userName = prefs.getString('userName') ?? '';
    String email = prefs.getString('email') ?? '';
    String betStudMobile = prefs.getString('betStudMobile') ?? '';
    int schoolid = prefs.getInt('schoolId') ?? 00;
    int studId = prefs.getInt('studId') ?? 00;
    int fYearId = prefs.getInt('fYearId') ?? 00;
    int acYearId = prefs.getInt('acYearId') ?? 00;
    int studUserId = prefs.getInt('studUserId') ?? 00;
    String betCourseId = prefs.getString('betCourseId') ?? '';

    final monthYear = await showmonth(semester, examType);
    if (monthYear == null) {
      throw Exception('Failed to fetch month year');
    }

    // Filter subjects to include only those with selected revaluation or recount type
    final selectedSubjects = _subjects.where((subject) {
      return subject['selectedRevalType'] != null; // Only include selected subjects
    }).toList();

    if (selectedSubjects.isEmpty) {
      _showErrorDialog(context, "Please select subjects for revaluation or recounting.");
      return;
    }

    // Prepare request body
    final requestBody = {
      "GrpCode": grpCodeValue,
      "CollegeId": "0001",
      "ColCode": "PSS",
      "SchoolId": schoolid,
      "StudId": studId,
      "Sem": _selectedSemester ?? '',
      "RecDate": DateFormat('yyyy-MM-dd').format(DateTime.now()),
      "MonthYear": monthYear,
      "ExamType": examType,
      "ReValuationShowFeeDetailsTableVariable": selectedSubjects.map((subject) {
        return {
          "SubId": subject['subId'].toString(),
          "ReValType": subject['selectedRevalType'] == "Re-Evaluation" ? "0" : "1",
        };
      }).toList(),
    };

    print("Request Body: $requestBody");

    // Send HTTP POST request
    final response = await http.post(
      Uri.parse('https://mritsexams.com/CoreApi/Android/ReValuationShowFeeDetails'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );

    // Handle response
    if (response.statusCode == 200) {

      final responseData = jsonDecode(response.body);
      print(responseData);
      if (responseData['reValuationShowFeeDetailsList'] != null &&
          responseData['reValuationShowFeeDetailsList'].isNotEmpty) {
        final feeDetails = responseData['reValuationShowFeeDetailsList'][0];
        _showRevalDetailsBottomSheet(
          context,
          feeDetails,
          monthYear,
          examType,
          semester,
          captcha,
        );
      } else {
        _showErrorDialog(context, "No fee details found in the response");
      }
    } else {
      _showErrorDialog(
        context,
        "Failed to get revaluation fee details. Status code: ${response.statusCode}",
      );
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }


  void _showRevalDetailsBottomSheet(BuildContext context,
      Map<String, dynamic> responseData,
      String monthYear,
      String examType,
      String semester,
      captcha) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          widthFactor: 1,
          heightFactor: 0.75,
          // Adjust the width factor as needed
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Re-Evaluation Fee Details",
                            style: TextStyle(
                              fontSize: 20.0,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: RichText(
                                textAlign: TextAlign.start,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Re-Evaluation Subjects: ",
                                      style: TextStyle(
                                        color: Color(0xFFFF9800),
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                      "${responseData['noOfRevalSubjects']}",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: RichText(
                                textAlign: TextAlign.start,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Re-Evaluation Fee: ",
                                      style: TextStyle(
                                        color: Color(0xFFFF9800),
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "${responseData['revaluationFee']}",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: RichText(
                                textAlign: TextAlign.start,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Re-Count Subjects: ",
                                      style: TextStyle(
                                        color: Color(0xFFFF9800),
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                      "${responseData['noofReCountSubject']}",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: RichText(
                                textAlign: TextAlign.start,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Re-Count Fee: ",
                                      style: TextStyle(
                                        color: Color(0xFFFF9800),
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "${responseData['reCountingFee']}",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: RichText(
                                textAlign: TextAlign.start,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Fine Amount: ",
                                      style: TextStyle(
                                        color: Color(0xFFFF9800),
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "${responseData['fine']}",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: RichText(
                                textAlign: TextAlign.start,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Total Amount: ",
                                      style: TextStyle(
                                        color: Color(0xFFFF9800),
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "${responseData['total']}",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                Fluttertoast.showToast(
                                  msg:
                                  "Page Redirecting to Paytm Payments Page...",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.white,
                                  textColor: Colors.black,
                                  fontSize: 16.0,
                                );
                                proceedToPay(
                                  responseData,
                                  monthYear,
                                  examType,
                                  semester,
                                  captcha,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors
                                    .lightGreen, // Set background color to green
                              ),
                              child: Text(
                                "Proceed to Pay",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void proceedToPay(Map<String, dynamic> responseData, String monthYear,
      String examType, String semester, String captcha) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String grpCodeValue = prefs.getString('grpCode') ?? '';
      String colCode = prefs.getString('colCode') ?? '';
      String userName = prefs.getString('userName') ?? '';
      String email = prefs.getString('email') ?? '';
      String betStudMobile = prefs.getString('betStudMobile') ?? '';
      int schoolid = prefs.getInt('schoolId') ?? 00;
      int studId = prefs.getInt('studId') ?? 00;
      int fYearId = prefs.getInt('fYearId') ?? 00;
      int acYearId = prefs.getInt('acYearId') ?? 00;
      int betStudUserId = prefs.getInt('betStudUserId') ?? 00;
      String betCourseId = prefs.getString('betCourseId') ?? '';

      // Filter subjects to only include those that have a selected revaluation type
      List<Map<String, dynamic>> selectedSubjects = _subjects
          .where((subject) => subject['selectedRevalType'] != null)
          .map((subject) {
        return {
          "subId": subject['subId'].toString(),
          "reValType": subject['selectedRevalType'] == "Re-Evaluation" ? 1 : 0
        };
      })
          .toList();

      final requestBody = {
        "grpCode": grpCodeValue,
        "collegeId": "0001",
        "colCode": "pss",
        "schoolId": schoolid,
        "studId": studId,
        "userId": betStudUserId,
        "sem": _selectedSemester ?? "",
        "paymentDate": DateFormat('yyyy-MM-dd').format(DateTime.now()),
        "captchaImg": captcha,
        "acYearId": acYearId,
        "RevalFee": responseData['revaluationFee'] ?? 0,
        "ReCountFee": responseData['reCountingFee'] ?? 0,
        "Fine": responseData['reValFine'] ?? 0,
        "ExamType": _selectedExamType ?? "",
        "monthYear": monthYear,
        "fYearId": fYearId,
        "flutterSaveReEvaluationFeeTempDataTablevariable": selectedSubjects,
      };
      print("sp" + requestBody.toString());

      final response = await http.post(
        Uri.parse(
            'https://mritsexams.com/CoreApi/Flutter/SaveReEvaluationFeeTempData'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        var transactionData = jsonDecode(response.body);
        var saveReEvaluationFeeTempDataList =
        transactionData['saveReEvaluationFeeTempDataList'];
        var firstItem = saveReEvaluationFeeTempDataList[0];
        var AtomTransId = firstItem['AtomTransId'];
        var newTxnId = firstItem['newTxnId'];
        print(AtomTransId);
        print(newTxnId);

        await initiatePaytmTransaction(
            transactionData,
            responseData,
            newTxnId,
            AtomTransId,
            examType,
            monthYear,
            semester,
            captcha);
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text(
                  "Failed to proceed with payment. Status code: ${response
                      .statusCode}"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      print('Error initiating Paytm transaction: $error');
    }
  }


  Future<void> initiatePaytmTransaction(Map<String, dynamic> transactionData,
      responseData,
      int newTxnId,
      String AtomTransId,
      String examType,
      String monthYear,
      String semester,
      captcha) async {
    try {
      if (transactionData == null) {
        throw Exception('Transaction data is null');
      }

      var token = transactionData['saveReEvaluationFeeTempDataList'][0]
      ['paytmResponse']['body']['txnToken'] ??
          '';

      var response = AllInOneSdk.startTransaction(
        transactionData['saveReEvaluationFeeTempDataList'][0]['MID'] ?? '',
        transactionData['saveReEvaluationFeeTempDataList'][0]['ORDER_ID'] ?? '',
        transactionData['saveReEvaluationFeeTempDataList'][0]['TXN_AMOUNT'] ??
            '',
        token,
        transactionData['saveReEvaluationFeeTempDataList'][0]['CALLBACK_URL'] ??
            '',
        false,
        false,
      );

      response.then((value) async {
        print("Paytm Transaction Response: $value");
        String gatewayName = value?['GATEWAYNAME']?.toString() ?? '';
        String status = value?['STATUS']?.toString() ?? '';
        String banktxnid = value?['BANKTXNID']?.toString() ?? '';
        String txnamount = value?['TXNAMOUNT']?.toString() ?? '';
        String txndate = value?['TXNDATE']?.toString() ?? '';
        String mid = value?['MID']?.toString() ?? '';
        String orderid = value?['ORDERID']?.toString() ?? '';
        String TXNID = value?['TXNID']?.toString() ?? '';

        print("Gateway Name: $gatewayName");
        print("Status: $status");
        print("Bank Transaction ID: $banktxnid");
        print("Transaction Date: $txndate");
        print("Transaction Amount: $txnamount");
        print("Merchant ID: $mid");
        print("Order ID: $orderid");
        print("Transaction ID: $TXNID");

        await _callAdditionalApi(
            transactionData,
            newTxnId,
            AtomTransId,
            gatewayName,
            txnamount,
            txndate,
            banktxnid,
            TXNID,
            orderid,
            status,
            responseData,
            examType,
            monthYear,
            mid,
            semester,
            captcha);
      }).catchError((onError) {
        print('Error starting transaction: $onError');
      });
    } catch (error) {
      print('Error initiating Paytm transaction: $error');
    }
  }

  Future<void> _callAdditionalApi(Map<String, dynamic> transactionData,
      int newTxnId,
      String AtomTransId,
      String gatewayName,
      String txnamount,
      String txndate,
      String banktxnid,
      String TXNID,
      String orderid,
      String status,
      responseData,
      String examType,
      String monthYear,
      String mid,
      String semester,
      captcha) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String userName = prefs.getString('userName') ?? '';
    String email = prefs.getString('email') ?? '';
    String betStudMobile = prefs.getString('betStudMobile') ?? '';
    int schoolid = prefs.getInt('schoolId') ?? 00;
    int studId = prefs.getInt('studId') ?? 00;
    int fYearId = prefs.getInt('fYearId') ?? 00;
    int acYearId = prefs.getInt('acYearId') ?? 00;
    int betStudUserId = prefs.getInt('betStudUserId') ?? 00;
    String collegeId = prefs.getString('collegeId') ?? '';

    try {
      final response = await http.post(
        Uri.parse(
            'https://mritsexams.com/CoreApi/Android/SaveReEvaluationFeeMainData'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "CollegeId": collegeId ?? '',
          "GrpCode": grpCodeValue,
          "ColCode": colCode,
          "SchoolId": schoolid,
          "StudId": studId,
          "NewTxnId": newTxnId,
          "CaptchaImg": captcha,
          "AcYearId": acYearId ?? '',
          "FeeStructureId": '${transactionData['FeeStructId'] ?? ''}',
          "PaymentDate": DateFormat('yyyy-MM-dd').format(DateTime.now()),
          "ReValFee": '${responseData['revaluationFee'] ?? ''}',
          "ReCountFee": '${responseData['reCountingFee'] ?? ''}',
          "RevalFine": '${responseData['reValFine'] ?? ''}',
          "Sem": semester.toString(),
          "FYearId": fYearId ?? '',
          "ExamMonth": monthYear,
          "ExamType": examType,
          "AtomTransId": AtomTransId.toString(),
          "MerchantTransId": mid.toString(),
          "TransAmt": txnamount,
          "TransSurChargeAmt": 0,
          "TransDate": DateFormat('yyyy-MM-dd').format(DateTime.now()),
          "BankTransId": banktxnid,
          "TransStatus": status,
          "BankName": "",
          "PaymentDoneThrough": gatewayName,
          "CardNumber": "",
          "CardHolderName": "",
          "Email": email,
          "MobileNo":
          betStudMobile,
          "Address": "HYDERABAD",
          "TransDescription": status,
          "Success": 0,
        }),
      );

      // print('Request Body: ${jsonEncode({
      //       "CollegeId": betStudentProvider.studentInformation?.collegeId ?? '',
      //       "GrpCode": betStudentProvider.studentInformation?.grpCode ?? '',
      //       "ColCode": betStudentProvider.studentInformation?.colCode ?? '',
      //       "SchoolId": betStudentProvider.studentInformation?.schoolId ?? '',
      //       "StudId": userDetails.studId ?? '',
      //       "NewTxnId": newTxnId,
      //       "CaptchaImg": captcha,
      //       "AcYearId": userDetails.acYearId ?? '',
      //       "FeeStructureId": '${transactionData['FeeStructId'] ?? ''}',
      //       "PaymentDate": DateFormat('yyyy-MM-dd').format(DateTime.now()),
      //       "ReValFee": '${responseData['revaluationFee'] ?? ''}',
      //       "ReCountFee": '${responseData['reCountingFee'] ?? ''}',
      //       "RevalFine": '${responseData['reValFine'] ?? ''}',
      //       "Sem": semester.toString(),
      //       "FYearId": userDetails.fYearId ?? '',
      //       "ExamMonth": monthYear,
      //       "ExamType": examType,
      //       "AtomTransId": AtomTransId.toString(),
      //       "MerchantTransId": mid.toString(),
      //       "TransAmt": txnamount,
      //       "TransSurChargeAmt": 0,
      //       "TransDate": DateFormat('yyyy-MM-dd').format(DateTime.now()),
      //       "BankTransId": banktxnid,
      //       "TransStatus": status,
      //       "BankName": "",
      //       "PaymentDoneThrough": gatewayName,
      //       "CardNumber": "",
      //       "CardHolderName": "",
      //       "Email": betStudentProvider.studentInformation?.email ?? '',
      //       "MobileNo":
      //           betStudentProvider.studentInformation?.betStudMobile ?? '',
      //       "Address": "HYDERABAD",
      //       "TransDescription": status,
      //       "Success": 0,
      //     })}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(response.body);
        print("Response from additional API: ${response.body}");
        if (responseData['saveReEvaluationFeeMainDataList'] != null &&
            responseData['saveReEvaluationFeeMainDataList'].isNotEmpty) {
          // Assuming there is only one entry in the list
          int receiptId =
          responseData['saveReEvaluationFeeMainDataList'][0]['recieptId'];
          await _fetchFeeReceiptsReport(receiptId);
        } else {
          print('recieptid key not found in saveReEvaluationFeeMainDataList');
          throw Exception(
              'recieptid key not found in saveReEvaluationFeeMainDataList');
        }

        // Make another API call to FeeReceiptsReports if needed
      } else {
        throw Exception(
            'Error: Failed to call additional API. Status code: ${response
                .statusCode}');
      }
    } catch (e) {
      print('Error calling additional API: $e');
    }
  }


  Future<void> _fetchFeeReceiptsReport(int receiptId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String grpCodeValue = prefs.getString('grpCode') ?? '';
      int schoolid = prefs.getInt('schoolId') ?? 0;

      final response = await http.post(
        Uri.parse(
            'https://mritsexams.com/CoreApi/Android/FeeReceiptsReports'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "GrpCode": grpCodeValue,
          "CollegeId": "0001",
          "ColCode": "PSS",
          "SchoolId": schoolid,
          "RecId": receiptId,
          "Type": "Re-Evaluation",
          "Words": "",
          "Flag": 1,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>Profile()));
        print('Response from FeeReceiptsReports API: ${response.body}');

        final fileName = 'preview_receipt.pdf';
        Directory tempDir = await getTemporaryDirectory();
        String filePath = '${tempDir.path}/$fileName';
        File pdfFile = File(filePath);
        await pdfFile.writeAsBytes(response.bodyBytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF downloaded successfully.'),
          ),
        );

        // Preview the PDF file
        _launchPDF(context, filePath);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to download PDF. Status code: ${response.statusCode}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  Future<void> _launchPDF(BuildContext context, String path) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PDFView(
              filePath: path,
              enableSwipe: true,
              swipeHorizontal: true,
            ),
      ),
    );
  }



  Future<void> fetchRevalFeeDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String userName = prefs.getString('userName') ?? '';
    String email = prefs.getString('email') ?? '';
    String betStudMobile = prefs.getString('betStudMobile') ?? '';
    int schoolid = prefs.getInt('schoolId') ?? 00;
    int studId = prefs.getInt('studId') ?? 00;
    int fYearId = prefs.getInt('fYearId') ?? 00;
    int acYearId = prefs.getInt('acYearId') ?? 00;
    int studUserId = prefs.getInt('studUserId') ?? 00;
    String betCourseId = prefs.getString('betCourseId') ?? '';
    final requestBody = {
      "GrpCode": grpCodeValue,
      "ColCode": "pss",
      "CollegeId": "0001",
      "SchoolId": schoolid,
      "HtNo": userName,
      "Sem": "",
      "Flag": "2"
    };

    final response = await http.post(
      Uri.parse('https://mritsexams.com/CoreApi/Android/FeeDetials'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      setState(() {
        _feeDetails = data['revalFeeDetailsList'][0];
        _isLoading = false;
      });
    } else {
      throw Exception(
          'Failed to load fee details. Status code: ${response.statusCode}');
    }
  }

  Future<void> fetchSemesters() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String userName = prefs.getString('userName') ?? '';
    String email = prefs.getString('email') ?? '';
    String betStudMobile = prefs.getString('betStudMobile') ?? '';
    int schoolid = prefs.getInt('schoolId') ?? 00;
    int studId = prefs.getInt('studId') ?? 00;
    int fYearId = prefs.getInt('fYearId') ?? 00;
    int acYearId = prefs.getInt('acYearId') ?? 00;
    int studUserId = prefs.getInt('studUserId') ?? 00;
    String betCourseId = prefs.getString('betCourseId') ?? '';
    final requestBody = {
      "GrpCode": grpCodeValue,
      "ColCode": "pss",
      "CollegeId": "0001",
      "SchoolId": schoolid,
      "StudId": studId
    };

    final response = await http.post(
      Uri.parse('https://mritsexams.com/CoreApi/Android/ShowAllStudSems'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      setState(() {
        _semesters = List<String>.from(
            data['showAllStudSemsList'].map((item) => item['sem']));
        _selectedSemester = _semesters.isNotEmpty ? _semesters[0] : null;
      });
    } else {
      throw Exception(
          'Failed to load semesters. Status code: ${response.statusCode}');
    }
  }

  Future<void> fetchExamTypes(String semester) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String userName = prefs.getString('userName') ?? '';
    String email = prefs.getString('email') ?? '';
    String betStudMobile = prefs.getString('betStudMobile') ?? '';
    int schoolid = prefs.getInt('schoolId') ?? 00;
    int studId = prefs.getInt('studId') ?? 00;
    int fYearId = prefs.getInt('fYearId') ?? 00;
    int acYearId = prefs.getInt('acYearId') ?? 00;
    int studUserId = prefs.getInt('studUserId') ?? 00;
    String betCourseId = prefs.getString('betCourseId') ?? '';
    final requestBody = {
      "GrpCode": grpCodeValue,
      "ColCode": "pss",
      "CollegeId": "0001",
      "SchoolId":schoolid,
      "StudId":studId,
      "Sem": semester,
      "ExamType": ""
    };
    ;
    final response = await http.post(
      Uri.parse('https://mritsexams.com/CoreApi/Android/ShowStudExamType'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      setState(() {
        _examTypes = List<String>.from(
            data['studExamTypeList'].map((item) => item['examType']));
        _selectedExamType = _examTypes.isNotEmpty ? _examTypes[0] : null;
      });
    } else {
      throw Exception(
          'Failed to load exam types. Status code: ${response.statusCode}');
    }
  }

  Future<void> fetchSubjects(String semester, String examType) async {
       SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String userName = prefs.getString('userName') ?? '';
    String email = prefs.getString('email') ?? '';
    String betStudMobile = prefs.getString('betStudMobile') ?? '';
    int schoolid = prefs.getInt('schoolId') ?? 00;
    int studId = prefs.getInt('studId') ?? 00;
    int fYearId = prefs.getInt('fYearId') ?? 00;
    int acYearId = prefs.getInt('acYearId') ?? 00;
    int studUserId = prefs.getInt('studUserId') ?? 00;
    String betCourseId = prefs.getString('betCourseId') ?? '';

    // Fetch monthYear value
    final monthYear = await showmonth(semester, examType);
    if (monthYear == null) {
      throw Exception('Failed to fetch month year');
    }

    final requestBody = {
      "GrpCode": grpCodeValue,
      "ColCode": "pss",
      "CollegeId": "0001",
      "SchoolId": schoolid,
      "Studid": studId,
      "Sem": semester,
      "ExamType": examType,
      "MonthYear": monthYear
    };

    final response = await http.post(
      Uri.parse(
          'https://mritsexams.com/CoreApi/Android/StudentReEvaluationSubjectDetails'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      print("sssssss" + response.body);
      final data = jsonDecode(response.body);
      final subjectDetailsList = data['studentReEvaluationSubjectDetailsList'];

      if (subjectDetailsList != null && subjectDetailsList is List) {
        setState(() {
          _subjects =
              List<Map<String, dynamic>>.from(subjectDetailsList.map((item) {
            item['isChecked'] = false; // Initialize with unchecked state
            return item;
          }));
        });
      } else {
        throw Exception('Invalid response format for subjects list');
      }
    } else {
      throw Exception(
          'Failed to load subjects. Status code: ${response.statusCode}');
    }
  }

  Future<void> fetchRevalTypes(String semester) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String userName = prefs.getString('userName') ?? '';
    String email = prefs.getString('email') ?? '';
    String betStudMobile = prefs.getString('betStudMobile') ?? '';
    int schoolid = prefs.getInt('schoolId') ?? 00;
    int studId = prefs.getInt('studId') ?? 00;
    int fYearId = prefs.getInt('fYearId') ?? 00;
    int acYearId = prefs.getInt('acYearId') ?? 00;
    int studUserId = prefs.getInt('studUserId') ?? 00;
    String betCourseId = prefs.getString('betCourseId') ?? '';
    final requestBody = {
      "GrpCode": grpCodeValue,
      "ColCode": "pss",
      "CollegeId": "0001",
      "SchoolId": schoolid,
      "HtNo": userName
    };

    final response = await http.post(
      Uri.parse(
          'https://mritsexams.com/CoreApi/Android/StudRevalTypeDropDown'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _revalTypes =
            List<Map<String, dynamic>>.from(data['studRevalTypeDropDownList']);
        _selectedRevalType =
            _revalTypes.isNotEmpty ? _revalTypes[0]['revalType'] : null;
      });
    } else {
      throw Exception(
          'Failed to load revaluation types. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.lightGreen,
        title: Text(
          "Re-Evaluation Fee Payments",
          style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 15.0, bottom: 8.0),
                            // Adjust bottom padding as neededdd
                            child: Row(
                              children: [
                                Text(
                                  "Re-Eval Fee (Per sub): ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Color(0xFFFF9800),
                                  ),
                                ),
                                Text(
                                  _feeDetails['reValFee'] ?? 'N/A',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 45, right: 15),
                                  // Adjust padding as needed
                                  child: Row(
                                    children: [
                                      Text(
                                        "Fine Amt: ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Color(0xFFFF9800),
                                        ),
                                      ),
                                      Text(
                                        _feeDetails['reValFine'] ?? 'N/A',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 15.0, bottom: 8.0),
                            // Adjust bottom padding as needed
                            child: Row(
                              children: [
                                Text(
                                  "Re-Count Fee (Per Sub): ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Color(0xFFFF9800),
                                  ),
                                ),
                                Text(
                                  _feeDetails['reCountFee'] ?? 'N/A',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          hintText: 'Select Semester',
                          border: InputBorder.none,
                        ),
                        value: _selectedSemester,
                        items: _semesters.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedSemester = newValue;
                            _selectedExamType = null;
                            _examTypes = [];
                            _subjects = [];
                            fetchExamTypes(newValue!);
                          });
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          hintText: 'Select Exam Type',
                          border: InputBorder.none,
                        ),
                        value: _selectedExamType,
                        items: _examTypes.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            Fluttertoast.showToast(
                              msg: "Fetching Subjects List...",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.white,
                              textColor: Colors.black,
                              fontSize: 16.0,
                            );
                            _selectedExamType = newValue;
                            _subjects = [];
                            fetchSubjects(_selectedSemester!, newValue!);
                            validate(_selectedSemester!, newValue);
                          });
                        },
                      ),
                    ),
                  ),

                  // Add this variable

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Month/Year",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFFFF9800),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: FutureBuilder<String?>(
                              future: _selectedSemester != null &&
                                      _selectedExamType != null
                                  ? showmonth(
                                      _selectedSemester!, _selectedExamType!)
                                  : Future.value(null),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text(
                                    _monthYear ?? "",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  );
                                } else if (snapshot.hasError) {
                                  return Text(
                                    'Error: ${snapshot.error}',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  );
                                } else {
                                  if (snapshot.hasData &&
                                      snapshot.data != null) {
                                    _monthYear = snapshot.data;
                                  }
                                  return Text(
                                    _monthYear ?? '',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 12.0, bottom: 12, left: 10),
                    child: Text(
                      _responseMessage.isNotEmpty ? "$_responseMessage" : "",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),

                  _subjects == null || _subjects.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 38.0),
                            child: Text(
                              "",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _subjects.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                // Handle selection logic here
                                setState(() {
                                  // Toggle selection
                                  _subjects[index]['isChecked'] =
                                      !_subjects[index]['isChecked'];
                                  if (_subjects[index]['isChecked']) {
                                    _revalType(_subjects[index]['subId']);
                                  }
                                });
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Container(
                                  width: double.infinity,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        // Align text at the top of the row
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0, right: 8, top: 10),
                                              child: Text(
                                                "${_subjects[index]['name'] ?? 'N/A'}",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0, right: 18, top: 10),
                                            child: Text(
                                              "Grade: ${_subjects[index]['grade'] ?? 'N/A'}",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8.0),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Wrap(
                                          spacing: 8.0,
                                          children: _revalTypes.map((value) {
                                            return ChoiceChip(
                                              label: Text(
                                                value['revalType'],
                                                style: TextStyle(
                                                  color: value['revalType'] ==
                                                          _subjects[index][
                                                              'selectedRevalType']
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                              ),
                                              selected: value['revalType'] ==
                                                  _subjects[index]
                                                      ['selectedRevalType'],
                                              selectedColor: Colors.lightGreen,
                                              onSelected: (selected) {
                                                setState(() {
                                                  _subjects[index][
                                                          'selectedRevalType'] =
                                                      selected
                                                          ? value['revalType']
                                                          : null;
                                                });
                                              },
                                              showCheckmark:
                                                  true, // This line shows the checkmark inside the ChoiceChip
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                  if (_subjects.isNotEmpty)
                    ElevatedButton(
                      onPressed: () {
                        Fluttertoast.showToast(
                          msg: "Calculating Total Fee.....",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 2,
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                          fontSize: 16.0,
                        );
                        _showRevalDetails(context, _selectedSemester!,
                            _selectedExamType!, captcha.toString());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Show Revaluation Details',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Future<void> validate(String semester, String examType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String userName = prefs.getString('userName') ?? '';
    String email = prefs.getString('email') ?? '';
    String betStudMobile = prefs.getString('betStudMobile') ?? '';
    int schoolid = prefs.getInt('schoolId') ?? 00;
    int studId = prefs.getInt('studId') ?? 00;
    int fYearId = prefs.getInt('fYearId') ?? 00;
    int acYearId = prefs.getInt('acYearId') ?? 00;
    int studUserId = prefs.getInt('studUserId') ?? 00;
    String betCourseId = prefs.getString('betCourseId') ?? '';
    final requestBody = {
      "GrpCode": grpCodeValue,
      "ColCode": "pss",
      "CollegeId": "0001",
      "SchoolId": schoolid,
      "StudId": studId,
      "CourseId": betCourseId,
      "Sem": semester,
      "ExamType": examType,
      "MonthYear": _monthYear
    };

    final response = await http.post(
      Uri.parse(
          'https://mritsexams.com/CoreApi/Android/ValidateStudentReValuationFeeCollection'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      var button = data['status'];
      print("mm" + button.toString());
      // setState(() {
      //   _showButton = (button == 1); // Show button if status is 1
      // });
      setState(() {
        _responseMessage =
            data['studentReValuationFeeCollectionList'][0]['message'];
      });
    } else {
      throw Exception(
          'Failed to validate. Status code: ${response.statusCode}');
    }
  }

  Future<String?> showmonth(String semester, String examType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String userName = prefs.getString('userName') ?? '';
    String email = prefs.getString('email') ?? '';
    String betStudMobile = prefs.getString('betStudMobile') ?? '';
    int schoolid = prefs.getInt('schoolId') ?? 00;
    int studId = prefs.getInt('studId') ?? 00;
    int fYearId = prefs.getInt('fYearId') ?? 00;
    int acYearId = prefs.getInt('acYearId') ?? 00;
    int studUserId = prefs.getInt('studUserId') ?? 00;
    String betCourseId = prefs.getString('betCourseId') ?? '';
    final requestBody = {
      "GrpCode": grpCodeValue,
      "ColCode": "pss",
      "CollegeId": "0001",
      "SchoolId": schoolid,
      "StudId":studId,
      "Sem": semester,
      "ExamType": examType
    };

    final response = await http.post(
      Uri.parse('https://mritsexams.com/CoreApi/Android/ShowStudExamType'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['monthYear'];
    } else {
      throw Exception(
          'Failed to load exam types. Status code: ${response.statusCode}');
    }
  }

  Future<void> _revalType(String subId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String userName = prefs.getString('userName') ?? '';
    String email = prefs.getString('email') ?? '';
    String betStudMobile = prefs.getString('betStudMobile') ?? '';
    int schoolid = prefs.getInt('schoolId') ?? 00;
    int studId = prefs.getInt('studId') ?? 00;
    int fYearId = prefs.getInt('fYearId') ?? 00;
    int acYearId = prefs.getInt('acYearId') ?? 00;
    int studUserId = prefs.getInt('studUserId') ?? 00;
    String betCourseId = prefs.getString('betCourseId') ?? '';
    final reValTypeValue =
        _selectedRevalType.toString() == "Re-Evaluation" ? "0" : "1";
    final requestBody = {
      "GrpCode": grpCodeValue,
      "CollegeId": "0001",
      "ColCode": "PSS",
      "SchoolId": schoolid,
      "StudId":studId,
      "Sem": _selectedSemester!,
      "RecDate": DateFormat('yyyy-MM-dd').format(DateTime.now()),
      "MonthYear": _monthYear,
      "ExamType": _examTypes,
      "ReValuationShowFeeDetailsTableVariable": [
        {"SubId": subId, "ReValType": reValTypeValue ?? ""}
      ]
    };
    print("sss"+requestBody.toString());

    final response = await http.post(
      Uri.parse(
          'https://mritsexams.com/CoreApi/Android/ReValuationShowFeeDetails'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        // Handle the response as needed
      });
    } else {
      throw Exception(
          'Failed to get revaluation type. Status code: ${response.statusCode}');
    }
  }
}
