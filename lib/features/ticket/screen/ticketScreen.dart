import 'package:flutter/material.dart';
import 'package:flutter_application_2/custome_shape/container/primary_header_container.dart';
import 'package:flutter_application_2/features/ticket/controllers/ticketController.dart';
import 'package:flutter_application_2/features/ticket/screen/widgets/CustomDropdown.dart';
// Removed unused import
import 'package:get/get.dart';
import 'widgets/CustomRadioGroup.dart';

class TicketScreen extends StatefulWidget {
  final String selectedCitizenship;

  const TicketScreen({super.key, required this.selectedCitizenship});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  // Initialize controller before usage
  final TicketController controller = Get.put(TicketController());
  
  // Initialize _selected with a default value
  late String _selected = 'regular';
  String? selectedItem;
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

  @override
  void initState() {
    super.initState();
    controller.selectedCitizenship.value = widget.selectedCitizenship;
    controller.updatePricesBasedOnCitizenship();
  }

  // Show OTP verification dialog
  Future<void> _showOTPDialog() async {
    final controller = Get.find<TicketController>();
    
    // Create a local controller for the OTP input
    final otpController = TextEditingController();
    bool isDialogOpen = true;
    
    // Clear any previous OTP errors
    controller.otpError.value = '';
    
    // Helper function to safely update the dialog state
    void safeDialogUpdate(VoidCallback fn) {
      if (isDialogOpen && mounted) {
        if (fn != null) fn();
      }
    }
    
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              void updateState() {
                if (isDialogOpen && mounted) {
                  setDialogState(() {});
                }
              }
              
              return GetBuilder<TicketController>(
                builder: (controller) {
                  return WillPopScope(
                    onWillPop: () async {
                      // Prevent dialog from being dismissed while verifying
                      return !controller.isVerifyingOTP.value;
                    },
                    child: AlertDialog(
                      title: const Text('Verify Your Email'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('We have sent an OTP to ${controller.emailController.text}. Please enter it below:'),
                            const SizedBox(height: 16),
                            TextField(
                              controller: otpController,
                              onChanged: (value) {
                                // Update the OTP code in the controller
                                controller.otpCode.value = value;
                                // Clear any previous errors when typing
                                if (controller.otpError.isNotEmpty) {
                                  controller.otpError.value = '';
                                }
                                // Update the UI
                                updateState();
                              },
                              decoration: InputDecoration(
                                labelText: 'Enter OTP',
                                errorText: controller.otpError.isEmpty ? null : controller.otpError.value,
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: controller.isVerifyingOTP.value
                              ? null
                              : () {
                                  // Clear the OTP code and error
                                  otpController.clear();
                                  controller.otpCode.value = '';
                                  controller.otpError.value = '';
                                  if (mounted) {
                                    Navigator.of(context).pop();
                                  }
                                },
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: (controller.isVerifyingOTP.value || otpController.text.trim().isEmpty)
                              ? null
                              : () async {
                                  // Show loading state
                                  controller.isVerifyingOTP.value = true;
                                  updateState();
                                  
                                  try {
                                    final verified = await controller.verifyOTP();
                                    
                                    if (!isDialogOpen) return;
                                    
                                    if (verified) {
                                      // Clear the OTP field and close the dialog
                                      otpController.clear();
                                      if (mounted) {
                                        Navigator.of(context).pop(true);
                                        // Show success message
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Email verified successfully!'),
                                            backgroundColor: Colors.green,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                      return;
                                    }
                                    
                                    // If we get here, verification failed
                                    if (isDialogOpen && mounted) {
                                      updateState();
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Error: ${e.toString()}'),
                                          backgroundColor: Colors.red,
                                          duration: const Duration(seconds: 3),
                                        ),
                                      );
                                    }
                                  } finally {
                                    if (isDialogOpen) {
                                      controller.isVerifyingOTP.value = false;
                                      if (mounted) {
                                        updateState();
                                      }
                                    }
                                  }
                                },
                          child: controller.isVerifyingOTP.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('Verify'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      );
    } catch (e) {
      debugPrint('Error in OTP dialog: $e');
    } finally {
      // Mark dialog as closed before any async operations
      isDialogOpen = false;
      
      // Use a post-frame callback to ensure safe disposal
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          otpController.dispose();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF5F7FA),
      // No app bar for cleaner fullscreen experience
      body: Column(
        children: [
          TPrimaryHeaderContainer(
            child: Stack(
              children: [
                // Background design elements
                Positioned(
                  right: -20,
                  top: -30,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  left: -50,
                  bottom: -20,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.train_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "ETHIO-DJIBOUTI RAILWAY",
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.2),
                              Colors.white.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.confirmation_number_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "TICKET BOOKING",
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, -5),
                    ),
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      isDark ? Colors.grey.shade900 : Colors.white,
                      isDark ? Colors.grey.shade800 : const Color(0xFFF8FAFF),
                    ],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).padding.bottom + 80),
                  child: Obx(
                    () => Column(
                      children: [
                        _buildProgressBar(controller.currentPage.value),
                        const SizedBox(height: 24),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.05, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: _getPageWidget(controller.currentPage.value),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Departure and Arrival Station Form with enhanced design
  Widget buildStationSelectionForm() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Journey illustration
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800.withOpacity(0.5) : Colors.blue.shade50.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.blue.shade100),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.directions_train_rounded,
                  color: Theme.of(context).primaryColor,
                  size: 36,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plan Your Journey'.tr,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Select Stations Below'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Departure Station
          Text(
            'from'.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 8.0),
          Obx(
            () => CustomDropdown(
              items: stations,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: controller.selectedDepartureStation.value == controller.selectedArrivalStation.value &&
                          controller.selectedDepartureStation.value != null
                      ? Colors.red.shade300
                      : isDark ? Colors.grey.shade600 : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
                color: isDark ? Colors.grey.shade800 : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              hintText: 'select_departure_station'.tr,
              label: '',
              onChanged: (value) {
                controller.selectedDepartureStation.value = value;
                
                // Reset date when changing stations
                if (controller.selectedArrivalStation.value != null) {
                  // Clear any previously selected date
                  controller.selectedDate.value = null;
                  controller.dateController.text = '';
                }
              },
              prefixIcon: Icons.departure_board_rounded,
              accentColor: Theme.of(context).primaryColor,
              errorText:
                  controller.selectedDepartureStation.value ==
                              controller.selectedArrivalStation.value &&
                          controller.selectedDepartureStation.value != null
                      ? 'stations_cannot_be_same'.tr
                      : null,
            ),
          ),
          
          // Simple spacer instead of journey direction indicator
          SizedBox(height: 16),
          
          // Arrival Station
          Text(
            'to'.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 8.0),
          Obx(
            () => CustomDropdown(
              items: stations,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: controller.selectedDepartureStation.value == controller.selectedArrivalStation.value &&
                          controller.selectedArrivalStation.value != null
                      ? Colors.red.shade300
                      : isDark ? Colors.grey.shade600 : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
                color: isDark ? Colors.grey.shade800 : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              hintText: 'select_arrival_station'.tr,
              label: '',
              onChanged: (value) {
                controller.selectedArrivalStation.value = value;
                
                // Reset date when changing stations
                if (controller.selectedDepartureStation.value != null) {
                  // Clear any previously selected date
                  controller.selectedDate.value = null;
                  controller.dateController.text = '';
                }
              },
              prefixIcon: Icons.location_on_rounded,
              accentColor: Theme.of(context).primaryColor,
              errorText:
                  controller.selectedDepartureStation.value ==
                              controller.selectedArrivalStation.value &&
                          controller.selectedArrivalStation.value != null
                      ? 'stations_cannot_be_same'.tr
                      : null,
            ),
          ),
          const SizedBox(height: 24.0),

          // Date Selection Header
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  color: Theme.of(context).primaryColor,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Travel Date'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          
          // Date Selection Container
          Column(
            children: [
              GestureDetector(
                onTap: () async {
                  // Check if stations are selected first
                  String? departure = controller.selectedDepartureStation.value;
                  String? arrival = controller.selectedArrivalStation.value;
                  
                  if (departure == null || arrival == null) {
                    Get.snackbar(
                      'Station Selection Required',
                      'Please select departure and arrival stations first',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.red.withOpacity(0.8),
                      colorText: Colors.white,
                      duration: Duration(seconds: 3),
                    );
                    return;
                  }
                  
                  // Check if the same station is selected for both departure and arrival
                  if (departure == arrival) {
                    Get.snackbar(
                      'Invalid Selection',
                      'Departure and arrival stations cannot be the same',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.red.withOpacity(0.8),
                      colorText: Colors.white,
                      duration: Duration(seconds: 3),
                    );
                    return;
                  }
                  
                  int departureIndex = stations.indexOf(departure);
                  int arrivalIndex = stations.indexOf(arrival);
                  
                  // Determine initial date based on direction
                  DateTime initialDate = DateTime.now();
                  
                  // Make sure initialDate is valid for the current direction
                  // For downward trains (earlier station to later station)
                  if (departureIndex < arrivalIndex) {
                    // Find the next even day from today
                    while (initialDate.day % 2 != 0) {
                      initialDate = initialDate.add(const Duration(days: 1));
                    }
                  } 
                  // For upward trains (later station to earlier station)
                  else {
                    // Find the next odd day from today
                    while (initialDate.day % 2 != 1) {
                      initialDate = initialDate.add(const Duration(days: 1));
                    }
                  }
                  
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: initialDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: Theme.of(context).primaryColor,
                            onPrimary: Colors.white,
                            surface: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.grey[800]! 
                                : Colors.white,
                            onSurface: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.white 
                                : Colors.black87,
                          ),
                          dialogBackgroundColor: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.grey[900] 
                              : Colors.white,
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.white 
                                : Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                    selectableDayPredicate: (DateTime date) {
                      // Check direction based on station order
                      
                      // For downward trains (Sebeta to Dire Dawa)
                      if (departureIndex < arrivalIndex) {
                        // Only allow even-numbered days
                        return date.day % 2 == 0; // Even days (2, 4, 6, etc.)
                      } 
                      // For upward trains (Dire Dawa to Sebeta)
                      else {
                        // Only allow odd-numbered days
                        return date.day % 2 == 1; // Odd days (1, 3, 5, etc.)
                      }
                    },
                  );
                  
                  if (picked != null) {
                    controller.selectedDate.value = picked;
                    // Update the text controller to display the selected date
                    controller.dateController.text = controller.formattedSelectedDate;
                    
                    // Provide visual feedback that the date was successfully selected
                    Get.snackbar(
                      'Date Selected',
                      'Travel date selected: ${controller.formattedSelectedDate}',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green.withOpacity(0.8),
                      colorText: Colors.white,
                      duration: Duration(seconds: 2),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.grey.shade600 : const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                    color: isDark ? Colors.grey.shade800 : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.calendar_month_rounded,
                              color: Theme.of(context).primaryColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: Obx(() => Text(
                              controller.selectedDate.value == null
                                  ? 'Tap To Select Date'.tr
                                  : controller.formattedSelectedDate,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: controller.selectedDate.value == null
                                    ? FontWeight.normal 
                                    : FontWeight.bold,
                                color: controller.selectedDate.value == null
                                    ? (isDark ? Colors.grey.shade400 : Colors.grey.shade600)
                                    : (isDark ? Colors.white : Colors.black87),
                              ),
                            )),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                            size: 16,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      Obx(() {
                        // Show route-specific schedule information
                        String? departure = controller.selectedDepartureStation.value;
                        String? arrival = controller.selectedArrivalStation.value;
                        
                        int departureIndex = departure != null ? stations.indexOf(departure) : -1;
                        int arrivalIndex = arrival != null ? stations.indexOf(arrival) : -1;
                        
                        // Check if valid indices and different stations
                        if (departureIndex != -1 && arrivalIndex != -1 && departureIndex != arrivalIndex) {
                          // Forward direction (Sebeta -> Dire Dawa)
                          if (departureIndex < arrivalIndex) {
                            return Text(
                              'Forward Direction Days'.tr,
                              style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                            );
                          } 
                          // Backward direction (Dire Dawa -> Sebeta)
                          else {
                            return Text(
                              'Backward Direction Days'.tr,
                              style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                            );
                          }
                        } else if (departure != null && arrival != null) {
                          return Text(
                            'Select Valid Stations'.tr,
                            style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              const SizedBox(height: 8.0),
            ],
          ),

          const SizedBox(height: 16.0),

          Obx(
            () => CustomRadioGroup(
              title: 'Nationality'.tr,
              groupValue: controller.selectedCitizenship.value,
              options: const ['Ethiopian', 'Foreign', 'Djiboutian'],
              isEnabled: false,
              accentColor: Theme.of(context).primaryColor,
              foreignCountries: controller.foreignCountries,
              selectedForeignCountry: controller.selectedForeignCountry.value,
              onChanged: (value) {
                controller.selectedCitizenship.value = value ?? 'Ethiopian';
                if (controller.selectedCitizenship.value != 'Foreign') {
                  controller.selectedForeignCountry.value = '';
                }
              },
              onForeignCountryChanged: (value) {
                if (value != null) {
                  controller.selectedForeignCountry.value = value;
                }
              },
            ),
          ),

          const SizedBox(height: 16.0),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed:
                    controller.isLoading.value ? null : controller.previousPage,
                child: Text(
                  "Back",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color:
                        controller.isLoading.value ? Colors.grey : Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black,
                  ),
                ),
              ),

              Obx(() {
                final isFormValid = _isFormValid(controller, controller.currentPage.value);
                return ElevatedButton(
                  onPressed: controller.isLoading.value || !isFormValid
                      ? null 
                      : controller.nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFormValid && !controller.isLoading.value
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade400,
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Next",
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(color: Colors.white),
                        ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  // User Information Form with modern design
  Widget buildUserInformation() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Personal Information Header
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800.withOpacity(0.5) : Colors.blue.shade50.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.blue.shade100),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person_rounded,
                  color: Theme.of(context).primaryColor,
                  size: 36,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Traveler Details'.tr,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Provide Personal Information'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Name Fields in a Row to save space
          Row(
            children: [
              // First Name Field
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "First Name".tr,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    GetBuilder<TicketController>(
                      builder: (controller) => TextFormField(
                        controller: controller.firstNameController,
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: InputDecoration(
                          labelText: 'First Name',
                          labelStyle: Theme.of(context).textTheme.labelMedium,
                          hintText: 'Enter your first name',
                          hintStyle: Theme.of(context).textTheme.labelMedium!.copyWith(
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 1.5,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: isDark ? Colors.white70 : Theme.of(context).primaryColor.withOpacity(0.7),
                            size: 20,
                          ),
                          filled: true,
                          fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your first name';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12.0),
              // Last Name Field
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Last Name".tr,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    GetBuilder<TicketController>(
                      builder: (controller) => TextFormField(
                        controller: controller.lastNameController,
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: InputDecoration(
                          labelText: 'Last Name',
                          labelStyle: Theme.of(context).textTheme.labelMedium,
                          hintText: 'Enter your last name',
                          hintStyle: Theme.of(context).textTheme.labelMedium!.copyWith(
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 1.5,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: isDark ? Colors.white70 : Theme.of(context).primaryColor.withOpacity(0.7),
                            size: 20,
                          ),
                          filled: true,
                          fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your last name';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16.0),
          
          // Contact Information
          Container(
            margin: const EdgeInsets.only(bottom: 12, top: 4),
            child: Text(
              "Contact Information".tr,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          
          // Email Field with Verification
          Obx(() {
            final isVerified = controller.isEmailVerified.value;
            final email = controller.emailController.text.trim().trim();
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800.withOpacity(0.7) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isVerified 
                      ? Colors.green.withOpacity(0.5)
                      : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Email Input with Verify Button
                  Row(
                    children: [
                      Expanded(
                        child: GetBuilder<TicketController>(
                          builder: (controller) => TextFormField(
                            controller: controller.emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: Theme.of(context).textTheme.bodyMedium,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: Theme.of(context).textTheme.labelMedium,
                              hintText: 'Enter your email',
                              hintStyle: Theme.of(context).textTheme.labelMedium!.copyWith(
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 1.5,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: isDark ? Colors.white70 : Theme.of(context).primaryColor.withOpacity(0.7),
                                size: 20,
                              ),
                              suffixIcon: controller.emailController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(
                                        controller.isEmailVerified.value
                                            ? Icons.verified
                                            : Icons.verified_outlined,
                                        color: controller.isEmailVerified.value
                                            ? Colors.green
                                            : (isDark ? Colors.white54 : Colors.black54),
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        if (controller.emailController.text.isNotEmpty) {
                                          _showOTPDialog();
                                        }
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                            ),
                            onChanged: (value) {
                              // Reset verification status if email changes
                              if (controller.verifiedEmail.value != value) {
                                controller.isEmailVerified.value = false;
                              }
                            },
                            validator: (value) {
                              if (value != null && value.isNotEmpty && !GetUtils.isEmail(value)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      if (email.isNotEmpty && !isVerified)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Obx(() => controller.isSendingOTP.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : TextButton(
                                  onPressed: () async {
                                    final success = await controller.sendOTP();
                                    if (success) {
                                      _showOTPDialog();
                                    } else {
                                      // Show error message if OTP sending fails
                                      Get.snackbar(
                                        'Error',
                                        'Failed to send OTP. Please try again.',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                      );
                                    }
                                  },
                                  child: Text(
                                    'Verify',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    minimumSize: const Size(80, 36),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(
                                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                          ),
                        ),
                    ],
                  ),
                  
                  // Verification Status
                  if (email.isNotEmpty && isVerified)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Email verified',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (controller.otpError.value.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        controller.otpError.value,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
      );}),
          
          // Phone Number Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Phone Number".tr,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 6.0),
              GetBuilder<TicketController>(
                builder: (controller) => TextFormField(
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: Theme.of(context).textTheme.labelMedium,
                    hintText: 'Enter your phone number',
                    hintStyle: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 1.5,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.phone_rounded,
                      color: isDark ? Colors.white70 : Theme.of(context).primaryColor.withOpacity(0.7),
                      size: 20,
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          
          // Passport field - only for Foreign and Djiboutian travelers
          Obx(() => controller.selectedCitizenship.value == 'Foreign' || controller.selectedCitizenship.value == 'Djiboutian' ? 
            Container(
              margin: const EdgeInsets.only(top: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Passport Number
                  Text(
                    "Passport Number".tr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  GetBuilder<TicketController>(
                    builder: (controller) => TextFormField(
                      controller: controller.passportController,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: InputDecoration(
                        labelText: 'Passport Number'.tr,
                        labelStyle: Theme.of(context).textTheme.labelMedium,
                        hintText: 'Enter your passport number',
                        hintStyle: Theme.of(context).textTheme.labelMedium!.copyWith(
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 1.5,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.credit_card,
                          color: isDark ? Colors.white70 : Theme.of(context).primaryColor.withOpacity(0.7),
                          size: 20,
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your passport number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ) : const SizedBox.shrink()),
          
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed:
                    controller.isLoading.value ? null : controller.previousPage,
                child: Text(
                  "Back",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color:
                        controller.isLoading.value ? Colors.grey : Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black,
                  ),
                ),
              ),

              // Use GetBuilder to react to controller updates
              GetBuilder<TicketController>(
                builder: (controller) {
                  // Check if email is verified (if email is provided)
                  final email = controller.emailController.text.trim();
                  final isEmailValid = email.isEmpty || 
                      (controller.isEmailVerified.value && 
                       controller.verifiedEmail.value == email);
                  
                  // Check all required fields
                  final isFormValid = 
                      controller.firstNameController.text.trim().isNotEmpty &&
                      controller.lastNameController.text.trim().isNotEmpty &&
                      controller.phoneController.text.trim().isNotEmpty &&
                      (controller.selectedCitizenship.value != 'Ethiopian' 
                          ? controller.passportController.text.trim().isNotEmpty 
                          : true) &&
                      isEmailValid;
                  
                  // Log for debugging
                  debugPrint('Form validation - '
                      'First: ${controller.firstNameController.text.isNotEmpty}, '
                      'Last: ${controller.lastNameController.text.isNotEmpty}, '
                      'Phone: ${controller.phoneController.text.isNotEmpty}, '
                      'Passport: ${controller.passportController.text.isNotEmpty}, '
                      'Email: $isEmailValid, '
                      'Form valid: $isFormValid');
                  
                  return ElevatedButton(
                    onPressed: controller.isLoading.value || !isFormValid
                        ? null
                        : controller.nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFormValid && !controller.isLoading.value
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      elevation: 2,
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 2,
                          ),
                        )
                      : const Text(
                            "Next",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget seatSelection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<TicketController>();

    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seat Selection Header with Icon
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800.withOpacity(0.5) : Colors.blue.shade50.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.blue.shade100),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.airline_seat_recline_extra_rounded,
                  color: Theme.of(context).primaryColor,
                  size: 36,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Your Seat'.tr,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Choose Seat Type And Position'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Seat Type Selection Cards
          Text(
            "Seat Type".tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          
          // Modern Card Layout for Seat Types
          Obx(() => Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                // Regular Seat Option
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.setSelectedSeatType('regular'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade800 : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: controller.selectedSeatType.value == 'regular'
                              ? Theme.of(context).primaryColor
                              : isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                          width: controller.selectedSeatType.value == 'regular' ? 2 : 1,
                        ),
                        boxShadow: controller.selectedSeatType.value == 'regular' ? [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ] : null,
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: controller.selectedSeatType.value == 'regular'
                                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                                  : isDark ? Colors.grey.shade700.withOpacity(0.3) : Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.airline_seat_recline_normal_rounded,
                              color: controller.selectedSeatType.value == 'regular'
                                  ? Theme.of(context).primaryColor
                                  : isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Regular Seat".tr,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: controller.selectedSeatType.value == 'regular'
                                  ? Theme.of(context).primaryColor
                                  : isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "ETB ${controller.seatPrices['regular']!.toStringAsFixed(0)}",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: controller.selectedSeatType.value == 'regular' ? FontWeight.w600 : FontWeight.normal,
                              color: controller.selectedSeatType.value == 'regular'
                                  ? Theme.of(context).primaryColor
                                  : isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Economic Bed Option
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.setSelectedSeatType('economic'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade800 : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: controller.selectedSeatType.value == 'economic'
                              ? Theme.of(context).primaryColor
                              : isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                          width: controller.selectedSeatType.value == 'economic' ? 2 : 1,
                        ),
                        boxShadow: controller.selectedSeatType.value == 'economic' ? [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ] : null,
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: controller.selectedSeatType.value == 'economic'
                                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                                  : isDark ? Colors.grey.shade700.withOpacity(0.3) : Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.hotel_rounded,
                              color: controller.selectedSeatType.value == 'economic'
                                  ? Theme.of(context).primaryColor
                                  : isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Economic Bed".tr,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: controller.selectedSeatType.value == 'economic'
                                  ? Theme.of(context).primaryColor
                                  : isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "ETB ${controller.seatPrices['economic_upper']!.toStringAsFixed(0)}+",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: controller.selectedSeatType.value == 'economic' ? FontWeight.w600 : FontWeight.normal,
                              color: controller.selectedSeatType.value == 'economic'
                                  ? Theme.of(context).primaryColor
                                  : isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // VIP Bed Option
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.setSelectedSeatType('vip'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade800 : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: controller.selectedSeatType.value == 'vip'
                              ? Theme.of(context).primaryColor
                              : isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                          width: controller.selectedSeatType.value == 'vip' ? 2 : 1,
                        ),
                        boxShadow: controller.selectedSeatType.value == 'vip' ? [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ] : null,
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: controller.selectedSeatType.value == 'vip'
                                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                                  : isDark ? Colors.grey.shade700.withOpacity(0.3) : Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.star_rounded,
                              color: controller.selectedSeatType.value == 'vip'
                                  ? Theme.of(context).primaryColor
                                  : isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "VIP Bed".tr,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: controller.selectedSeatType.value == 'vip'
                                  ? Theme.of(context).primaryColor
                                  : isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "ETB ${controller.seatPrices['vip_upper']!.toStringAsFixed(0)}+",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: controller.selectedSeatType.value == 'vip' ? FontWeight.w600 : FontWeight.normal,
                              color: controller.selectedSeatType.value == 'vip'
                                  ? Theme.of(context).primaryColor
                                  : isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),

          // Bed Position Selection for Economic and VIP
          Obx(() {
            if (controller.selectedSeatType.value == 'economic') {
              return _buildBedPositionSelection(controller, "Economic", [
                "upper",
                "middle",
                "lower",
              ]);
            } else if (controller.selectedSeatType.value == 'vip') {
              return _buildBedPositionSelection(controller, "VIP", [
                "upper",
                "lower",
              ]);
            }
            return const SizedBox.shrink();
          }),

          const SizedBox(height: 24),
          // Price Display with enhanced design
          const SizedBox(height: 32),
          Obx(
            () => Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.grey.shade800.withOpacity(0.7) 
                    : Theme.of(context).primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark 
                      ? Colors.grey.shade700 
                      : Theme.of(context).primaryColor.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  // Price summary header
                  Row(
                    children: [
                      Icon(
                        Icons.receipt_long_rounded,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Price Summary'.tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Seat type row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Seat Type'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        controller.selectedSeatType.value == 'regular'
                            ? 'Regular Seat'.tr
                            : controller.selectedSeatType.value == 'economic'
                                ? 'Economic Bed'.tr
                                : 'VIP Bed'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Position row (only for beds)
                  if (controller.selectedSeatType.value != 'regular')
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Position'.tr,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                              ),
                            ),
                            Text(
                              controller.selectedBedPosition.value.isEmpty
                                  ? 'Not Selected'.tr
                                  : '${controller.selectedBedPosition.value.substring(0, 1).toUpperCase()}${controller.selectedBedPosition.value.substring(1)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  
                  // Divider
                  Divider(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    height: 24,
                  ),
                  
                  // Total price row with larger text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Price'.tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        'ETB ${controller.currentSeatPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
          
          // Enhanced navigation buttons with modern design
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
                children: [
                  // Back button with improved styling
                  Expanded(
                    flex: 1,
                    child: ElevatedButton.icon(
                      onPressed: controller.isLoading.value ? null : controller.previousPage,
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        size: 18,
                        color: controller.isLoading.value 
                            ? Colors.grey.shade400 
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                      label: Text(
                        'Back'.tr,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: controller.isLoading.value 
                              ? Colors.grey.shade400 
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
                        foregroundColor: isDark ? Colors.white : Colors.black87,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Book Ticket button with improved styling
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value ? null : controller.bookTicket,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        elevation: controller.isLoading.value ? 0 : 2,
                        shadowColor: Theme.of(context).primaryColor.withOpacity(0.4),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ).copyWith(
                        overlayColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed)) {
                              return Theme.of(context).primaryColor.withOpacity(0.8);
                            }
                            return null;
                          },
                        ),
                      ),
                      child: controller.isLoading.value
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 2,
                                  backgroundColor: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Processing'.tr,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Book Ticket'.tr,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.confirmation_number_rounded, size: 18),
                            ],
                          ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _getPageWidget(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return buildStationSelectionForm();
      case 1:
        return buildUserInformation();
      case 2:
        return seatSelection();
      case 3:
        return buildBookingConfirmation();
      default:
        return const Center(child: Text('Invalid page'));
    }
  }
  
  // Final booking confirmation page with ticket summary and QR code
  Widget buildBookingConfirmation() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Generate a unique ticket ID for QR code
    final String ticketId = "ETH-${DateTime.now().millisecondsSinceEpoch.toString().substring(5, 13)}";
    
    return Column(  
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Modern ticket header with animation
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withBlue(255),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.confirmation_number_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'E Ticket'.tr.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Booking Confirmed'.tr,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Paid'.tr,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // QR Code section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Placeholder for QR code - in a real app, you would generate a real QR code
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.qr_code_2_rounded,
                              size: 100,
                              color: Colors.black87,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              ticketId,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                letterSpacing: 1,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Scan For Verification'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Journey details card
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Journey header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade50,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  border: Border(bottom: BorderSide(color: isDark ? Colors.grey.shade600 : Colors.grey.shade200)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade800 : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.train_rounded,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Journey Details'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.withOpacity(0.3)),
                      ),
                      child: Text(
                        'Unused'.tr,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Journey details content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Stations with modern design
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade700.withOpacity(0.3) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          // From station
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.trip_origin,
                                  size: 16,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'From'.tr,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Obx(() => Text(
                                    controller.selectedDepartureStation.value ?? 'Not Selected'.tr,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  )),
                                ],
                              ),
                            ],
                          ),
                          
                          // Connection line
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: SizedBox(
                              height: 30,
                              child: VerticalDivider(
                                color: Theme.of(context).primaryColor.withOpacity(0.3),
                                thickness: 1,
                                width: 1,
                              ),
                            ),
                          ),
                          
                          // To station
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.place,
                                  size: 16,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'To'.tr,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Obx(() => Text(
                                    controller.selectedArrivalStation.value ?? 'Not Selected'.tr,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  )),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Date and time with modern design
                    Row(
                      children: [
                        // Date card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey.shade700.withOpacity(0.3) : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.grey.shade800 : Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Date'.tr,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Obx(() => Text(
                                        controller.selectedDate.value != null
                                            ? "${controller.selectedDate.value!.day}/${controller.selectedDate.value!.month}/${controller.selectedDate.value!.year}"
                                            : 'Not Selected'.tr,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                      )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Time card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey.shade700.withOpacity(0.3) : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.grey.shade800 : Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Time'.tr,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '08:00 AM', // Example time
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Passenger details with modern design
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade700.withOpacity(0.3) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.grey.shade800 : Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: 16,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Passenger Details'.tr,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Name
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Name'.tr,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Obx(() => Text(
                                      "${controller.firstNameController.text} ${controller.lastNameController.text}",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                              // Citizenship
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Citizenship'.tr,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Obx(() => Text(
                                      controller.selectedCitizenship.value,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Contact Information
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Phone'.tr,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Obx(() => Text(
                                      controller.phoneController.text,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Email'.tr,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Obx(() => Text(
                                      controller.emailController.text,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Seat details with modern design
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade700.withOpacity(0.3) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.grey.shade800 : Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.airline_seat_recline_normal,
                                  size: 16,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Seat Details'.tr,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Seat info
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Seat Type'.tr,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Obx(() => Text(
                                      controller.selectedSeatType.value.capitalizeFirst!,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Position'.tr,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Obx(() => Text(
                                      controller.selectedBedPosition.value != null
                                          ? controller.selectedBedPosition.value!.toString().capitalizeFirst!
                                          : 'Not Selected'.tr,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Additional ticket information
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800.withOpacity(0.3) : Colors.grey.shade50,
                  border: Border(
                    top: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200),
                  ),
                ),
                child: Column(
                  children: [
                    // Citizenship information
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Citizenship'.tr,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Obx(() => Text(
                                controller.selectedCitizenship.value,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              )),
                            ],
                          ),
                        ),
                        // Issued date
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Issued At'.tr,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Ticket footer with price
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900.withOpacity(0.5) : Colors.grey.shade50,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                  border: Border(
                    top: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Price'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Obx(() {
                      // Calculate total price
                      String seatType = controller.selectedSeatType.value;
                      String? bedPosition = controller.selectedBedPosition.value;
                      double price = 0.0;
                      
                      if (seatType.isNotEmpty && bedPosition != null) {
                        String key = "${seatType.toLowerCase()}_$bedPosition";
                        price = controller.seatPrices[key] ?? 0.0;
                      }
                      
                      return Text(
                        "ETB ${price.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Payment method selection
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment Method'.tr,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              // Payment options
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade800 : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.credit_card,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chapa Payment',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            'Secure Online Payment'.tr,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Radio(
                      value: true,
                      groupValue: true,
                      onChanged: (value) {},
                      activeColor: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Navigation buttons
        Obx(() {
          final currentPage = controller.currentPage.value;
          final isLastPage = currentPage == 3; // Assuming 4 steps (0-3)
          final isFormValid = _isFormValid(controller, currentPage);
          
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back button
              TextButton(
                onPressed: controller.isLoading.value || currentPage == 0 
                    ? null 
                    : () {
                        controller.previousPage();
                      },
                child: Text(
                  "back".tr,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: controller.isLoading.value || currentPage == 0
                        ? Colors.grey 
                        : Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white70 
                            : Colors.black,
                  ),
                ),
              ),
              
              // Next/Submit button
              ElevatedButton(
                onPressed: controller.isLoading.value || !isFormValid
                    ? null
                    : () {
                        if (currentPage < 3) {
                          controller.nextPage();
                        } else {
                          // Handle form submission
                          controller.isLoading.value = true;
                          // Simulate payment processing
                          Future.delayed(const Duration(seconds: 2), () {
                            controller.isLoading.value = false;
                            // Show success message
                            Get.snackbar(
                              'payment_successful'.tr,
                              'ticket_booked_successfully'.tr,
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                              margin: const EdgeInsets.all(16),
                              borderRadius: 12,
                              duration: const Duration(seconds: 3),
                            );
                          });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: isFormValid && !controller.isLoading.value
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade400,
                  elevation: 3,
                  shadowColor: isFormValid && !controller.isLoading.value
                      ? Theme.of(context).primaryColor.withOpacity(0.3)
                      : Colors.transparent,
                ),
                child: controller.isLoading.value
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                              backgroundColor: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'processing'.tr,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isLastPage ? 'submit'.tr : 'next'.tr,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                          if (!isLastPage) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ],
                      ),
              ),
            ],
          );
        }),
      ],
    );
  }
  
  // Check if current form is valid based on current page
  bool _isFormValid(TicketController controller, int currentStep) {
    switch (currentStep) {
      case 0: // Travel Details
        return controller.selectedDepartureStation.value != null &&
               controller.selectedArrivalStation.value != null &&
               controller.selectedDate.value != null;
      case 1: // Personal Info
        final email = controller.emailController.text.trim();
        final isEmailValid = email.isEmpty || 
            (controller.isEmailVerified.value && 
             controller.verifiedEmail.value == email);
            
        return controller.firstNameController.text.isNotEmpty &&
               controller.lastNameController.text.isNotEmpty &&
               controller.phoneController.text.isNotEmpty &&
               (controller.selectedCitizenship.value != 'Foreign' || 
                controller.passportController.text.isNotEmpty) &&
               isEmailValid;
      case 2: // Seat Selection
        return controller.selectedSeatType.value.isNotEmpty &&
               (controller.selectedSeatType.value == 'regular' || 
                controller.selectedBedPosition.value.isNotEmpty);
      default:
        return true;
    }
  }

  Widget _buildProgressBar(int currentStep) {
    final int totalSteps = 4;
    final List<String> stepTitles = ['Travel Details'.tr, 'Personal Info'.tr, 'Seat Selection'.tr, 'Confirmation'.tr];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<TicketController>();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900.withOpacity(0.5) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Progress bar with animation
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                // Background track
                Container(
                  width: double.infinity,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                
                // Progress indicator with gradient and animation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  width: (MediaQuery.of(context).size.width - 32) * 
                      ((currentStep + 1) / totalSteps),
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.9),
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.9),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Step indicators and titles
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              totalSteps,
              (index) => GestureDetector(
                onTap: () {
                  // Only allow tapping on completed or current steps
                  if (index <= currentStep) {
                    controller.currentPage.value = index;
                  }
                },
                child: Column(
                  children: [
                    // Step indicator
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index <= currentStep
                            ? Theme.of(context).primaryColor
                            : isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                        border: Border.all(
                          color: isDark ? Colors.grey.shade600 : Colors.white,
                          width: 2,
                        ),
                        boxShadow: [
                          if (index <= currentStep)
                            BoxShadow(
                              color: Theme.of(context).primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Center(
                        child: index < currentStep
                            ? Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: index <= currentStep
                                      ? Colors.white
                                      : isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    // Step title
                    const SizedBox(height: 8),
                    Text(
                      stepTitles[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: index == currentStep ? FontWeight.bold : FontWeight.normal,
                        color: index <= currentStep
                            ? (isDark ? Colors.white : Theme.of(context).primaryColor)
                            : (isDark ? Colors.grey.shade500 : Colors.grey.shade500),
                      ),
                    ),
                    // Connection line (except for last step)
                    if (index < totalSteps - 1)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 2,
                        width: 20,
                        color: index < currentStep 
                            ? Theme.of(context).primaryColor.withOpacity(0.5)
                            : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBedPositionSelection(
    TicketController controller,
    String type,
    List<String> positions,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header for bed position selection
          Row(
            children: [
              Icon(
                type == "VIP" ? Icons.star_border_rounded : Icons.bed_rounded,
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                "choose_${type.toLowerCase()}_bed_position".tr,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Modern grid layout for bed positions
          GridView.count(
            crossAxisCount: positions.length == 3 ? 3 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.0,
            children: positions.map((position) {
              final String fullPosition = "${type.toLowerCase()}_$position";
              final bool isSelected = controller.selectedBedPosition.value == position && 
                                   controller.selectedSeatType.value == type.toLowerCase();
              
              // Get appropriate icon based on position
              IconData positionIcon = position == 'upper'
                  ? Icons.arrow_upward_rounded
                  : position == 'middle'
                      ? Icons.drag_handle_rounded
                      : Icons.arrow_downward_rounded;
                      
              return GestureDetector(
                onTap: () {
                  // Set both seat type and bed position
                  controller.setSelectedSeatType(type.toLowerCase());
                  controller.setSelectedBedPosition(position);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ] : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Position icon with background
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).primaryColor.withOpacity(0.1)
                              : isDark ? Colors.grey.shade700.withOpacity(0.3) : Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          positionIcon,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Position name
                      Text(
                        "${position.substring(0, 1).toUpperCase()}${position.substring(1)}",
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      
                      // Price
                      const SizedBox(height: 4),
                      Text(
                        controller.seatPrices[fullPosition] != null 
                            ? "ETB ${controller.seatPrices[fullPosition]!.toStringAsFixed(0)}"
                            : "Price N/A",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  // The _buildBedOptionTile method has been removed as it's no longer used in the new design
}
