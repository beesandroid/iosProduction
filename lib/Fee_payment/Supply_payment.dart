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

class SupplyFeePayment extends StatefulWidget {
  const SupplyFeePayment({Key? key}) : super(key: key);

  @override
  State<SupplyFeePayment> createState() => _SupplyFeePaymentState();
}

class _SupplyFeePaymentState extends State<SupplyFeePayment> {
  late Future<FeeDetailsResponse> feeDetailsFuture;
  late Future<String> paymentStatusFuture;
  late Future<List<String>> semestersFuture;
  late Future<Map<String, dynamic>> supplyFeeFuture;

  List<Subject> subjects = [];
  String paymentStatus = '';
  String? selectedSemester;
  bool _showButton = false;
  String? suppExamMonth;

  @override
  void initState() {
    super.initState();
    feeDetailsFuture = fetchFeeDetails();
    paymentStatusFuture = fetchPaymentStatus();
    semestersFuture = fetchSemesters();
    supplyFeeFuture = fetchSupplyFee();
    _showButton = false;

    paymentStatusFuture.then((status) {
      setState(() {
        paymentStatus = status;
      });
    });
  }

  String generateRandomText(int length) {
    const _chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final _random = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => _chars.codeUnitAt(_random.nextInt(_chars.length))));
  }

  Future<void> saveSupplyFeeTempData(
      Map<String, dynamic> supplyFeeDetails) async {
    try {
      var captcha = generateRandomText(6).toString();
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

      final response = await http.post(
        Uri.parse(
            'https://mritsexams.com/CoreApi/Flutter/SaveSupplyFeeTempData'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "GrpCode": grpCodeValue,
          "CollegeId": "0001",
          "ColCode": "pss",
          "SchoolId": schoolid,
          "UserId": betStudUserId,
          "StudId": studId,
          "PaymentDate": DateFormat('yyyy-MM-dd').format(DateTime.now()),
          "CaptchaImg": captcha.toString(),
          // "CaptchaImg": "112233",
          "AcYearId": acYearId,
          "SubIds": getSelectedSubIds().join(','),
          "FeeStructId": '${supplyFeeDetails['feeStructId'] ?? ''}',
          "Fee": supplyFeeDetails['fee'] ?? '0.00',
          "Fine": supplyFeeDetails['fine'] ?? '0',
          "Sem": '${supplyFeeDetails['semester'] ?? ''}',
          "FYearId": fYearId,
          "ExamMonth": suppExamMonth,
          "AdmnNo": userName,
          "CourseId": betCourseId
        }),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        final List<dynamic> transactionDataList =
        responseData['saveSupplyFeeTempDataList'];
        print(responseData);

        for (var transactionData in transactionDataList) {
          final studFee = transactionData['StudFee'];
          final studFine = transactionData['StudFine'];
          final atomTransId = transactionData['AtomTransId'];
          final sem = transactionData['sem'];
          final newTxnId = transactionData['newTxnId'];
          final AtomTransId = transactionData['AtomTransId'].toString();
          final examMonth = transactionData['regExamMonth'];

          initiatePaytmTransaction(transactionData, newTxnId, AtomTransId,
              supplyFeeDetails, suppExamMonth, captcha.toString());
        }
        if (transactionDataList != null && transactionDataList.isNotEmpty) {
          print('Error: transactionData is null');
        } else {
          print('No transaction data found in response');
        }
      } else {
        print('Failed to save data: ${response.body}');
      }
    } catch (error) {
      print('Error saving supply fee data: $error');
    }
  }

  Future<void> initiatePaytmTransaction(
      Map<String, dynamic> transactionData,
      int newTxnId,
      String AtomTransId,
      supplyFeeDetails,
      suppExamMonth,
      String captcha) async {
    try {
      if (transactionData == null) {
        throw Exception('Transaction data is null');
      }

      var token = transactionData['supplyPaytmResponse']['body']['txnToken'];

      // Start the Paytm transaction using the retrieved data
      var response = AllInOneSdk.startTransaction(
        transactionData['MID'],
        transactionData['ORDER_ID'],
        transactionData['TXN_AMOUNT'],
        token,
        transactionData['CALLBACK_URL'],
        false,
        // isStaging
        false, // isAppInvoke
      );

      // Handle the response accordingly
      response.then((value) {
        print(value);
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
            supplyFeeDetails,
            suppExamMonth,
            captcha.toString());
        // Add your logic here to handle the transaction response
      }).catchError((onError) {
        print('Error starting transaction: $onError');
        // Handle transaction error
      });
    } catch (error) {
      print('Error initiating Paytm transaction: $error');
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
      supplyFeeDetails,
      suppExamMonth,
      captcha) async {
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

      final response = await http.post(
        Uri.parse(
            'https://mritsexams.com/CoreApi/Android/SupplyFeeMainData'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "CollegeId":"0001",
          "GrpCode": grpCodeValue,
          "ColCode": colCode,
          "SchoolId": schoolid,
          "StudId":studId,
          "NewTxnId": newTxnId,
          "CaptchaImg": captcha.toString(),
          "AcYearId": acYearId,
          "FeeStructureId": '${transactionData['FeeStructId'] ?? ''}',
          "PaymentDt": DateFormat('yyyy-MM-dd').format(DateTime.now()),
          "Fee": '${supplyFeeDetails['fee'] ?? ''}',
          "Fine": '${supplyFeeDetails['fine'] ?? ''}',
          "Sem": '${transactionData['Sem'] ?? ''}',
          "FyearId": fYearId,
          "ExamMonth": suppExamMonth,
          "AtomTransId": AtomTransId.toString(),
          "MerchantTransId": transactionData['MID'],
          "TXNAMOUNT": txnamount,
          "TransSurChargeAmt": 0,
          "TransDate": DateFormat('yyyy-MM-dd').format(DateTime.now()),
          "BankTransId": "",
          "TransStatus": statues,
          "BankName": banktxnid,
          "PaymentDoneThrough": gatewayName,
          "CardNumber": "",
          "CardHolderName": "",
          "Email":email,
          "MobileNo": betStudMobile,
          "Address": "HYDERABAD",
          "TransDescription": statues,
          "Success": 0,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("Response Data: $responseData");

        if (responseData.containsKey('supplyFeeMainDataList') &&
            responseData['supplyFeeMainDataList'] is List &&
            responseData['supplyFeeMainDataList'].isNotEmpty) {
          final supplyFeeMainData = responseData['supplyFeeMainDataList'][0];

          if (supplyFeeMainData.containsKey('recieptid')) {
            // Check if 'recieptid' or 'receiptid' is correct in your response
            int receiptId = supplyFeeMainData[
            'recieptid']; // Adjust 'recieptid' to 'receiptid' if necessary
            print('Receipt ID: $receiptId');
            await _fetchFeeReceiptsReport(receiptId, context);
          } else {
            print('recieptid key not found in supplyFeeMainData');
            throw Exception('recieptid key not found in supplyFeeMainData');
          }
        } else {
          print('supplyFeeMainDataList is empty or not a List');
          throw Exception('supplyFeeMainDataList is empty or not a List');
        }
      } else {
        throw Exception(
            'Error: Failed to call additional API, Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in _callAdditionalApi: $e');
      setState(() {}); // Make sure to handle state update as needed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error calling API: $e'),
        ),
      );
    }
  }

  Future<void> _fetchFeeReceiptsReport(
      int receiptId, BuildContext context) async {try {
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
          "Type": "Supplementary",
          "Words": "",
          "Flag": 0,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>Profile()));
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


  Future<FeeDetailsResponse> fetchFeeDetails() async {
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
        "Flag": "1"
      }),
    );

    if (response.statusCode == 200) {
      return FeeDetailsResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load fee details');
    }
  }

  Future<String> fetchPaymentStatus() async {
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
    final response = await http.post(
      Uri.parse(
          'https://mritsexams.com/CoreApi/Android/SupplyFeeCollectionValidation'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "GrpCode": grpCodeValue,
        "ColCode": "pss",
        "CollegeId": "0001",
        "SchoolId": schoolid,
        "CourseId": betCourseId,
        "StudId": studId,
        "Sem": "",
        "AcYearId": acYearId
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      var button = responseData['status'];
      print("mm" + button.toString());
      setState(() {
        _showButton = (button == 0);
        // Show button if status is 0
      });
      return responseData['message'];
    } else {
      throw Exception('Failed to load payment status');
    }
  }

  Future<List<String>> fetchSemesters() async {
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
    final response = await http.post(
      Uri.parse(
          'https://mritsexams.com/CoreApi/Android/StudentDueSubjectSemesters'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "GrpCode": grpCodeValue,
        "ColCode": "pss",
        "CollegeId": "0001",
        "SchoolId": schoolid,
        "CourseId": betCourseId,
        "StudId": studId,
        "Sem": "",
        "AcYearId":acYearId
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final List<dynamic>? semestersData =
      responseData['semWiseEndDatesListList'];
      if (semestersData != null) {
        final List<String> semesters =
        semestersData.map((data) => data['sem'] as String).toList();
        return semesters;
      } else {
        throw Exception('Semesters data is null');
      }
    } else {
      throw Exception(
          'Failed to load semesters. Status code: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchSupplyFee() async {
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
    final List<int> selectedSubIds = getSelectedSubIds(); // Get selected subIds
    final String subIdsString =
    selectedSubIds.join(','); // Join selected subIds with comma

    final response = await http.post(
      Uri.parse(
          'https://mritsexams.com/CoreApi/Flutter/StudentSupplyFeeDisplay'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "GrpCode": grpCodeValue,
        "ColCode": "pss",
        "CollegeId": "0001",
        "SchoolId": schoolid,
        "SubIds": subIdsString, // Use the comma-separated string
        "CourseId": betCourseId,
        "StudId": studId,
        "Sem": "",
        "AcYearId": acYearId
      }),
    );

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData.containsKey('studentSupplyFeeDisplayDetails')) {
        final List<dynamic> displayDetails =
        responseData['studentSupplyFeeDisplayDetails'];
        if (displayDetails.isNotEmpty) {
          return displayDetails[0];
        } else {
          throw Exception('No supply fee display details found');
        }
      } else {
        throw Exception(
            'Key "studentSupplyFeeDisplayDetails" not found in response');
      }
    } else {
      throw Exception(
          'Failed to load supply fee. Status code: ${response.statusCode}');
    }
  }

  Future<void> fetchSubjects(String selectedSemester) async {
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
    final response = await http.post(
      Uri.parse(
          'https://mritsexams.com/CoreApi/Android/getStudentDueSubjectSemWise'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "GrpCode": grpCodeValue,
        "ColCode": "pss",
        "CollegeId": "0001",
        "SchoolId": schoolid,
        "CourseId": betCourseId,
        "StudId": studId,
        "Sem": selectedSemester,
        "AcYearId": acYearId
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final List<dynamic>? subjectsData = responseData['dueSubjectsList'];

      if (subjectsData != null) {
        setState(() {
          suppExamMonth = subjectsData[0]['suppExamMonth'];
          subjects =
              subjectsData.map((data) => Subject.fromJson(data)).toList();
          var month = subjectsData[0]['suppExamMonth'];
          ;
        });

        // Print suppExamMonth from the first item in subjectsData (assuming there's at least one item)
        if (subjectsData.isNotEmpty) {
          print('suppExamMonth: ${subjectsData[0]['suppExamMonth']}');
        }
      } else {
        throw Exception('Subjects data is null');
      }
    } else {
      throw Exception('Failed to load subjects');
    }
  }

  List<int> getSelectedSubIds() {
    return subjects
        .where((subject) => subject.selected)
        .map((subject) => subject.subId)
        .toList();
  }

  void showNoSubjectsSelectedDialog() {
    showDialog(
      context: context,
      builder: (BuildContextcontext) {
        return AlertDialog(
          title: Text('No Subjects Selected'),
          content: Text('Please select at least one subject to proceed.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.lightGreen,
        title: Text(
          'Supply Fee Payment',
          style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<FeeDetailsResponse>(
        future: feeDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height),
                child: Column(
                  children: [
                    // if(_showButton)
                    Column(
                      children: [
                        // DataTable section
                        if (snapshot.hasData &&
                            snapshot.data!.feeDetails.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                              ),
                              child: DataTable(
                                columns: const <DataColumn>[
                                  DataColumn(
                                    label: Text(
                                      'Fine',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Amount',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Date',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ),
                                ],
                                rows:
                                snapshot.data!.feeDetails.map((feeDetail) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                          Text(feeDetail.fineDate ?? 'N/A')),
                                      DataCell(Text(feeDetail.fines ?? 'N/A')),
                                      DataCell(Text(feeDetail.sem)),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),

                        // Message when no data available
                        if (snapshot.hasData &&
                            snapshot.data!.feeDetails.isEmpty)
                          SizedBox.shrink()
                      ],
                    ),
                    Text(
                      suppExamMonth ?? '',
                      style: TextStyle(color: Colors.white, fontSize: 1),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 18.0, top: 15),
                      child: Text(
                        ' $paymentStatus',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: FutureBuilder<List<String>>(
                        future: semestersFuture,
                        builder: (context, semestersSnapshot) {
                          if (semestersSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (semestersSnapshot.hasError) {
                            return Text('Error: ${semestersSnapshot.error}');
                          } else if (semestersSnapshot.hasData &&
                              semestersSnapshot.data!.isNotEmpty) {
                            return Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding:
                                    EdgeInsets.symmetric(horizontal: 10.0),
                                    child: Row(
                                      children: [
                                        SizedBox(width: 10.0),
                                        Expanded(
                                          child:
                                          DropdownButtonFormField<String>(
                                            decoration: InputDecoration(
                                              labelText: "Select Sem",
                                              border: OutlineInputBorder(),
                                              contentPadding:
                                              EdgeInsets.symmetric(
                                                  horizontal: 10),
                                            ),
                                            isExpanded: true,
                                            value: selectedSemester ??
                                                semestersSnapshot.data!.first,
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                Fluttertoast.showToast(
                                                  msg: "Fetching Subjects List...",
                                                  toastLength: Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.BOTTOM,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor: Colors.white,
                                                  textColor: Colors.black,
                                                  fontSize: 16.0,
                                                );
                                                selectedSemester = newValue;
                                                if (newValue != null) {
                                                  fetchSubjects(newValue);
                                                }
                                              });
                                            },
                                            items: semestersSnapshot.data!
                                                .map((String semester) {
                                              return DropdownMenuItem<String>(
                                                value: semester,
                                                child: Text(semester),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                        SizedBox(width: 10.0),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Padding(
                              padding:
                              const EdgeInsets.only(top: 58.0, bottom: 58),
                              child: Text(
                                '',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: subjects.length,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          margin: EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 10.0),
                          child: ListTile(
                            title: Text(
                              subjects[index].name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              subjects[index].sem,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.yellow[800],
                              ),
                            ),
                            trailing: Checkbox(
                              value: subjects[index].selected,
                              onChanged: (bool? value) {
                                setState(() {
                                  subjects[index].selected = value ?? false;
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),

                    Container(
                      child: Column(
                        children: [
                          // Display the ElevatedButton only if DataTable is visible
                          if (snapshot.hasData &&
                              snapshot.data!.feeDetails.isNotEmpty &&
                              subjects.isNotEmpty)
                            ElevatedButton(
                              onPressed: () {
                                Fluttertoast.showToast(
                                  msg: "Calculating Total Fee...",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.white,
                                  textColor: Colors.black,
                                  fontSize: 16.0,
                                );
                                if (getSelectedSubIds().isEmpty) {
                                  showNoSubjectsSelectedDialog();
                                } else {
                                  fetchSupplyFee().then((response) {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return FractionallySizedBox(
                                          heightFactor: 0.85,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ListView(
                                              children: [
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                      top: 15.0, left: 15),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .center,
                                                    children: [
                                                      Text(
                                                        "Supply Fee Details",
                                                        style: TextStyle(
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color:
                                                            Colors.black),
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(10)),
                                                    child: Column(
                                                      children: [
                                                        ListTile(
                                                          title: Row(
                                                            children: [
                                                              Text(
                                                                'Fee : ',
                                                                style:
                                                                TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                ),
                                                              ),
                                                              Text(
                                                                '${response["fee"]}',
                                                                style:
                                                                TextStyle(
                                                                  color: Colors
                                                                      .yellow[
                                                                  800],
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        ListTile(
                                                          title: Row(
                                                            children: [
                                                              Text(
                                                                'Fine : ',
                                                                style:
                                                                TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                ),
                                                              ),
                                                              Text(
                                                                '${response["fine"]}',
                                                                style:
                                                                TextStyle(
                                                                  color: Colors
                                                                      .yellow[
                                                                  800],
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        ListTile(
                                                          title: Row(
                                                            children: [
                                                              Text(
                                                                'No. of Subjects : ',
                                                                style:
                                                                TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                ),
                                                              ),
                                                              Text(
                                                                '${response["noOfSubjects"]}',
                                                                style:
                                                                TextStyle(
                                                                  color: Colors
                                                                      .yellow[
                                                                  800],
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        ListTile(
                                                          title: Row(
                                                            children: [
                                                              Text(
                                                                'Semester : ',
                                                                style:
                                                                TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                ),
                                                              ),
                                                              Text(
                                                                '${response["semester"]}',
                                                                style:
                                                                TextStyle(
                                                                  color: Colors
                                                                      .yellow[
                                                                  800],
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                    top: 25.0,
                                                    left: 55,
                                                    right: 55,
                                                    bottom: 10,
                                                  ),
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      Fluttertoast.showToast(
                                                        msg:
                                                        "Page is redirecting to Paytm Payments Page...",
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
                                                      saveSupplyFeeTempData(
                                                          response);
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                      Colors.lightGreen,
                                                    ),
                                                    child: Text(
                                                      'Proceed to Payment',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }).catchError((error) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Error'),
                                          content: Text(error.toString()),
                                        );
                                      },
                                    );
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightGreen,
                              ),
                              child: Text(
                                "Continue to Payment",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}

class FeeDetailsResponse {
  final List<FeeDetail> feeDetails;

  FeeDetailsResponse({required this.feeDetails});

  factory FeeDetailsResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> feeDetailsData = json['feeDetialsList'] ?? [];
    final List<FeeDetail> feeDetails =
    feeDetailsData.map((data) => FeeDetail.fromJson(data)).toList();
    return FeeDetailsResponse(feeDetails: feeDetails);
  }
}

class FeeDetail {
  final String sem;
  final String? fineDate;
  final String? fines;

  FeeDetail({required this.sem, this.fineDate, this.fines});

  factory FeeDetail.fromJson(Map<String, dynamic> json) {
    return FeeDetail(
      sem: json['sem'] as String,
      fineDate: json['fineDate'] as String?,
      fines: json['fines'] as String?,
    );
  }
}

class Subject {
  final int subId;
  final String sem;
  final String name;
  bool selected;

  Subject({
    required this.subId,
    required this.sem,
    required this.name,
    this.selected = false,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      subId: json['subId'] as int,
      sem: json['sem'] as String,
      name: json['name'] as String,
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SupplyFeePayment(),
  ));
}