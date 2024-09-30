import 'dart:convert';
import 'package:betplus_ios/Fee_payment/duplicates.dart'; // Assuming this is your duplicates widget
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    const url =
        'https://mritsexams.com/CoreAPI/Flutter/CertificateDropDownForFlutter';
    final requestBody = {
      "GrpCode": grpCodeValue,
      "ColCode": "PSS",
      "CollegeId": "0001",
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

  // Function to handle the "Show Total" button click
  Future<void> showTotal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String admnNo = prefs.getString('admnNo') ?? '';
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    int schoolId = prefs.getInt('schoolId') ?? 0;
    int studId = prefs.getInt('studId') ?? 0;
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

    final requestBody = {
      "GrpCode": grpCodeValue,
      "ColCode": "PSS",
      "CollegeId": "0001",
      "SchoolId": schoolId,
      "Flag": 1,
      "FYearId": 0,
      "CertificateIds": "",
      "Copies": "",
      "CaptchaImg": "",
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
      "NewTxnIdMain": 0,
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
        print(response.body);

        // Extract certificates list
        final certificatesList =
            data['cerificatesDropDownForFlutterList'] as List<dynamic>;

        // Prepare the message to display
        StringBuffer messageBuffer = StringBuffer();
        int grandTotal = 0;

        for (var certificate in certificatesList) {
          final certificateName =
              certificate['certificateName'] ?? "Unknown Certificate";
          final totalAmount =
              (certificate['totalAmount'] ?? 0) as num; // Get as num
          grandTotal +=
              totalAmount.toInt(); // Convert to int and add to grandTotal
          messageBuffer.writeln("$certificateName: ${totalAmount}");
        }
        messageBuffer.writeln("\nGrand Total: ${grandTotal}");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Total Amount"),
            content: SingleChildScrollView(child: Text(messageBuffer.toString())),
            actions: [
              TextButton(
                onPressed: () {
                  // Extract Paytm details for transaction
                  final paytmDetails = data['paytmDetailsList']?[0];
                  if (paytmDetails != null) {
                    final productId = paytmDetails['productId'] ?? '';
                    final ordeR_ID = paytmDetails['ordeR_ID'] ?? '';
                    final callbacK_URL = paytmDetails['callbacK_URL'] ?? '';
                    final txnToken = paytmDetails['paytmResponseCertificates']['body']['txnToken'] ?? '';

                    // Close the dialog
                    Navigator.of(context).pop();

                    // Proceed with Paytm payment
                    initiatePaytmTransaction(txnToken, productId, grandTotal, ordeR_ID, callbacK_URL);
                  } else {
                    print("No Paytm details found");
                    Navigator.of(context).pop(); // Close the dialog if no details found
                  }
                },
                child: const Text("Proceed to Pay"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(), // Close the dialog
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
      String txnToken,
      String productId,
      int amount,
      String orderId, // Fixed capitalization
      String callbackUrl // Fixed capitalization
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
      print("Amount: $amount");
      print("Order ID: $orderId");
      print("Callback URL: $callbackUrl");

      var response = AllInOneSdk.startTransaction(
          productId,
          orderId,

          amount.toString(),
          // Amount
          txnToken,
          // Order ID
          callbackUrl,
          // Callback URL (If available)
          false,
          // Is Staging (for testing set true, for production set false)
          false // Enable 4G optimization
      );

      response.then((value) {
        print("Transaction Successful: $value");
        // Handle the response from Paytm after transaction completes.
        // You can navigate the user to a success page or show a confirmation dialog.
      }).catchError((onError) {
        print("Transaction failed: $onError");
        // Handle transaction failure here
      });
    } catch (e) {
      print("Error in initiating Paytm transaction: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
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

                                  return ListTile(
                                    title: Text(certificateName),
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
                            onPressed: showTotal,
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
