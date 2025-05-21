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

  // Text Controllers with reactive updates
  late final TextEditingController departureController;
  late final TextEditingController arrivalController;
  late final TextEditingController dateController;
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController passportController;
  late final TextEditingController seatController;
  late final TextEditingController priceController;
  late final TextEditingController statusController;
  late final TextEditingController selectedCitizenshipController;

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

  // Form Key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Citizen and Country Selection
  final RxString selectedCitizenship = 'Ethiopian'.obs;
  final RxString selectedForeignCountry = ''.obs;
  final List<String> foreignCountries = [
    'Djiboutian',
    'Kenyan',
    'Sudanese',
    'Other'
  ];

  // Seat Selection
  final RxString selectedSeatType = 'regular'.obs;
  final RxString selectedBedPosition = 'lower'.obs;
  final Map<String, double> seatPrices = {
    'regular': 0.0,
    'economic_upper': 0.0,
    'economic_lower': 0.0,
    'vip_upper': 0.0,
    'vip_lower': 0.0,
  };

  // Getter for current seat price
  double get currentSeatPrice {
    final seatType = selectedSeatType.value;
    final bedPosition = selectedBedPosition.value;
    final key = seatType == 'regular' ? 'regular' : '${seatType}_$bedPosition';
    return seatPrices[key] ?? 0.0;
  }

  // Get formatted selected date
  String get formattedSelectedDate {
    if (selectedDate.value == null) return '';
    return DateFormat('EEEE, MMMM d, y').format(selectedDate.value!);
  }

  // Navigation
  final RxInt currentPage = 0.obs;
  final int totalPages = 4; // Total number of pages in the form

  // Form validation state
  final RxBool isFormValid = false.obs;

  // Observable variables
  final Rx<String?> selectedDepartureStation = Rx<String?>(null);
  final Rx<String?> selectedArrivalStation = Rx<String?>(null);
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final RxString departureStation = ''.obs;
  final RxString arrivalStation = ''.obs;
  final Rx<DateTime> date = DateTime.now().obs;
  final RxBool isLoading = false.obs;
  final RxList<PriceModel> prices = <PriceModel>[].obs;
  final RxList<String> availableSeatTypes = <String>['regular', 'sleeper'].obs;
  final RxList<String> availableBedPositions = <String>['lower', 'upper'].obs;

  @override
  void onInit() {
    super.onInit();
    
    // Initialize controllers
    departureController = TextEditingController();
    arrivalController = TextEditingController();
    dateController = TextEditingController();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    passportController = TextEditingController();
    seatController = TextEditingController();
    priceController = TextEditingController();
    statusController = TextEditingController();
    selectedCitizenshipController = TextEditingController();
    
    // Add update listeners to all text controllers
    void addUpdateListener(TextEditingController controller) {
      controller.addListener(update);
    }
    
    // Add listeners to form fields for real-time validation
    addUpdateListener(firstNameController);
    addUpdateListener(lastNameController);
    addUpdateListener(phoneController);
    addUpdateListener(passportController);
    addUpdateListener(emailController);
    
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
      prices.assignAll(await priceList.first); // Assuming getAllPrices returns a Future<Stream<List<PriceModel>>>
      updatePricesBasedOnCitizenship();
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

  // Update prices based on citizenship
  void updatePricesBasedOnCitizenship() {
    try {
      final isForeign = selectedCitizenship.value != 'Ethiopian';
      
      // Base prices for Ethiopian citizens
      final Map<String, double> basePrices = {
        'regular': 100.0,
        'economic_upper': 150.0,
        'economic_middle': 150.0,
        'economic_lower': 150.0,
        'vip_upper': 200.0,
        'vip_lower': 200.0,
      };
      
      // Update seat prices based on citizenship
      basePrices.forEach((key, basePrice) {
        if (isForeign) {
          // Apply foreigner pricing (50% more)
          seatPrices[key] = basePrice * 1.5;
        } else {
          seatPrices[key] = basePrice;
        }
      });
      
      update(); // Notify listeners
    } catch (e) {
      print('Error updating prices: $e');
      // Reset to default prices in case of error
      seatPrices.clear();
      seatPrices.addAll({
        'regular': 100.0,
        'economic_upper': 150.0,
        'economic_middle': 150.0,
        'economic_lower': 150.0,
        'vip_upper': 200.0,
        'vip_lower': 200.0,
      });
      update();
    }
  }

  // Navigation methods
  void nextPage() {
    if (currentPage.value < totalPages - 1) {
      currentPage.value++;
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      currentPage.value--;
    } else {
      // If we're on the first page, navigate back to home
      Get.offAllNamed('/home');
    }
  }

  // Seat selection methods
  void setSelectedSeatType(String type) {
    selectedSeatType.value = type;
    // Reset bed position when seat type changes
    selectedBedPosition.value = 'lower';
  }

  void setSelectedBedPosition(String position) {
    selectedBedPosition.value = position;
  }

  // Book ticket
  Future<void> bookTicket() async {
    try {
      if (!formKey.currentState!.validate()) return;
      
      // Check if email is verified if it's provided
      if (emailController.text.isNotEmpty && !isEmailVerified.value) {
        Get.snackbar(
          'Email Not Verified',
          'Please verify your email before booking',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }
      
      isLoading.value = true;
      
      // Generate a random 10-character alphanumeric ticket number
      const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
      
      // Get departure and arrival values from controllers if not set in Rx variables
      final departureValue = selectedDepartureStation.value ?? departureController.text.trim();
      final arrivalValue = selectedArrivalStation.value ?? arrivalController.text.trim();
      
      if (departureValue.isEmpty || arrivalValue.isEmpty) {
        Get.snackbar(
          'Error',
          'Please select departure and arrival stations',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }
      
      // Generate a ticket number
      final ticketNumber = _generateTicketNumber();
      
      // Format seat type and bed position for display
      String formattedSeatType = selectedSeatType.value;
      String formattedBedPosition = selectedBedPosition.value ?? '';
      
      // Update seat type display
      if (selectedSeatType.value == 'vip') {
        formattedSeatType = 'VIP Bed';
      } else if (selectedSeatType.value == 'economic') {
        formattedSeatType = 'Economic Bed';
      } else if (selectedSeatType.value == 'regular') {
        formattedSeatType = 'Regular Seat';
        // Clear bed position for regular seats
        formattedBedPosition = '';
      }
      
      // Create a new ticket with form data
      final ticket = TicketModel(
        id: const Uuid().v4(),
        departure: departureValue,
        arrival: arrivalValue,
        date: selectedDate.value ?? DateTime.now(),
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        passport: passportController.text.trim(),
        seatType: formattedSeatType,
        bedPosition: formattedBedPosition,
        price: currentSeatPrice,
        status: 'confirmed',
        citizenship: selectedCitizenship.value,
        ticket_number: ticketNumber, // Set the generated ticket number
      );
      
      // Debug print to verify the ticket data
      print('Creating ticket with number: $ticketNumber');
      print('Ticket data: ${ticket.toJson()}');
      
      // Save ticket to Firestore
      final ticketId = await _ticketRepo.createTicket(ticket);
      
      if (ticketId.isEmpty) {
        throw Exception('Failed to create ticket');
      }
      
      // Create an updated ticket with the generated ID and ensure all fields are set
      final updatedTicket = ticket.copyWith(
        id: ticketId,
        ticket_number: ticketNumber, // Ensure ticket number is preserved
        departure: selectedDepartureStation.value ?? '',
        arrival: selectedArrivalStation.value ?? '',
      );
      
      // Debug print to verify the values
      print('Updated ticket with ID: $ticketId, number: $ticketNumber');
      print('Departure: ${updatedTicket.departure}, Arrival: ${updatedTicket.arrival}');
      
      // Send confirmation email using the instance
      print('Sending confirmation email to: ${updatedTicket.email}');
      final emailSent = await _emailService.sendTicketEmail(updatedTicket);
      print('Email sent: $emailSent');
      
      // Navigate to ticket view and remove all previous routes to prevent going back to the booking flow
      final ticketView = TicketViewScreen(
        ticket: updatedTicket,
        isNewBooking: true,
      );
      
      if (emailSent) {
        // Navigate to success screen
        Get.offAll(() => ticketView);
      } else {
        // If email fails but ticket is saved, still navigate but show a warning
        Get.snackbar(
          'Ticket Booked', 
          'Your ticket was booked but we couldn\'t send the confirmation email. Please check your email address.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        Get.offAll(() => ticketView);
      }
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to book ticket: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Generate a random 10-character alphanumeric ticket number
  String _generateTicketNumber() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(10, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
    );
  }

  // Clean up resources
  @override
  void onClose() {
    // Remove listeners and dispose controllers
    void removeListener(TextEditingController controller) {
      controller.removeListener(update);
      controller.dispose();
    }
    
    // Remove listeners and dispose all controllers
    removeListener(departureController);
    removeListener(arrivalController);
    removeListener(dateController);
    removeListener(firstNameController);
    removeListener(lastNameController);
    removeListener(emailController);
    removeListener(phoneController);
    removeListener(passportController);
    removeListener(seatController);
    removeListener(priceController);
    removeListener(statusController);
    removeListener(selectedCitizenshipController);
    
    super.onClose();
  }
}
