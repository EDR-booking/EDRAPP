import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/repositories/ticket_repositories.dart';
import '../../../features/price/repositories/price_repository.dart';
import '../../../features/price/models/price_model.dart';
import '../models/ticket_model.dart';
import '../screen/ticket_view_screen.dart';
import '../services/ticket_email_service.dart';

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
  final TextEditingController selectedCitizenshipController =
      TextEditingController();

  // Repositories
  final TicketRepository _ticketRepo = TicketRepository();
  final PriceRepository _priceRepo = PriceRepository();

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

  // These fields are used in the UI
  final RxString selectedSeatType = RxString('regular');
  final RxString selectedBedPosition = RxString('');
  final RxString selectedCitizenship = RxString('Ethiopian');
  final RxString selectedForeignCountry = RxString('');

  final List<String> foreignCountries = [
    'USA',
    'UK',
    'Canada',
    'France',
    'Germany',
    'Italy',
    'Spain',
    'China',
    'Japan',
    'India',
  ];

  // Prices from Firestore
  final RxList<PriceModel> prices = <PriceModel>[].obs;
  final RxMap<String, double> seatPrices = RxMap<String, double>();
  final RxBool pricesLoaded = false.obs;

  // Station list
  final List<String> stations = [
    'Sebeta',
    'Lebu',
    'Bishoftu',
    'Mojo',
    'Adama',
    'Bike',
    'Mieso',
    'Dire Dawa',
  ];
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Getters
  bool get canProceedFromSeatSelection =>
      selectedSeatType.value == 'regular' ||
      ((selectedSeatType.value == 'economic' ||
              selectedSeatType.value == 'vip') &&
          selectedBedPosition.value.isNotEmpty);

  double get currentSeatPrice {
    if (selectedSeatType.value == 'regular') {
      return seatPrices['regular'] ?? 0.0;
    } else if ((selectedSeatType.value == 'economic' ||
            selectedSeatType.value == 'vip') &&
        selectedBedPosition.value.isNotEmpty) {
      final key = '${selectedSeatType.value}_${selectedBedPosition.value}';
      return seatPrices[key] ?? 0.0;
    }
    return 0.0;
  }

  // Getter for formatted selected date
  String get formattedSelectedDate {
    if (selectedDate.value == null) return '';

    // Format: Day of Week, Month Day, Year (e.g., "Monday, January 1, 2023")
    return "${_getDayName(selectedDate.value!.weekday)}, ${_getMonthName(selectedDate.value!.month)} ${selectedDate.value!.day}, ${selectedDate.value!.year}";
  }

  // Helper method to get day name
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  // Helper method to get month name
  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }

  @override
  void onInit() {
    super.onInit();
    print('TicketController initialized');

    // Load verified email from storage and set it in the email controller
    final box = GetStorage();
    final verifiedEmail = box.read('verifiedEmail');
    if (verifiedEmail != null) {
      emailController.text = verifiedEmail;
      print('Loaded verified email: $verifiedEmail');
    } else {
      print('No verified email found in storage');
    }

    loadPricesFromFirestore();
  }

  // Load all prices from Firestore
  void loadPricesFromFirestore() {
    isLoading.value = true;
    _priceRepo.getAllPrices().listen((priceList) {
      prices.value = priceList;
      print('Loaded ${priceList.length} prices from Firestore');
      pricesLoaded.value = true;
      updatePricesBasedOnCitizenship();
      isLoading.value = false;
    }, onError: (error) {
      print('Error loading prices: $error');
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to load prices');
    });
  }

  // Find price for a specific route
  PriceModel? findPriceForRoute(String originName, String destinationName) {
    if (!pricesLoaded.value || prices.isEmpty) {
      return null;
    }

    return prices.firstWhereOrNull(
      (price) => price.originName == originName && price.destinationName == destinationName,
    );
  }

  // Get price value based on ticket type and citizenship
  double getPriceForTicketType(PriceModel? priceModel, String ticketType, String citizenship) {
    if (priceModel == null) {
      return 0.0;
    }

    String currencyCode;
    switch (citizenship) {
      case 'Ethiopian':
        currencyCode = 'ETH';
        break;
      case 'Djiboutian':
        currencyCode = 'DJI';
        break;
      case 'Foreign':
        currencyCode = 'FOR';
        break;
      default:
        currencyCode = 'ETH';
    }

    // Map our ticket types to Firestore's ticket types
    String firestoreTicketType;
    switch (ticketType) {
      case 'regular':
        firestoreTicketType = 'regular';
        break;
      case 'economic_upper':
        firestoreTicketType = 'bedUpper';
        break;
      case 'economic_middle':
        firestoreTicketType = 'bedMiddle';
        break;
      case 'economic_lower':
        firestoreTicketType = 'bedLower';
        break;
      case 'vip_upper':
        firestoreTicketType = 'vipUpper';
        break;
      case 'vip_middle':
        firestoreTicketType = 'vipMiddle';
        break;
      case 'vip_lower':
        firestoreTicketType = 'vipLower';
        break;
      default:
        firestoreTicketType = 'regular';
    }

    return priceModel.getPriceByTypeAndCurrency(firestoreTicketType, currencyCode);
  }

  // Update prices based on citizenship
  void updatePricesBasedOnCitizenship() {
    // Clear current prices
    seatPrices.clear();

    if (!pricesLoaded.value) {
      print('Cannot update prices - prices not loaded from Firestore yet');
      return;
    }

    if (selectedDepartureStation.value == null || selectedArrivalStation.value == null) {
      print('Cannot update prices - departure or arrival station not selected');
      return;
    }

    // Find price for the selected route
    PriceModel? routePrice = findPriceForRoute(
      selectedDepartureStation.value!,
      selectedArrivalStation.value!,
    );

    if (routePrice == null) {
      print('No price found for route ${selectedDepartureStation.value} to ${selectedArrivalStation.value}');
      return;
    }

    print('Found price for route ${routePrice.originName} to ${routePrice.destinationName}');

    // Map of ticket types
    final ticketTypes = {
      'regular': 'regular',
      'economic_upper': 'bedUpper',
      'economic_middle': 'bedMiddle',
      'economic_lower': 'bedLower',
      'vip_upper': 'vipUpper',
      'vip_middle': 'vipMiddle',
      'vip_lower': 'vipLower',
    };

    // Get prices for the current citizenship
    String currencyCode;
    switch (selectedCitizenship.value) {
      case 'Ethiopian':
        currencyCode = 'ETH';
        break;
      case 'Djiboutian':
        currencyCode = 'DJI';
        break;
      case 'Foreign':
        currencyCode = 'FOR';
        break;
      default:
        currencyCode = 'ETH';
    }

    // Calculate and set prices from Firestore data
    ticketTypes.forEach((uiKey, firestoreKey) {
      double price = routePrice.getPriceByTypeAndCurrency(firestoreKey, currencyCode);
      seatPrices[uiKey] = price;
      print('Price for $uiKey ($currencyCode): $price');
    });
  }

  void nextPage() {
    try {
      // First page - Station selection
      if (currentPage.value == 0) {
        if (_validateFirstStep()) {
          print('=== Step 1 Values ===');
          print('Departure Station: ${selectedDepartureStation.value}');
          print('Arrival Station: ${selectedArrivalStation.value}');
          print('Date: ${selectedDate.value}');
          print('Citizenship: ${selectedCitizenship.value}');
          
          // Set values to controllers for other parts of the app
          departureController.text = selectedDepartureStation.value!;
          arrivalController.text = selectedArrivalStation.value!;

          // Update prices based on citizenship before moving to the next page
          updatePricesBasedOnCitizenship();

          // Move to next page
          currentPage.value++;
          
          // Provide feedback
          Get.snackbar(
            'Step Completed',
            'Station and date selection confirmed',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade700,
            colorText: Colors.white,
            duration: Duration(seconds: 2),
          );
        }
      } 
      // Second page - User information
      else if (currentPage.value == 1) {
        if (_validateSecondStep()) {
          print('=== Step 2 Values ===');
          print('First Name: ${firstNameController.text}');
          print('Last Name: ${lastNameController.text}');
          print('Email: ${emailController.text}');
          print('Phone: ${phoneController.text}');
          
          // Move to next page
          currentPage.value++;
          
          // Provide feedback
          Get.snackbar(
            'Step Completed',
            'Personal information saved',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade700,
            colorText: Colors.white,
            duration: Duration(seconds: 2),
          );
        }
      } 
      // Third page - Seat selection
      else if (currentPage.value == 2) {
        if (_validateInputs()) {
          print('=== Step 3 Values ===');
          print('Seat Type: ${selectedSeatType.value}');
          print('Bed Position: ${selectedBedPosition.value}');
          print('Price: ${currentSeatPrice}');
          
          // Move to next page
          currentPage.value++;
          
          // Provide feedback
          Get.snackbar(
            'Step Completed',
            'Seat selection confirmed',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade700,
            colorText: Colors.white,
            duration: Duration(seconds: 2),
          );
        }
      }
    } catch (e) {
      print('Error in nextPage: $e');
      Get.snackbar(
        'Error',
        'An error occurred when trying to proceed. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      currentPage.value--;
    }
  }

  void setSelectedSeatType(String type) {
    selectedSeatType.value = type;
    if (type == 'regular') {
      selectedBedPosition.value = '';
    }
  }

  void setSelectedBedPosition(String position) {
    selectedBedPosition.value = position;
  }

  bool _validateFirstStep() {
    bool isValid = true;
    String errorMsg = '';
    
    // Check if departure station is selected
    if (selectedDepartureStation.value == null) {
      isValid = false;
      errorMsg += 'Please select a departure station\n';
    }
    
    // Check if arrival station is selected
    if (selectedArrivalStation.value == null) {
      isValid = false;
      errorMsg += 'Please select an arrival station\n';
    }
    
    // Check if stations are the same
    if (selectedDepartureStation.value != null && 
        selectedArrivalStation.value != null && 
        selectedDepartureStation.value == selectedArrivalStation.value) {
      isValid = false;
      errorMsg += 'Departure and arrival stations cannot be the same\n';
    }
    
    // Check if date is selected
    if (selectedDate.value == null) {
      isValid = false;
      errorMsg += 'Please select a travel date';
    }
    
    // Debug print
    print('First step validation: $isValid');
    if (!isValid) {
      print('Validation errors: $errorMsg');
    }
    
    // Show error message if validation fails
    if (!isValid) {
      Get.snackbar(
        'Validation Error',
        errorMsg.trim(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
        margin: EdgeInsets.all(10),
      );
    }
    
    return isValid;
  }

  bool _validateSecondStep() {
    bool isValid = true;
    String errorMsg = '';
    
    // Validate first name
    if (firstNameController.text.isEmpty) {
      isValid = false;
      errorMsg += 'First name is required\n';
    }
    
    // Validate last name
    if (lastNameController.text.isEmpty) {
      isValid = false;
      errorMsg += 'Last name is required\n';
    }
    
    // Validate email
    if (emailController.text.isEmpty) {
      isValid = false;
      errorMsg += 'Email is required\n';
    } else if (!GetUtils.isEmail(emailController.text)) {
      isValid = false;
      errorMsg += 'Please enter a valid email address\n';
    }
    
    // Validate phone format - more flexible validation
    if (phoneController.text.isEmpty) {
      isValid = false;
      errorMsg += 'Phone number is required\n';
    } else if (phoneController.text.length < 9) {
      isValid = false;
      errorMsg += 'Phone number is too short\n';
    }
    
    // Validate passport if foreign citizen
    if (selectedCitizenship.value == 'Foreign' && passportController.text.isEmpty) {
      isValid = false;
      errorMsg += 'Passport number is required for foreign citizens';
    }

    // Show error message if validation fails
    if (!isValid) {
      Get.snackbar(
        'Validation Error',
        errorMsg.trim(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
        margin: EdgeInsets.all(10),
      );
    }
    
    return isValid;
  }
  
  bool _validateInputs() {
    bool isValid = true;
    String errorMsg = '';
    
    // Validate seat type selection
    if (selectedSeatType.value.isEmpty) {
      isValid = false;
      errorMsg += 'Please select a seat type\n';
    }

    // If economic or VIP is selected, validate bed position
    if ((selectedSeatType.value == 'economic' || selectedSeatType.value == 'vip') &&
        selectedBedPosition.value.isEmpty) {
      isValid = false;
      errorMsg += 'Please select a bed position';
    }

    // Show error message if validation fails
    if (!isValid) {
      Get.snackbar(
        'Validation Error',
        errorMsg.trim(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
        margin: EdgeInsets.all(10),
      );
    }

    return isValid;
  }
  
  void _resetForm() {
    selectedDepartureStation.value = null;
    selectedArrivalStation.value = null;
    selectedDate.value = null;
    selectedCitizenship.value = 'Ethiopian';
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    phoneController.clear();
    passportController.clear();
    selectedSeatType.value = 'regular';
    selectedBedPosition.value = '';
    currentPage.value = 0;
  }

  Future<void> bookTicket() async {
    try {
      // Validate all inputs
      if (!_validateInputs()) {
        return;
      }

      isLoading.value = true;
      print('Creating ticket...');

      // Create the ticket and automatically confirm it
      final ticket = await _createTicket();

      if (ticket == null) {
        print('Failed to create ticket');
        isLoading.value = false;

        Get.snackbar(
          'Error',
          'Failed to create ticket. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      print('Ticket created successfully: ${ticket.id}');
      
      // IMPORTANT: Move ticket generation BEFORE showing success message or resetting form
      print('Starting ticket display and email process...');
      
      // Use Future.delayed to ensure UI has time to respond before continuing
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Generate ticket and display it
      await _generateAndShowTicket(ticket);
      
      print('Ticket display and email process completed');
      
      isLoading.value = false;
      
      // Show success message
      Get.snackbar(
        'Success',
        'Your ticket has been booked successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      
      // Delay before resetting the form
      await Future.delayed(const Duration(seconds: 1));
      
      // Reset the form
      _resetForm();
      
    } catch (e) {
      print('BOOKING ERROR: $e');
      isLoading.value = false;

      // Show error message
      Get.snackbar(
        'Error',
        'Failed to book ticket: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<TicketModel?> _createTicket() async {
    try {
      // Create ticket model with confirmed status directly
      final TicketModel ticket = TicketModel(
        departure: selectedDepartureStation.value!,
        arrival: selectedArrivalStation.value!,
        date: selectedDate.value!,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        passport: passportController.text.trim(),
        seatType: selectedSeatType.value,
        bedPosition: selectedBedPosition.value,
        price: currentSeatPrice,
        status: 'confirmed', // Mark as confirmed immediately
        citizenship: selectedCitizenship.value,
        createdAt: DateTime.now(),
      );

      // Save to Firestore - this returns a document ID string
      final String ticketId = await _ticketRepo.createTicket(ticket);
      
      // Create a TicketModel with the ID included
      final updatedTicket = ticket.copyWith(id: ticketId);
      
      print('Ticket created and confirmed with ID: $ticketId');

      return updatedTicket;
    } catch (e) {
      print('Failed to create ticket: $e');
      return null;
    }
  }
  
  // Payment and confirmation methods removed since tickets are confirmed on creation

  // Generate ticket and show it to the user
  Future<void> _generateAndShowTicket(TicketModel ticket) async {
    try {
      print('STEP 1: Starting ticket display');
      
      // Show the ticket in the ticket view screen
      await Get.to(() => TicketViewScreen(ticket: ticket));
      
      print('STEP 2: Ticket displayed successfully');
      
      // Send the ticket via email if email is provided
      if (ticket.email.isNotEmpty) {
        print('STEP 3: Email provided, preparing to send email');
        print('EMAIL INFO - Email address: ${ticket.email}');
        print('EMAIL INFO - Ticket ID: ${ticket.id}');
        print('EMAIL INFO - User: ${ticket.firstName} ${ticket.lastName}');
        
        // This will execute outside the normal flow as a separate process
        Future(() async {
          try {
            print('STEP 4: Starting email service');
            
            Get.snackbar(
              'Sending Email',
              'Sending your ticket to ${ticket.email}...',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.blue,
              colorText: Colors.white,
              duration: const Duration(seconds: 10),
            );
            
            // Force delay to ensure snackbar is shown
            await Future.delayed(const Duration(seconds: 1));
            
            // Use the TicketEmailService to send the email
            print('STEP 5: Calling TicketEmailService.sendTicketEmail');
            final emailSent = await TicketEmailService.sendTicketEmail(ticket);
            
            if (emailSent) {
              print('STEP 6: Email sent successfully');
              Get.snackbar(
                'Email Sent',
                'Your ticket has been sent to ${ticket.email}',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
                duration: const Duration(seconds: 5),
              );
            } else {
              print('STEP 6: Email sending failed');
              Get.snackbar(
                'Email Not Sent',
                'Failed to send ticket. Please try again.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
                duration: const Duration(seconds: 5),
              );
            }
          } catch (emailError) {
            print('EMAIL ERROR: $emailError');
            Get.snackbar(
              'Email Error',
              'Error: $emailError',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
              duration: const Duration(seconds: 8),
            );
          }
        });
        
        // Continue with main flow
        print('STEP 7: Continuing with main app flow');
        
      } else {
        print('DEBUG: No email provided for ticket ${ticket.id}');
      }
    } catch (e) {
      print('MAIN ERROR in _generateAndShowTicket: $e');
      Get.snackbar(
        'Error',
        'Failed to generate ticket: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  // Fetch a ticket by ID - uses TicketRepository from class property
  Future<TicketModel?> getTicketById(String ticketId) async {
    try {
      return await _ticketRepo.getTicket(ticketId);
    } catch (e) {
      print('Error fetching ticket: $e');
      return null;
    }
  }
  
  // Get all tickets for the current user
  Future<List<TicketModel>> getUserTickets(String email) async {
    try {
      // Get the stream and wait for the first value
      final ticketsStream = _ticketRepo.getTicketsByEmail(email);
      final tickets = await ticketsStream.first;
      return tickets;
    } catch (e) {
      print('Error fetching user tickets: $e');
      return [];
    }
  }

  @override
  void onClose() {
    // Dispose of all the controllers
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
