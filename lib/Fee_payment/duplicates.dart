import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    const url =
        'https://mritsexams.com/CoreAPI/Flutter/CertificateDropDownForFlutter';
    final requestBody = {
      "GrpCode": grpCodeValue,
      "ColCode": "PSS",
      "CollegeId": "0001",
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
      "NewTxnIdMain": 0,
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

  Future<void> showTotal(BuildContext context) async {
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
                        ordeR_ID, callbacK_URL);
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

  Future<void> selectCopies(int certificateId, int copies) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String grpCodeValue = prefs.getString('grpCode') ?? '';
    int schoolId = prefs.getInt('schoolId') ?? 0;
    int studId = prefs.getInt('studId') ?? 0;

    setState(() {
      selectedCopies[certificateId] = copies;
    });
    final requestBody = {
      "GrpCode": grpCodeValue,
      "ColCode": "PSS",
      "CollegeId": "0001",
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
      "NewTxnIdMain": 0,
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

    final selectedExamTypeValue = selectedExamType[certificateId] ?? '';
    final selectedSemValue = selectedSem[certificateId] ?? '';

    if (selectedExamTypeValue.isNotEmpty && selectedSemValue.isNotEmpty) {
      final requestBody = {
        "GrpCode": grpCodeValue,
        "ColCode": "PSS",
        "CollegeId": "0001",
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
                                  selectCopies(certificateId, value);
                                }
                              },
                              items: List.generate(
                                      11, (i) => i) // Generates from 0 to 9
                                  .map<DropdownMenuItem<int>>(
                                    (int value) => DropdownMenuItem<int>(
                                      value: value,
                                      child: Text(value.toString()),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),

                          // Dropdown for semList if available
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

                          // Dropdown for semList
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

                          // Dropdown for monthYearList
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
                          backgroundColor: Colors.lightGreen),
                      onPressed: () async {
                        await showTotal(context);
                      },
                      child: const Text(
                        'Show Total',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
