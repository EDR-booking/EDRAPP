import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_2/features/payment/services/payment_service.dart';
import 'package:flutter_application_2/features/payment/models/payment_model.dart';
import 'package:flutter_application_2/features/ticket/models/ticket_model.dart';
import 'package:flutter_application_2/data/repositories/ticket_repositories.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_application_2/features/payment/screens/payment_webview_screen.dart';

class PaymentController extends GetxController {
  static PaymentController get to => Get.find();
  
  // Services and repositories
  final PaymentService _paymentService = PaymentService();
  final TicketRepository _ticketRepo = TicketRepository();
  
  // Observable states
  final RxBool isLoading = false.obs;
  final RxBool isPaymentInitialized = false.obs;
  final RxBool isPaymentCompleted = false.obs;
  final RxString paymentStatus = 'pending'.obs;
  final RxString paymentError = ''.obs;
  
  // Payment data
  final Rx<PaymentResponse?> paymentResponse = Rx<PaymentResponse?>(null);
  final Rx<PaymentStatus?> currentPaymentStatus = Rx<PaymentStatus?>(null);
  
  // Initialize Chapa payment with Supabase Edge Function
  Future<bool> initializePayment(TicketModel ticket) async {
    try {
      isLoading.value = true;
      paymentError.value = '';
      
      // Generate a unique payment ID based on the ticket number
      final paymentId = 'EDR-TICKET-${ticket.ticket_number}-${DateTime.now().millisecondsSinceEpoch}';
      
      // Initialize payment with Chapa integration
      final htmlContent = await _paymentService.initializePaymentWithChapa(
        ticket: ticket,
        returnUrl: 'edrapp://payment-callback',
      );
      
      if (htmlContent != null && htmlContent.isNotEmpty) {
        // Update ticket with payment ID
        if (ticket.id != null) {
          final updatedTicket = ticket.copyWith(
            paymentId: paymentId,
            paymentStatus: 'processing'
          );
          await _ticketRepo.updateTicket(ticket.id!, updatedTicket);
        }
        
        isLoading.value = false;
        
        // Show WebView screen with Chapa payment form
        final result = await Get.to(() => PaymentWebViewScreen(
          htmlContent: htmlContent,
          ticket: ticket,
          paymentId: paymentId,
        ));
        
        // If we returned with a success result
        return result == true;
      } else {
        paymentError.value = 'Failed to generate payment form';
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      paymentError.value = 'Failed to initialize payment: $e';
      isLoading.value = false;
      return false;
    }
  }
  
  // This method is no longer needed with the WebView approach
  // but kept for backward compatibility
  Future<bool> openCheckoutUrl() async {
    debugPrint('openCheckoutUrl is deprecated with WebView integration');
    
    if (paymentResponse.value?.checkoutUrl == null) {
      paymentError.value = 'No checkout URL available';
      return false;
    }
    
    try {
      final Uri url = Uri.parse(paymentResponse.value!.checkoutUrl!);
      
      // Launch URL
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        return true;
      } else {
        paymentError.value = 'Could not launch payment URL';
        return false;
      }
    } catch (e) {
      paymentError.value = 'Error opening payment page: $e';
      return false;
    }
  }
  
  // Update ticket payment details
  Future<bool> updateTicketPaymentDetails(String ticketId, TicketModel updatedTicket) async {
    try {
      await _ticketRepo.updateTicket(ticketId, updatedTicket);
      return true;
    } catch (e) {
      debugPrint('Error updating ticket payment details: $e');
      return false;
    }
  }
  
  // Check the status of a payment
  Future<bool> checkPaymentStatus(String paymentId, String ticketId) async {
    try {
      isLoading.value = true;
      paymentError.value = '';
      
      final status = await _paymentService.checkPaymentStatus(paymentId);
      currentPaymentStatus.value = status;
      
      if (status.status == 'success' || status.status == 'completed') {
        // Payment completed successfully
        isPaymentCompleted.value = true;
        
        // Update ticket if we have a ticket ID
        if (ticketId.isNotEmpty) {
          final ticket = await _ticketRepo.getTicketById(ticketId);
          if (ticket != null) {
            final updatedTicket = ticket.copyWith(
              status: 'confirmed',
              paymentStatus: 'completed',
              paymentMethod: 'online',
              paymentDate: DateTime.now(),
              paymentReference: status.reference ?? paymentId,
            );
            await _ticketRepo.updateTicket(ticketId, updatedTicket);
          }
        }
        
        isLoading.value = false;
        return true;
      } else if (status.status == 'pending') {
        // Payment still pending
        isLoading.value = false;
        return false;
      } else {
        // Payment failed
        paymentError.value = 'Payment failed or was cancelled';
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      paymentError.value = 'Error checking payment status: $e';
      isLoading.value = false;
      return false;
    }
  }
  
  // For demo: Complete payment without going through actual payment gateway
  Future<bool> completePaymentDemo(TicketModel ticket) async {
    try {
      isLoading.value = true;
      
      // Generate a demo payment ID if none exists
      final paymentId = ticket.paymentId ?? 'demo_${DateTime.now().millisecondsSinceEpoch}';
      
      // Simulate payment verification
      final status = await _paymentService.simulateVerifyPayment(paymentId);
      currentPaymentStatus.value = status;
      paymentStatus.value = 'completed';
      isPaymentCompleted.value = true;
      
      // Update ticket with payment details if we have an ID
      if (ticket.id != null) {
        final updatedTicket = ticket.copyWith(
          paymentStatus: 'completed',
          paymentId: paymentId,
          paymentMethod: 'demo_payment',
          paymentReference: status.reference,
          paymentDate: DateTime.now(),
          status: 'confirmed', // Ensure ticket is confirmed
        );
        
        await _ticketRepo.updateTicket(ticket.id!, updatedTicket);
      }
      
      isLoading.value = false;
      return true;
    } catch (e) {
      paymentError.value = 'Error completing demo payment: $e';
      isLoading.value = false;
      return false;
    }
  }
  
  // Reset payment state
  void resetPaymentState() {
    isPaymentInitialized.value = false;
    isPaymentCompleted.value = false;
    paymentStatus.value = 'pending';
    paymentError.value = '';
    paymentResponse.value = null;
    currentPaymentStatus.value = null;
  }
}
