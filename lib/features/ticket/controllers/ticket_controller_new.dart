import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:math';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Repositories
import '../../../data/repositories/ticket_repositories.dart';
import '../../../features/price/repositories/price_repository.dart';
import '../../../features/price/models/price_model.dart';
import '../models/ticket_model.dart';
import '../screen/ticket_view_screen.dart';
import '../services/ticket_email_service.dart';
import '../../../features/payment/screens/payment_screen.dart';
import '../../../features/payment/controllers/payment_controller.dart';
import 'package:flutter_application_2/services/otp_service.dart';

class TicketController extends GetxController {
  static TicketController get to => Get.find();

  // Text Controllers
  final TextEditingController departureController = TextEditingController();
  final TextEditingController arrivalController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passportController = TextEditingController();
  final TextEditingController seatController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  final TextEditingController selectedCitizenshipController = TextEditingController();

  // Repositories
  final TicketRepository _ticketRepo = TicketRepository();
  final PriceRepository _priceRepo = PriceRepository();
  final TicketEmailService _emailService = TicketEmailService();

  // OTP Verification
  final RxBool isEmailVerified = false.obs;
  final OTPService _otpService = OTPService();
  final RxBool isSendingOTP = false.obs;
  final RxBool isVerifyingOTP = false.obs;
  final RxString otpError = ''.obs;
  final RxString otpCode = ''.obs;
  final RxString verifiedEmail = ''.obs;

  // Observable variables
  final Rx<String?> selectedDepartureStation = Rx<String?>(null);
  final Rx<String?> selectedArrivalStation = Rx<String?>(null);
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final RxInt currentPage = 0.obs;
  final RxString departureStation = ''.obs;
  final RxString arrivalStation = ''.obs;
  final Rx<DateTime> date = DateTime.now().obs;
  final RxString citizenship = 'Ethiopian'.obs;
  final RxString firstName = ''.obs;
  final RxString lastName = ''.obs;
  final RxString email = ''.obs;
  final RxString phone = ''.obs;
  final RxString passport = ''.obs;
  final RxString seatType = 'regular'.obs;
  final RxString bedPosition = ''.obs;
  final RxDouble price = 0.0.obs;
  final RxBool isLoading = false.obs;
  final RxString selectedSeatType = RxString('regular');
  final RxString selectedBedPosition = RxString('');
  final RxList<PriceModel> prices = <PriceModel>[].obs;
  final RxList<String> availableSeatTypes = <String>['regular', 'sleeper'].obs;
  final RxList<String> availableBedPositions = <String>['lower', 'upper'].obs;

  @override
  void onInit() {
    super.onInit();
    // Check if email is already verified
    final storedEmail = _otpService.getVerifiedEmail();
    if (storedEmail != null) {
      verifiedEmail.value = storedEmail;
      if (emailController.text.isNotEmpty && emailController.text == storedEmail) {
        isEmailVerified.value = true;
      }
    }
    
    // Load prices when controller initializes
    loadPricesFromFirestore();
  }

  // Send OTP to the provided email
  Future<bool> sendOTP() async {
    try {
      isSendingOTP.value = true;
      otpError.value = '';
      
      final email = emailController.text.trim();
      if (email.isEmpty) {
        otpError.value = 'Please enter your email first';
        return false;
      }
      
      if (!GetUtils.isEmail(email)) {
        otpError.value = 'Please enter a valid email';
        return false;
      }
      
      // If email is already verified, no need to send OTP again
      if (isEmailVerified.value && verifiedEmail.value == email) {
        return true;
      }
      
      await _otpService.sendOTP(email);
      
      Get.snackbar(
        'OTP Sent', 
        'We have sent an OTP to your email',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      
      return true;
    } catch (e) {
      otpError.value = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      isSendingOTP.value = false;
    }
  }

  // Verify the OTP entered by the user
  Future<bool> verifyOTP() async {
    try {
      isVerifyingOTP.value = true;
      otpError.value = '';
      
      final email = emailController.text.trim();
      final code = otpCode.value.trim();
      
      if (email.isEmpty) {
        otpError.value = 'Email is required';
        return false;
      }
      
      if (code.isEmpty) {
        otpError.value = 'Please enter the OTP';
        return false;
      }
      
      await _otpService.verifyOTP(email, code);
      
      // Mark email as verified
      isEmailVerified.value = true;
      verifiedEmail.value = email;
      
      Get.snackbar(
        'Email Verified', 
        'Your email has been verified successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      
      return true;
    } catch (e) {
      otpError.value = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      isVerifyingOTP.value = false;
    }
  }

  // Load prices from Firestore
  Future<void> loadPricesFromFirestore() async {
    try {
      isLoading.value = true;
      final priceList = await _priceRepo.getAllPrices();
      prices.assignAll(priceList);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load prices',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Other existing methods...
  // [Previous methods like bookTicket, proceedToPayment, etc. can be added here]

  @override
  void onClose() {
    // Dispose controllers
    departureController.dispose();
    arrivalController.dispose();
    dateController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passportController.dispose();
    seatController.dispose();
    priceController.dispose();
    statusController.dispose();
    selectedCitizenshipController.dispose();
    super.onClose();
  }
}
