import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_application_2/features/payment/controllers/payment_controller.dart';
import 'package:flutter_application_2/features/ticket/models/ticket_model.dart';
import 'package:flutter_application_2/features/ticket/screen/ticket_view_screen.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String htmlContent;
  final TicketModel ticket;
  final String paymentId;

  const PaymentWebViewScreen({
    Key? key,
    required this.htmlContent,
    required this.ticket,
    required this.paymentId,
  }) : super(key: key);

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late WebViewController _webViewController;
  final PaymentController _paymentController = Get.find<PaymentController>();
  bool _isLoading = true;
  bool _checkingPayment = false;
  bool _hasError = false;
  String _errorMessage = '';
  
  // Timer for periodic payment status checks
  int _checkCounter = 0;
  static const int _maxChecks = 30; // Max number of status checks
  
  @override
  void initState() {
    super.initState();
    _initWebView();
    
    // Print the HTML content to debug (truncated for privacy)
    debugPrint('HTML content length: ${widget.htmlContent.length}');
    debugPrint('HTML content preview: ${widget.htmlContent.substring(0, min(100, widget.htmlContent.length))}...');
  }

  void _initWebView() {
    debugPrint('Initializing WebView with Chapa payment form');
    
    // Create a WebViewController with proper API for version 4.11.0
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('WebView page started loading: $url');
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            debugPrint('WebView page finished loading: $url');
            setState(() {
              _isLoading = false;
            });
            
            // Check if the URL contains callback parameters from Chapa
            if (url.contains('tx_ref=') || url.contains('ticket_id=') || 
                url.contains('status=') || url.contains('edrapp://payment-callback')) {
              debugPrint('Detected payment callback URL: $url');
              _handlePaymentCallback(url);
            }
          },
          onUrlChange: (UrlChange change) {
            if (change.url != null) {
              debugPrint('WebView URL changed to: ${change.url}');
              
              // Check if we're returning from payment gateway
              if (change.url!.contains('tx_ref=') || 
                  change.url!.contains('status=') || 
                  change.url!.contains('edrapp://payment-callback')) {
                debugPrint('Detected payment completion via URL change: ${change.url}');
                _handlePaymentCallback(change.url!);
              }
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
            setState(() {
              _hasError = true;
              _errorMessage = 'Error loading payment page: ${error.description}';
              _isLoading = false;
            });
          },
        ),
      )
      // Set general settings for WebView
      ..enableZoom(true)
      // Load the HTML directly
      ..loadHtmlString(widget.htmlContent);
      
    // Set up JavaScript channel for communication if needed
    _webViewController.addJavaScriptChannel(
      'FlutterChannel',
      onMessageReceived: (JavaScriptMessage message) {
        debugPrint('Message from JavaScript: ${message.message}');
        
        // Handle any messages from the WebView if needed
        if (message.message.contains('payment_complete')) {
          _handlePaymentCallback('edrapp://payment-callback?status=success');
        }
      },
    );
  }
  
  void _handlePaymentCallback(String url) {
    if (_checkingPayment) return; // Prevent multiple checks
    
    _checkingPayment = true;
    _verifyPaymentStatus();
  }
  
  Future<void> _verifyPaymentStatus() async {
    try {
      // Start checking payment status
      bool paymentComplete = await _paymentController.checkPaymentStatus(
        widget.paymentId, 
        widget.ticket.id!
      );
      
      if (paymentComplete) {
        // If payment is successful, navigate to the ticket view
        Get.offAll(() => TicketViewScreen(
          ticket: widget.ticket.copyWith(
            status: 'confirmed',
            paymentStatus: 'completed',
          ), 
          isNewBooking: true,
        ));
      } else {
        // If still pending and we haven't reached max checks
        if (_checkCounter < _maxChecks) {
          // Wait a moment before checking again
          await Future.delayed(const Duration(seconds: 3));
          _checkCounter++;
          
          // Only continue checking if still on this screen
          if (mounted) {
            _checkingPayment = false;
            _verifyPaymentStatus();
          }
        } else {
          // Max checks reached, show error or alternative action
          setState(() {
            _checkingPayment = false;
            _hasError = true;
            _errorMessage = 'Payment verification timed out. Please check your payment status in "My Tickets" section.';
          });
        }
      }
    } catch (e) {
      debugPrint('Error verifying payment: $e');
      setState(() {
        _checkingPayment = false;
        _hasError = true;
        _errorMessage = 'Failed to verify payment status.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Get.back();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _webViewController.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // WebView
          WebViewWidget(
            controller: _webViewController,
          ),
          
          // Loading indicator
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
            
          // Error message if payment verification fails
          if (_hasError)
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _errorMessage,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _hasError = false;
                      });
                      _webViewController.reload();
                    },
                    child: const Text('Try Again'),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
            
          // Payment processing indicator
          if (_checkingPayment)
            Container(
              color: Colors.black54,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 20),
                  Text(
                    'Verifying payment...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
