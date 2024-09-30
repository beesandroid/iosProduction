import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../views/MainPage.dart';

class Condonation extends StatefulWidget {
  const Condonation({super.key});

  @override
  State<Condonation> createState() => _CondonationState();
}

class _CondonationState extends State<Condonation> {
  Map<String, dynamic>? responseData;

  String result = ''; // To store the result of the transaction

  @override
  void initState() {
    super.initState();
    _fetchCondonationDetails();
  }

  Future<void> _fetchCondonationDetails() async {
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
    String collegeId = prefs.getString('collegeId') ?? '';
    String admnNo = prefs.getString('admnNo') ?? '';
    final url = Uri.parse(
        'https://mritsexams.com/CoreAPI/Flutter/StudCondonationFeeFillDetails');
    final requestBody = {
      "GrpCode": grpCodeValue,
      "ColCode": colCode,
      "SchoolId": schoolid,
      "CollegeId": collegeId,
      "AdmnNo": admnNo
    };
print(requestBody);
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data['singleStudCondonationFeeFillDetailsList']['AtomTransId']);
        final atomId =
            data['singleStudCondonationFeeFillDetailsList']['AtomTransId'];
        setState(() {
          responseData = data['singleStudCondonationFeeFillDetailsList'];
          responseData!['atomId'] = atomId;
        });
      } else {
        print('Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  void _onPayButtonPressed(String captchaImg, newTxnId) async {
    if (responseData != null) {
      final orderId = responseData!['ORDER_ID'];
      final atomId = responseData!['atomId'];
      final amount = responseData!['TXN_AMOUNT'];
      final callbackUrl = responseData!['CALLBACK_URL'];
      final mid = responseData!['MID']; // Extracting MID from response
      const isStaging = false; // Set to false for production
      const restrictAppInvoke = false;

      try {
        var response = await AllInOneSdk.startTransaction(
          mid,
          orderId,
          amount.toString(),
          responseData!['paytmResponseCondonation']['body']['txnToken'],
          callbackUrl,
          isStaging,
          restrictAppInvoke,
        );

        print("Transaction response: $response");

        if (response != null && response['STATUS'] == "TXN_SUCCESS") {
          // Convert the response map to Map<String, dynamic>
          Map<String, dynamic> transactionResponse =
              Map<String, dynamic>.from(response);
          await handleSuccessfulTransaction(
              transactionResponse, newTxnId, captchaImg,atomId);
        }

        setState(() {
          result = response.toString();
        });
      } catch (onError) {
        if (onError is PlatformException) {
          setState(() {
            result = "${onError.message} \n ${onError.details.toString()}";
          });
        } else {
          setState(() {
            result = onError.toString();
          });
        }
      }
    }
  }

  Future<void> handleSuccessfulTransaction(
      Map<String, dynamic> transactionResponse,
      newTxnId,
      String captchaImg,
      atomId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String email = prefs.getString('email') ?? '';
    int schoolId = prefs.getInt('schoolId') ?? 0;
    int studId = prefs.getInt('studId') ?? 0;
    int fYearId = prefs.getInt('fYearId') ?? 0;
    int acYearId = prefs.getInt('acYearId') ?? 0;
    String sem = prefs.getString('betSem') ?? '';
    String betBranchCode = prefs.getString('betBranchCode') ?? '';
    String betStudMobile = prefs.getString('betStudMobile') ?? '';

    // Extracting transaction details from response
    String mid = transactionResponse['MID'];
    String orderId = transactionResponse['ORDERID'];
    String bankTxnId = transactionResponse['BANKTXNID'];
    String txnAmount = transactionResponse['TXNAMOUNT'];
    String status = transactionResponse['STATUS'];
    String tnxid = transactionResponse['TXNID'];
    String admnNo = prefs.getString('admnNo') ?? '';
    String newTxnIdString = newTxnId.toString();

    // Preparing request body for printing
    Map<String, dynamic> requestBody = {
      'grpCode': grpCodeValue,
      'colCode': colCode,
      'collegeId': "0001",
      "AdmnNo": admnNo,
      'studId': studId.toString(),
      'mobileNo': betStudMobile,
      'email': email,
      'newTxnId': newTxnIdString,
      'captchaImg': captchaImg,
      'acYearId': acYearId.toString(),
      'paymentDt': "2024-04-01", // Use actual payment date
      'fee': txnAmount.toString(),
      'branchCode': betBranchCode,

      'sem': sem,
      'fyearId': fYearId.toString(),
      'atomTransId': atomId,
      'merchantTransId': mid,
      'transAmt': txnAmount,
      'transSurChargeAmt': "0", // Assuming no surcharge
      'transDate': "2024-04-01 16:10:10.0", // Use actual transaction date
      'bankTransId': bankTxnId,
      'transStatus': status,
      'bankName': "", // Add if available
      'paymentDoneThrough': "PPBLC",
      'cardNumber': "",
      'cardHolderName': "",
      'address': "HYDERABAD",
      'transDescription': status,
      'success': "0",
      'txnId': tnxid,
      'txnAmount': txnAmount.toString(),
    };

    // Print the request body
    print("Request Body: $requestBody");

    // Call saveCondonationFee with the request body
    await saveCondonationFee(
      grpCode: grpCodeValue,
      colCode: colCode,
      collegeId: "0001",
      studId: studId.toString(),
      mobileNo: betStudMobile,
      email: email,
      AdmnNo: admnNo,
      newTxnId: newTxnIdString,
      captchaImg: captchaImg,
      acYearId: acYearId.toString(),
      paymentDt: "2024-04-01",
      fee: txnAmount.toString(),
      branchCode: betBranchCode,
      sem: sem,
      fyearId: fYearId.toString(),
      atomTransId: atomId,
      merchantTransId: mid,
      transAmt: txnAmount,
      transSurChargeAmt: "0",
      transDate: "2024-04-01 16:10:10.0",
      bankTransId: bankTxnId,
      transStatus: status,
      bankName: "",
      paymentDoneThrough: "PPBLC",
      cardNumber: "",
      cardHolderName: "",
      address: "HYDERABAD",
      transDescription: status,
      success: "0",
      txnId: tnxid,
      txnAmount: "", AtomTransId: atomId,
    );
  }


  String generateRandomCaptcha() {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final random = Random();
    return List.generate(6, (index) => letters[random.nextInt(letters.length)])
        .join();
  }

  Future<void> saveCondonationFee({
    required String grpCode,
    required String colCode,
    required String collegeId,
    required String studId,
    required String mobileNo,
    required String email,
    required String newTxnId,
    required String captchaImg,
    required String acYearId,
    required String paymentDt,
    required String fee,
    required String branchCode,
    required String sem,
    required String fyearId,
    required String atomTransId,
    required String merchantTransId,
    required String transAmt,
    required String transSurChargeAmt,
    required String transDate,
    required String bankTransId,
    required String transStatus,
    required String bankName,
    required String paymentDoneThrough,
    required String cardNumber,
    required String cardHolderName,
    required String address,
    required String txnAmount,
    required String transDescription,
    required String AtomTransId,
    required String success, required String txnId, required  AdmnNo,

  }) async {
    final url =
        'https://mritsexams.com/CoreAPI/Flutter/SaveCondonationFeeMainData';

    // bandarupattabhi@ybl
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String admnNo = prefs.getString('admnNo') ?? '';
    // Prepare the request body
    final requestBody = {
      "GrpCode": grpCode,
      "ColCode": colCode,
      "CollegeId": "0001",
      "StudId": studId,
      "MobileNo": mobileNo,
      "Email": email,
"AdmnNo":admnNo,
      "NewTxnId": newTxnId,
      "CaptchaImg": captchaImg,
      "AcYearId": acYearId,
      "PaymentDt": paymentDt,
      "Fee":transAmt,
      "BranchCode": branchCode,
      "Sem": sem,
      "FyearId": fyearId,
      "AtomTransId": responseData!['atomId'],
      "MerchantTransId": merchantTransId,
      "TransAmt": transAmt,
      "TransSurChargeAmt": transSurChargeAmt,
      "TransDate": transDate,
      "BankTransId": bankTransId,
      "TransStatus": transStatus,
      "BankName": bankName,
      "PaymentDoneThrough": paymentDoneThrough,
      "CardNumber": cardNumber,
      "CardHolderName": cardHolderName,
      "Address": address,
      "TransDescription": transDescription,
      "Success": success,
      "TxnId":txnId


    };
    print("vvv" + requestBody.toString());
    // print("vvvvv"+requestBody.toString());

    // Send the POST request
    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode(requestBody),
    );

    // Check the response
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment successfull'),
        ),
      );
      final responseData = jsonDecode(response.body);
      print(responseData);

      int receiptId =
      responseData['singleSaveCondonationFeeMainDataList']['recieptId'];
      print('Receipt ID: $receiptId');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF downloading in process.'),
        ),
      );
      await _fetchFeeReceiptsReport(receiptId, context);
      print('Condonation fee saved successfully: ${response.body}');
    } else {
      print(
          'Failed to save condonation fee: ${response.statusCode} ${response.body}');
    }
  }
  Future<void> _fetchFeeReceiptsReport(
      int receiptId, BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String grpCodeValue = prefs.getString('grpCode') ?? '';
      int schoolid = prefs.getInt('schoolId') ?? 0;
      final requestBody = {
        "GrpCode": grpCodeValue,
        "CollegeId": "0001",
        "ColCode": "PSS",
        "SchoolId": schoolid,
        "RecId": receiptId,
        "Type": "Condonation",
        "Words": "",
        "Flag": 3,
      };
      print('Request body: ${jsonEncode(requestBody)}');
      final response = await http.post(
        Uri.parse('https://mritsexams.com/CoreApi/Android/FeeReceiptsReports'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
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

  String getTodayDate() {
    DateTime now = DateTime.now();
    return DateFormat('yyyy-MM-dd').format(now);
  }

  Future<void> _onPayPressed(String captchaImg) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    int schoolId = prefs.getInt('schoolId') ?? 0;
    int studId = prefs.getInt('studId') ?? 0;
    int fYearId = prefs.getInt('fYearId') ?? 0;
    int acYearId = prefs.getInt('acYearId') ?? 0;
    String sem = prefs.getString('betSem') ?? '';
    String betBranchCode = prefs.getString('betBranchCode') ?? '';

    // Ensure responseData is not null before accessing its properties
    if (responseData != null) {
      final amount =
          responseData!['TXN_AMOUNT'] ?? '0.00'; // Default value if null
      String captchaImg = generateRandomCaptcha(); // Generate captcha

      // Prepare the request payload
      final payload = {
        "CollegeId": "0001",
        "GrpCode": grpCodeValue,
        "ColCode": colCode,
        "SchoolId": schoolId,
        "StudId": studId,
        "PaymentDt": getTodayDate(),
        "CaptchaImg": captchaImg,
        "AcYearId": acYearId,
        "Fee": amount, // Ensure amount is a valid String
        "BranchCode": betBranchCode,
        "Sem": sem,
        "FYearId": fYearId,
      };

      try {
        final response = await http.post(
          Uri.parse(
              'https://mritsexams.com/CoreAPI/Flutter/SaveCondonationFeeTempData'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final newTxnId =
              responseData['singleSaveCondonationFeeTempDataList']['newTxnId'];
          if (newTxnId != null) {
            _onPayButtonPressed(captchaImg, newTxnId);
          } else {
            print('New Transaction ID is null');
          }
          print('Transaction ID: $newTxnId');
        } else {
          print('Failed to save condonation fee: ${response.body}');
        }
      } catch (e) {
        print('Error occurred: $e');
      }
    } else {
      print('Response data is null');
    }
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.lightGreen,
        title: const Text(
          'Condonation',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: responseData == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    width: double.infinity, // Ensure full width
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [


                            Text(
                              'Admission No: ${responseData!['admnNo']}',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Branch: ${responseData!['branchCode']}',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Batch: ${responseData!['batch']}',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Condon Fee: ${responseData!['condonFee']}',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Total: ${responseData!['TotalFee']}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Text(result),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 220,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.lightGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        String captchaImg = generateRandomCaptcha();
                        _onPayPressed(captchaImg);
                      },
                      child: Text(
                        'Pay Now',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
