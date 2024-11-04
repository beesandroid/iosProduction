import 'dart:convert';
import 'package:betplus_ios/views/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class WebViewScreen extends StatefulWidget {
  final String bdorderid;
  final String mercid;
  final String rdata;

  WebViewScreen({
    required this.bdorderid,
    required this.mercid,
    required this.rdata, required String initialUrl,
  });

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _webViewController;
  bool _loading = true;
  late ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _loading = false;
            });
            _progressDialog.dismiss();
          },
          onNavigationRequest: (NavigationRequest request) {
            if (handleDeepLink(request.url)) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            print("WebView error: ${error.description}");
            _progressDialog.dismiss();
          },
        ),
      );

    loadBillDeskPaymentPage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _progressDialog = ProgressDialog(context: context);
    if (_loading) {
      _progressDialog.show();
    }
  }

  @override
  void dispose() {
    _progressDialog.dismiss();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Page'),
        automaticallyImplyLeading: false,
      ),
      body: WillPopScope(
        onWillPop: () async {
          if (await _webViewController.canGoBack()) {
            _webViewController.goBack();
            return false;
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SplashScreen()),
            );
            return true;
          }
        },
        child: Stack(
          children: [
            WebViewWidget(controller: _webViewController),
            if (_loading)
              Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  void loadBillDeskPaymentPage() {
    String htmlContent = """
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Payment Page</title>
        <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
        <style>
          .left-align { text-align: left; }
          .btn-chatgpt { color: #ffffff; background-color: #17a2b8; border-color: #17a2b8; margin-top: 10px; }
          h3 { margin: 0; padding: 20px 20px 10px; font-size: 20px; background-color: #f8f9fa; margin-bottom: 20px; }
          ol { margin-left: 20px; padding-left: 0; }
          ol li { margin-bottom: 10px; font-size: 18px; }
          body { font-size: 16px; overflow-x: auto; overflow-y: none; padding-top: 0; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="row justify-content-center">
            <div class="col-md-6">
              <div class="left-align">
                <div class="content">
                  <h3 class="text-center">Instructions for Completing Payment</h3>
                  <ol>
                    <li>Ensure you have an active & stable internet connection before proceeding with the payment.</li>
                    <li>Choose UPI or QR Code option to pay.</li>
                    <li>Double-check all entered payment details to ensure they are correct before proceeding.</li>
                    <li>Use the Sign up button to restart the transaction if an error occurs.</li>
                    <li>Verify that you receive a confirmation on successful transaction.</li>
                    <li>Click the 'Login' button to access.</li>
                  </ol>
                  <div class="text-center">
                    <form name="sdklaunch" id="sdklaunch" action="https://pay.billdesk.com/web/v1_2/embeddedsdk" method="POST">
                      <input type="hidden" id="bdorderid" name="bdorderid" value="${widget.bdorderid}">
                      <input type="hidden" id="merchantid" name="merchantid" value="${widget.mercid}">
                      <input type="hidden" id="rdata" name="rdata" value="${widget.rdata}">
                      <button class="btn btn-chatgpt" type="submit">Complete your Payment</button>
                    </form>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <hr>
        </div>
      </body>
      </html>
    """;

    _webViewController.loadHtmlString(htmlContent);
  }

  bool handleDeepLink(String url) {
    Uri uri = Uri.parse(url);
    if (url.startsWith("upi://")) {
      try {
        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        return true;
      } catch (e) {
        print("Can't resolve intent: ${e.toString()}");
      }
    } else if (uri.host == "www.beessoftware.com" && uri.path.startsWith("/v1/")) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SplashScreen()),
      );
      return true;
    }
    return false;
  }
}

class ProgressDialog {
  final BuildContext context;
  bool _isShowing = false;

  ProgressDialog({required this.context});

  void show() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isShowing) {
        _isShowing = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text('Connecting'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Please wait...'),
              ],
            ),
          ),
        );
      }
    });
  }

  void dismiss() {
    if (_isShowing) {
      _isShowing = false;
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  bool get isShowing => _isShowing;
}
