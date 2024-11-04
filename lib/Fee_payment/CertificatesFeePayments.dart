import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:betplus_ios/Fee_payment/duplicates.dart'; // Assuming this is your duplicates widget
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class CertificateFeePayments extends StatefulWidget {
  const CertificateFeePayments({super.key});

  @override
  State<CertificateFeePayments> createState() => _CertificateFeePaymentsState();
}

class _CertificateFeePaymentsState extends State<CertificateFeePayments> {
  final PageController _pageController = PageController();
  List certificates = [];
  Map<int, int> selectedCopies = {}; // Maps certificateId to selected copies
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    fetchCertificates();
  }

  Future<void> fetchCertificates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String admnNo = prefs.getString('admnNo') ?? '';
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
      "StudId": studId,
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
        print(data);
        setState(() {
          certificates = data['cerificatesDropDownForFlutterList']
              .where((certificate) =>
                  certificate['certificateId'] != 4 &&
                  certificate['certificateId'] != 1)
              .toList();

          // Initialize selectedCopies with 0 for each certificate
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
      "ExamType":"",
      "Sem": "",
      "MonthYear": "",
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
    print("sssss"+requestBody.toString());


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

  // Function to handle number of copies selection
  void selectCopies(int certificateId, int copies) {
    setState(() {
      selectedCopies[certificateId] = copies;
    });
  }

  // Function to calculate total copies
  int getTotalCopies() {
    return selectedCopies.values
        .fold(0, (previousValue, copies) => previousValue + copies);
  }

  String generateRandomText(int length) {
    const _chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final _random = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => _chars.codeUnitAt(_random.nextInt(_chars.length))));
  }

  // Function to handle the "Show Total" button click
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
    // Prepare data for the API request
    final List<Map<String, dynamic>> studentCertificates = selectedCopies
        .entries
        .where((entry) =>
            entry.value > 0) // Only include certificates with copies > 0
        .map((entry) => {
              "CertificateId": entry.key,
              "Copies": entry.value,
              "ExamType": "",
              "Sem": "",
              "MonthYear": "",
              "CopyType": 0
            })
        .toList();
    var captcha = generateRandomText(6).toString();
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
      "StudentOnlineCertificatesVariable": studentCertificates,
    };
    print(requestBody);

    // Call the API with selected values
    const url =
        'https://mritsexams.com/CoreAPI/Flutter/CertificateDropDownForFlutter';
    try {
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
                  print("122"+atomTransId.toString());
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


  Future<void> initiatePaytmTransaction(
      txnToken, productId, grandTotal,
      ordeR_ID, callbacK_URL, captcha, atomTransId,newTxnId, // Fixed capitalization
      ) async {
    try {
      //   mid,
      // orderId,
      // amount.toString(),
      // responseData!['paytmResponseCondonation']['body']['txnToken'],
      // callbackUrl,
      // isStaging,
      // restrictAppInvoke,
      print("Initiating Paytm transaction with:");
      print("Product ID: $productId");
      print("Transaction Token: $txnToken");
      print("Amount: $grandTotal");
      print("Order ID: $ordeR_ID");
      print("Callback URL: $callbacK_URL");

      var response = AllInOneSdk.startTransaction(
          productId,
          ordeR_ID,
          grandTotal.toString(),
          // Amount
          txnToken,
          // Order ID
          callbacK_URL,
          // Callback URL (If available)
          false,
          // Is Staging (for testing set true, for production set false)
          false // Enable 4G optimization
          );

      response.then((value) {
        print("Transaction Successful: $value");
        // Extracting necessary values from the transaction response
        String txnId = value?['TXNID'];
        String orderId = value?['ORDERID'];
        String txnAmount = value?['TXNAMOUNT'];
        String paymentMode = value?['PAYMENTMODE'];
        String bankTxnId = value?['BANKTXNID'];
        String txnDate = value?['TXNDATE'];

        // Call the API again with Flag = 5
        callApiWithFlag5(txnId, ordeR_ID, txnAmount, paymentMode, bankTxnId,
            txnDate, captcha, newTxnId, productId,atomTransId);
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
              "ExamType": "",
              "Sem": "",
              "MonthYear": "",
              "CopyType": 0,
            })
        .toList();

    final requestBody = {
      "GrpCode": grpCodeValue,
      "ColCode": colCode,
      "CollegeId": collegeId,
      "SchoolId": schoolId,
      "Flag": 5, // Updating flag to 5
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
      "MerchantTransId": newTxnId,
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
      "NewTxnIdMain": productId,
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



  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child:
      Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.lightGreen,
          title: const Text(
            "Certificate Fee Payments",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            labelColor: Colors.white, // Color for selected tab text
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(
                child: Text(
                  "Certificates",
                  style: TextStyle(
                    fontWeight: FontWeight.bold, // Make text bold
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "Grade Memos",
                  style: TextStyle(
                    fontWeight: FontWeight.bold, // Make text bold
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  Column(
                    // Wrap the first tab's content in a Column
                    children: [
                      certificates.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : Expanded(
                              child: ListView.builder(
                                itemCount: certificates.length,
                                itemBuilder: (context, index) {
                                  final certificate = certificates[index];
                                  final certificateId =
                                      certificate['certificateId'];
                                  final certificateName =
                                      certificate['certificateName'];
                                  final int copiesoutPut =
                                      certificate['copiesoutPut'];

                                  return ListTile(
                                    title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(certificateName),
                                      ],
                                    ),
                                    trailing: DropdownButton<int>(
                                      value: selectedCopies[certificateId] ?? 0,
                                      // Default to 0
                                      onChanged: (value) {
                                        if (value != null) {
                                          selectCopies(certificateId, value);
                                        }
                                      },
                                      items: List.generate(11,
                                              (i) => i) // Generates from 0 to 9
                                          .map<DropdownMenuItem<int>>(
                                            (int value) =>
                                                DropdownMenuItem<int>(
                                              value: value,
                                              child: Text(value.toString()),
                                            ),
                                          )
                                          .toList(),
                                    ),
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
                                backgroundColor: Colors.lightGreen),
                            onPressed: (){ Tempsave();},
                            child: Text(
                              'Show Total',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Duplicates(), // The second tab remains unaffected
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
