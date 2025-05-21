import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/payment_model.dart';
import '../../ticket/models/ticket_model.dart';

class PaymentService {
  // Base URL for Supabase Edge Functions
  // Using the actual URL of your deployed functions
  final String _edgeFunctionUrl = 'https://ycyzzrtkgdcjgyyvxvtr.supabase.co/functions/v1';
  
  // This would come from environment variables in production
  // Your Supabase anon key
  final String _supabaseApiKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InljeXp6cnRrZ2Rjamd5eXZ4dnRyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTUwMTI2NjgsImV4cCI6MjAzMDU4ODY2OH0.eDLELKI_yMlEGJoMXy-EY0QkYQgxC1xhvB_lkU-q-VE';
  
  // Initialize payment process and get a payment URL
  // Initialize payment by creating a direct Chapa checkout form
  Future<String?> initializePaymentWithChapa({
    required TicketModel ticket,
    required String returnUrl,
    String currency = 'ETB',
  }) async {
    try {
      debugPrint('Initializing Chapa payment for ticket: ${ticket.ticket_number}');
      
      // Generate a unique transaction reference
      final txRef = 'tx-${ticket.ticket_number}-${DateTime.now().millisecondsSinceEpoch}';
      
      // Create a direct HTML form for Chapa payment (no server-side needed)
      final html = '''
<!DOCTYPE html>
<html>
<head>
  <title>EDR Ticket Payment</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    body { font-family: Arial, sans-serif; text-align: center; padding: 20px; background-color: #f5f5f5; }
    .container { max-width: 500px; margin: 0 auto; background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
    .ticket-info { text-align: left; margin: 20px 0; border-top: 1px solid #eee; border-bottom: 1px solid #eee; padding: 15px 0; }
    .ticket-row { display: flex; justify-content: space-between; margin: 8px 0; }
    .total { font-weight: bold; font-size: 1.2em; margin-top: 15px; }
    .btn { background: #4CAF50; color: white; border: none; padding: 12px 20px; border-radius: 4px; cursor: pointer; font-size: 16px; margin-top: 20px; width: 100%; }
    .logo { max-width: 150px; margin-bottom: 20px; }
  </style>
</head>
<body>
  <div class="container">
    <h2>EDR Ticket Payment</h2>
    <div class="ticket-info">
      <div class="ticket-row">
        <span>Ticket Number:</span>
        <span>${ticket.ticket_number}</span>
      </div>
      <div class="ticket-row">
        <span>Journey:</span>
        <span>${ticket.departure} to ${ticket.arrival}</span>
      </div>
      <div class="ticket-row">
        <span>Passenger:</span>
        <span>${ticket.firstName} ${ticket.lastName}</span>
      </div>
      <div class="ticket-row">
        <span>Seat Type:</span>
        <span>${ticket.seatType}</span>
      </div>
      <div class="ticket-row total">
        <span>Total Amount:</span>
        <span>ETB ${ticket.price.toStringAsFixed(2)}</span>
      </div>
    </div>
    
    <p>Click the button below to complete your payment with Chapa's secure payment gateway.</p>
    
    <!-- Direct to Chapa Test Mode Page for Testing -->
    <form id="paymentForm" method="POST" action="https://checkout.chapa.co/checkout/payment">
      <input type="hidden" name="public_key" value="CHAPUBK_TEST-XruT6GlarWjIC5EIUsIO915GK3xbdFLE" />
      <input type="hidden" name="tx_ref" value="$txRef" />
      <input type="hidden" name="amount" value="${ticket.price}" />
      <input type="hidden" name="currency" value="ETB" />
      <input type="hidden" name="email" value="${ticket.email}" />
      <input type="hidden" name="first_name" value="${ticket.firstName}" />
      <input type="hidden" name="last_name" value="${ticket.lastName}" />
      <input type="hidden" name="title" value="EDR Train Ticket" />
      <input type="hidden" name="description" value="Train ticket: ${ticket.departure} to ${ticket.arrival}" />
      <input type="hidden" name="return_url" value="$returnUrl?tx_ref=$txRef" />
      <input type="submit" class="btn" value="Pay ETB ${ticket.price} Now" />
    </form>
    
    <script>
      // Auto-submit for better user experience
      document.addEventListener('DOMContentLoaded', function() {
        // Show a brief delay to let user see the ticket details
        setTimeout(function() {
          // You could uncomment this for auto-submit
          // document.getElementById('paymentForm').submit();
        }, 1000);
      });
    </script>
  </div>
</body>
</html>
      ''';
      
      return html;
    } catch (e) {
      debugPrint('Exception in initializePaymentWithChapa: $e');
      return null;
    }
  }
  
  // Legacy payment initialization for backward compatibility
  Future<PaymentResponse?> initializePayment({
    required TicketModel ticket,
    required String returnUrl,
    String currency = 'ETB',
  }) async {
    try {
      // Since we're now returning HTML from the Edge Function, 
      // we'll use the legacy demo implementation for the old method
      return await simulatePayment(ticket: ticket, returnUrl: returnUrl);
    } catch (e) {
      debugPrint('Exception in initializePayment: $e');
      return null;
    }
  }

  // Check payment status directly with Chapa API
  Future<PaymentStatus> checkPaymentStatus(String paymentId) async {
    try {
      debugPrint('Checking payment status for transaction: $paymentId');
      
      // Extract the transaction reference if needed
      // The paymentId from WebView might be in format "tx_ref=xxx" or just the txRef itself
      String txRef = paymentId;
      if (paymentId.contains('tx_ref=')) {
        txRef = paymentId.split('tx_ref=').last.split('&').first;
      }
      
      // For demo purposes with test credentials, we'll simulate a successful payment
      // since the Chapa API doesn't actually process test transactions for verification
      
      // In production, you would verify with Chapa API:
      /*
      const apiKey = 'CHASECK_TEST-VWePs4V7AiqneTuNqKkg3w4zuO5kDopC'; // Your Chapa test key
      final response = await http.get(
        Uri.parse('https://api.chapa.co/v1/transaction/verify/$txRef'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      );
      */
      
      // For demo, simulate a successful payment
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      debugPrint('Simulating successful payment for: $txRef');
      
      return PaymentStatus(
        status: 'completed',
        paymentId: txRef,
        reference: 'demo-ref-${DateTime.now().millisecondsSinceEpoch}',
        completedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Exception in checkPaymentStatus: $e');
      return PaymentStatus(status: 'error', paymentId: paymentId);
    }
  }

  // For the demo implementation, we'll simulate a payment process
  Future<PaymentResponse> simulatePayment({
    required TicketModel ticket,
    required String returnUrl,
  }) async {
    // In a real implementation this would be replaced with an actual API call
    await Future.delayed(const Duration(seconds: 2)); // Simulate network request
    
    final String mockPaymentId = 'demo_payment_${DateTime.now().millisecondsSinceEpoch}';
    final String mockCheckoutUrl = 'https://demo-payment.example/checkout?payment_id=$mockPaymentId';
    
    return PaymentResponse(
      success: true,
      paymentId: mockPaymentId,
      checkoutUrl: mockCheckoutUrl,
      message: 'Payment initialized successfully',
    );
  }

  // Simulate payment verification
  Future<PaymentStatus> simulateVerifyPayment(String paymentId) async {
    // In a real implementation this would be replaced with an actual API call
    await Future.delayed(const Duration(seconds: 2)); // Simulate network request
    
    // For demo purposes, we'll always return success
    return PaymentStatus(
      status: 'completed',
      paymentId: paymentId,
      reference: 'DEMO_REF_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      completedAt: DateTime.now(),
    );
  }
}
