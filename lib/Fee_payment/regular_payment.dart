import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../views/MainPage.dart';

class RegularFeePayment extends StatefulWidget {
  const RegularFeePayment({Key? key}) : super(key: key);

  @override
  State<RegularFeePayment> createState() => _RegularFeePaymentState();
}

class _RegularFeePaymentState extends State<RegularFeePayment> {
  late Future<List<FeeDetails>> feeDetailsFuture;
  late Future<String> studentValidationResultFuture;
  late Future<StudFeeFillDetails>? studFeeFillDetailsFuture;
  late String result = '';
  bool _showButton = false;
  bool _dontshow = false;
  String? _payDate;
  String? _payedAmount;

  @override
  void initState() {
    super.initState();
    feeDetailsFuture = fetchFeeDetails();
    studentValidationResultFuture = fetchStudentValidationResult();
    studFeeFillDetailsFuture = fetchStudFeeFillDetails();
  }

  Future<List<FeeDetails>> fetchFeeDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    String userName = prefs.getString('userName') ?? '';
    int schoolid = prefs.getInt('schoolId') ?? 00;
    int studId = prefs.getInt('studId') ?? 00;
    final response = await http.post(
      Uri.parse('https://mritsexams.com/CoreApi/Android/FeeDetials'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "GrpCode": grpCodeValue,
        "ColCode": "pss",
        "CollegeId": "0001",
        "SchoolId": schoolid,
        "HtNo": userName,
        "Sem": "",
        "Flag": "0"
      }),
    );


    if (response.statusCode == 200) {
      final List<dynamic> feeDetailsList =
          jsonDecode(response.body)['feeDetialsList'];
      return feeDetailsList.map((json) => FeeDetails.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load fee details');
    }
  }

  Future<String> fetchStudentValidationResult() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    String userName = prefs.getString('userName') ?? '';
    int schoolid = prefs.getInt('schoolId') ?? 00;
    int studId = prefs.getInt('studId') ?? 00;
    final response = await http.post(
      Uri.parse('https://mritsexams.com/CoreApi/Android/StudentValidation'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "GrpCode": grpCodeValue,
        "ColCode": "pss",
        "CollegeId": "0001",
        "SchoolId": schoolid,
        "HtNo": userName,
        "Sem": "",
        "Flag": "0"
      }),
    );

    if (response.statusCode == 200) {
      print("fff" + response.body);
      var payDate =
          jsonDecode(response.body)['singlStudentValidationist']['paymentDt'];
      var payedAmount = jsonDecode(response.body)['singlStudentValidationist']
          ['paymentAmount'];
      var button =
          jsonDecode(response.body)['singlStudentValidationist']['status'];
      print(button);
      setState(() {
        _dontshow = (button == 1);
        _payDate = payDate;
        _payedAmount = payedAmount;

        _showButton = (button == 0); // Show button if status is 0
      });
      return jsonDecode(response.body)['singlStudentValidationist']['result'];
    } else {
      throw Exception('Failed to load student validation result');
    }
  }

  Future<StudFeeFillDetails> fetchStudFeeFillDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    String userName = prefs.getString('userName') ?? '';
    int schoolid = prefs.getInt('schoolId') ?? 00;
    int studId = prefs.getInt('studId') ?? 00;
    final response = await http.post(
      Uri.parse('https://mritsexams.com/CoreApi/Android/StudFeeFillDetails'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "GrpCode": grpCodeValue,
        "ColCode": "pss",
        "CollegeId": "0001",
        "SchoolId": schoolid,
        "HtNo": userName,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final singleStudFeeFillDetailsList =
          responseData['singleStudFeeFillDetailsList'];
      print(responseData['singleStudFeeFillDetailsList']);

      return StudFeeFillDetails.fromJson(singleStudFeeFillDetailsList);
    } else {
      throw Exception('Failed to load student fee fill details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
          'Regular Fee Payments',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: FutureBuilder<List<FeeDetails>>(
        future: feeDetailsFuture,
        builder: (context, feeSnapshot) {
          if (feeSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (feeSnapshot.hasError) {
            return Center(
              child: Text('Error: ${feeSnapshot.error}'),
            );
          } else if (feeSnapshot.hasData) {
            final List<FeeDetails> feeDetails = feeSnapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          if (_showButton)
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)),
                              child: DataTable(
                                columns: [
                                  DataColumn(
                                      label: Text('Fine Date',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16))),
                                  DataColumn(
                                      label: Text('Semester',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16))),
                                  DataColumn(
                                      label: Text('Fines',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16))),
                                ],
                                rows: feeDetails.map((feeDetail) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(feeDetail.fineDate ?? '')),
                                      DataCell(Text(feeDetail.sem ?? '')),
                                      DataCell(Text(feeDetail.fines ?? '')),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  FutureBuilder<String>(
                    future: studentValidationResultFuture,
                    builder: (context, studentSnapshot) {
                      if (studentSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (studentSnapshot.hasError) {
                        return Text('Error: ${studentSnapshot.error}');
                      } else if (studentSnapshot.hasData) {
                        final result = studentSnapshot.data!;
                        bool showPayDate = _payDate != null;
                        bool showPayedAmount = _payedAmount != null;

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        result,
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Visibility(
                                    visible: _payDate != null &&
                                            _payDate!.isNotEmpty ||
                                        _payedAmount != null &&
                                            _payedAmount!.isNotEmpty,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      width: double.infinity,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            if (showPayDate &&
                                                _payDate != null &&
                                                _payDate!.isNotEmpty)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: RichText(
                                                  text: TextSpan(
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                    children: [
                                                      TextSpan(
                                                        text:
                                                            'Payment Date       ',
                                                        style: TextStyle(
                                                          color: Colors.orange,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: '\n$_payDate',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            if (showPayDate &&
                                                _payedAmount != null &&
                                                _payedAmount!.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 15),
                                                child: RichText(
                                                  text: TextSpan(
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                    children: [
                                                      TextSpan(
                                                        text: 'Paid Amount ',
                                                        style: TextStyle(
                                                          color: Colors.orange,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: '\n$_payedAmount',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return Text('No data available');
                      }
                    },
                  ),
                  if (_showButton)
                    FutureBuilder<StudFeeFillDetails>(
                      future: studFeeFillDetailsFuture,
                      builder: (context, studFeeSnapshot) {
                        if (studFeeSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (studFeeSnapshot.hasError) {
                          return Text('Error: ${studFeeSnapshot.error}');
                        } else if (studFeeSnapshot.hasData) {
                          final studFeeDetails = studFeeSnapshot.data!;
                          int totalFee = (studFeeDetails.studFee ?? 0) +
                              (studFeeDetails.studFine ?? 0);
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Material(
                              borderRadius: BorderRadius.circular(10),
                              // elevation: 4, // Remove elevation
                              // Add border color and width
                              borderOnForeground: true,
                              color: Colors.transparent,
                              // Make material transparent
                              child: Column(
                                children: [
                                  if (_showButton)
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Exam Month',
                                                style: TextStyle(
                                                  color: Color(0xFFFF9800),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '${studFeeDetails.regExamMonth}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Student Fee',
                                                style: TextStyle(
                                                  color: Color(0xFFFF9800),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '${studFeeDetails.studFee ?? ''}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Student Fine',
                                                style: TextStyle(
                                                  color: Color(0xFFFF9800),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '${studFeeDetails.studFine ?? ''}',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Divider(
                                              color: Colors.grey,
                                              thickness: 1,
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Total',
                                                style: TextStyle(
                                                  color: Color(0xFFFF9800),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '$totalFee',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              if (_showButton)
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Fluttertoast.showToast(
                                                      msg:
                                                          "Page redirecting to Paytm Payments Page...",
                                                      toastLength:
                                                          Toast.LENGTH_SHORT,
                                                      gravity:
                                                          ToastGravity.BOTTOM,
                                                      timeInSecForIosWeb: 1,
                                                      backgroundColor:
                                                          Colors.white,
                                                      textColor: Colors.black,
                                                      fontSize: 16.0,
                                                    );
                                                    proceedToPayment(
                                                        studFeeDetails); // Pass studFeeDetails to proceedToPayment
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.lightGreen,
                                                  ),
                                                  child: Text(
                                                    "Proceed to Payment",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          // Add this widget to display transaction result
                                          SizedBox(height: 16),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return SizedBox
                              .shrink(); // Return null if there is no data
                        }
                      },
                    ),
                ],
              ),
            );
          } else {
            return const Center(
              child: Text('No data available'),
            );
          }
        },
      ),
    );
  }

  String generateRandomText(int length) {
    const _chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final _random = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => _chars.codeUnitAt(_random.nextInt(_chars.length))));
  }

  Future<void> _startTransaction(
      Map<String, dynamic> transactionData,
      int newTxnId,
      String AtomTransId,
      StudFeeFillDetails studFeeDetails,
      String captcha) async {
    try {
      var txnToken = transactionData['paytmResponse']['body']['txnToken'];

      var response = AllInOneSdk.startTransaction(
        transactionData['MID'],
        transactionData['ORDER_ID'],
        transactionData['TXN_AMOUNT'],
        txnToken,
        transactionData['CALLBACK_URL'],
        false,
        // isStaging
        false, // restrictAppInvoke
      );

      response.then((value) {
        print("Response from SDK: $value");
        setState(() {
          result = value.toString(); // Include gateway name in result
        });

        // Extract gateway name from value
        String gatewayName = value?['GATEWAYNAME'].toString() ?? '';
        String statues = value?['STATUS'].toString() ?? '';
        String banktxnid = value?['BANKTXNID'].toString() ?? '';
        String txnamount = value?['TXNAMOUNT'].toString() ?? '';
        String txndate = value?['TXNDATE'].toString() ?? '';
        String mid = value?['MID'].toString() ?? '';
        String orderid = value?['ORDERID'].toString() ?? '';
        String TXNID = value?['TXNID'].toString() ?? '';
        print("Gateway Name: $gatewayName");
        print("$statues");

        print("$banktxnid");
        print("$txndate");
        print("$txnamount");
        print("$mid");
        print("$orderid");
        print("$TXNID");

        // Call additional API after transaction is completed
        _callAdditionalApi(
            transactionData,
            newTxnId,
            AtomTransId,
            gatewayName,
            txnamount,
            txndate,
            banktxnid,
            TXNID,
            orderid,
            statues,
            studFeeDetails,
            captcha);

        // Show a toast indicating successful transaction
        Fluttertoast.showToast(
          msg: "Transaction Successful",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }).catchError((onError) {
        if (onError is PlatformException) {
          setState(() {
            result = onError.message! + " \n  " + onError.details.toString();
          });
        } else {
          setState(() {
            result = onError.toString();
          });
        }
        print("Error in SDK Response: $onError");
      });
    } catch (error) {
      print('Error: $error');
      setState(() {
        result = error.toString();
      });
    }
  }

  Future<void> proceedToPayment(StudFeeFillDetails studFeeDetails) async {
    var captcha = generateRandomText(6).toString();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    String userName = prefs.getString('userName') ?? '';
    int schoolid = prefs.getInt('schoolId') ?? 00;
    int studId = prefs.getInt('studId') ?? 00;
    int fYearId = prefs.getInt('fYearId') ?? 00;
    try {
      final response = await http.post(
        Uri.parse(
            'https://mritsexams.com/CoreApi/Flutter/SaveRegularFeeTempData'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "GrpCode": grpCodeValue,
          "ColCode": "pss",
          "CollegeId": "0001",
          "SchoolId": schoolid,
          "StudId": studId,
          "PaymentDt": DateFormat('yyyy-MM-dd').format(DateTime.now()),
          "CaptchaImg": captcha,
          "AcYearId": '${studFeeDetails.acYearId ?? ''}',
          "FeeStructId": '${studFeeDetails.feeStructId ?? ''}',
          "Fee": '${studFeeDetails.studFee ?? ''}',
          "Fine": '${studFeeDetails.studFine ?? ''}',
          "Sem": '${studFeeDetails.sem ?? ''}',
          "FYearId": fYearId,
          "ExamMonth": '${studFeeDetails.regExamMonth ?? ''}',
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('singleSaveRegularFeeTempDataList')) {
          final Map<String, dynamic> singleSaveRegularFeeTempDataList =
              responseData['singleSaveRegularFeeTempDataList'];
          final newTxnId = singleSaveRegularFeeTempDataList['newTxnId'];
          final AtomTransId =
              singleSaveRegularFeeTempDataList['AtomTransId'].toString();
          final examMonth = singleSaveRegularFeeTempDataList['regExamMonth'];
          final sem = singleSaveRegularFeeTempDataList['Sem'];
          _startTransaction(singleSaveRegularFeeTempDataList, newTxnId,
              AtomTransId, studFeeDetails, captcha);
        } else {
          throw Exception('Error: Response does not contain required data');
        }
      } else {
        throw Exception(
            'Error: Failed to proceed with payment, Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      // Handle any errors that occur during the process
      setState(() {});
    }
  }

  Future<void> _callAdditionalApi(
      Map<String, dynamic> transactionData,
      int newTxnId,
      String AtomTransId,
      String gatewayName,
      String txnamount,
      txndate,
      banktxnid,
      TXNID,
      orderid,
      statues,
      studFeeDetails,
      String captcha) async {
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
      String collegeId = prefs.getString('collegeId') ?? '';
      final response = await http.post(
        Uri.parse(
            'https://mritsexams.com/CoreApi/Android/SaveRegularFeeMainData'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "CollegeId": collegeId,
          "GrpCode": grpCodeValue,
          "ColCode": colCode,
          "SchoolId": schoolid,
          "StudId": studId,
          "NewTxnId": newTxnId,
          "CaptchaImg": captcha,
          "AcYearId": acYearId,
          "FeeStructureId": '${transactionData['FeeStructId'] ?? ''}',
          "PaymentDt": DateFormat('yyyy-MM-dd').format(DateTime.now()),
          "Fee": '${studFeeDetails.studFee ?? ''}',
          "Fine": '${studFeeDetails.studFine ?? ''}',
          "Sem": '${transactionData['Sem'] ?? ''}',
          "FyearId": fYearId,
          "ExamMonth": '${transactionData['regExamMonth'] ?? ''}',
          "AtomTransId": AtomTransId.toString(),
          "MerchantTransId": transactionData['MID'],
          "TXNAMOUNT": txnamount, // Use txnamount here
          "TransSurChargeAmt": 0,
          "TransDate": DateFormat('yyyy-MM-dd').format(DateTime.now()),
          "BankTransId": "",
          "TransStatus": statues,
          "BankName": banktxnid,
          "PaymentDoneThrough": gatewayName,
          "CardNumber": "",
          "CardHolderName": "",
          "Email": email,
          "MobileNo": betStudMobile,
          "Address": "HYDERABAD",
          "TransDescription": statues,
          "Success": 0,
        }),
      );

      print({
        "CollegeId": collegeId,
        "GrpCode": grpCodeValue,
        "ColCode": colCode,
        "SchoolId": schoolid,
        "StudId": studId,
        "NewTxnId": newTxnId,
        "CaptchaImg": captcha,
        "AcYearId": acYearId,
        "FeeStructureId": '${transactionData['FeeStructId'] ?? ''}',
        "PaymentDt": DateFormat('yyyy-MM-dd').format(DateTime.now()),
        "Fee": '${studFeeDetails.studFee ?? ''}',
        "Fine": '${studFeeDetails.studFine ?? ''}',
        "Sem": '${transactionData['Sem'] ?? ''}',
        "FyearId": fYearId,
        "ExamMonth": '${transactionData['regExamMonth'] ?? ''}',
        "AtomTransId": AtomTransId.toString(),
        "MerchantTransId": transactionData['MID'],
        "TXNAMOUNT": txnamount, // Use txnamount here
        "TransSurChargeAmt": 0,
        "TransDate": DateFormat('yyyy-MM-dd').format(DateTime.now()),
        "BankTransId": "",
        "TransStatus": statues,
        "BankName": banktxnid,
        "PaymentDoneThrough": gatewayName,
        "CardNumber": "",
        "CardHolderName": "",
        "Email": email,
        "MobileNo": betStudMobile,
        "Address": "HYDERABAD",
        "TransDescription": statues,
        "Success": 0,
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("ssssss" + response.body);
        int receiptId =
            responseData['singleSaveRegularFeeMainDataList']['recieptId'];
        print('Receipt ID: $receiptId');
        // Make another API call to FeeReceiptsReports

        await _fetchFeeReceiptsReport(receiptId, context);

        setState(() {
          result = responseData.toString();
        });
      } else {
        throw Exception('Error: Failed to call additional API');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        result = 'Error occurred: $e';
      });
    }
  }

  Future<void> _fetchFeeReceiptsReport(
      int receiptId, BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String grpCodeValue = prefs.getString('grpCode') ?? '';
      int schoolid = prefs.getInt('schoolId') ?? 0;

      final response = await http.post(
        Uri.parse('https://mritsexams.com/CoreApi/Android/FeeReceiptsReports'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "GrpCode": grpCodeValue,
          "CollegeId": "0001",
          "ColCode": "PSS",
          "SchoolId": schoolid,
          "RecId": receiptId,
          "Type": "Regular",
          "Words": "",
          "Flag": 0,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Profile()));
        print('Response body: ${response.body}');

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
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _launchPDF(BuildContext context, String path) async {
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
  }
}

class FeeDetails {
  final String? sem;
  final String? entryNo;
  final String? fineDate;
  final String? fines;

  FeeDetails({
    required this.sem,
    required this.entryNo,
    required this.fineDate,
    required this.fines,
  });

  factory FeeDetails.fromJson(Map<String, dynamic> json) {
    return FeeDetails(
      sem: json['sem'] as String?,
      entryNo: json['entryNo'] as String?,
      fineDate: json['fineDate'] as String?,
      fines: json['fines'] as String?,
    );
  }
}

class StudFeeFillDetails {
  final String? colCode;
  final String? collegeId;
  final int? schoolId;
  final String? htNo;
  final String? sem;
  final int? status;
  final String? result;
  final String? examMonth;
  final String? regDt;
  final String? paymentAmount;
  final String? paymentDt;
  final int? studFee;
  final int? studFine;
  final String? regExamMonth;
  final String? acYearId;
  final int? feeStructId;

  StudFeeFillDetails({
    this.colCode,
    this.collegeId,
    this.schoolId,
    this.htNo,
    this.sem,
    this.status,
    this.result,
    this.examMonth,
    this.regDt,
    this.paymentAmount,
    this.paymentDt,
    this.studFee,
    this.studFine,
    this.regExamMonth,
    this.acYearId,
    this.feeStructId,
  });

  factory StudFeeFillDetails.fromJson(Map<String, dynamic> json) {
    return StudFeeFillDetails(
      colCode: json['colCode'] as String?,
      collegeId: json['collegeId'] as String?,
      schoolId: json['schoolId'] as int?,
      htNo: json['htNo'] as String?,
      sem: json['sem'] as String?,
      status: json['status'] as int?,
      result: json['result'] as String?,
      examMonth: json['examMonth']?.toString(),
      regDt: json['regDt'] as String?,
      paymentAmount: json['paymentAmount'] as String?,
      paymentDt: json['paymentDt'] as String?,
      studFee: json['studFee'] as int?,
      studFine: json['studFine'] as int?,
      regExamMonth: json['regExamMonth']?.toString(),
      acYearId: json['acYearId']?.toString(),
      feeStructId: json['feeStructId'] as int?,
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: RegularFeePayment(),
  ));
}
