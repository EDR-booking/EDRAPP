import 'package:flutter/material.dart';
import 'package:flutter_application_2/custome_shape/container/primary_header_container.dart';
import 'package:flutter_application_2/features/ticket/controllers/ticketController.dart';
import 'package:flutter_application_2/features/ticket/screen/widgets/CustomDropdown.dart';
import 'package:flutter_application_2/utils/constants/colors.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      // No app bar for cleaner fullscreen experience
      body: Column(
        children: [
          TPrimaryHeaderContainer(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "ETHIO-DJIBOUTI RAILWAY",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      "TICKET BOOKING",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).brightness == Brightness.dark ? Colors.grey[900]! : Colors.white,
                      Theme.of(context).brightness == Brightness.dark ? Colors.grey[850]! : const Color(0xFFF8FAFF),
                    ],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).padding.bottom + 80),
                  child: Obx(
                    () => Column(
                      children: [
                        _buildProgressBar(controller.currentPage.value),
                        const SizedBox(height: 20),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
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

  // Departure and Arrival Station Form
  Widget buildStationSelectionForm() {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8.0),
          Obx(
            () => CustomDropdown(
              items: stations,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.grey[600]! 
                      : const Color(0xFFE2E8F0)
                ),
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              hintText: 'Select departure station'.tr,
              label: 'from'.tr,
              onChanged: (value) {
                controller.selectedDepartureStation.value = value;
                
                // Reset date when changing stations
                if (controller.selectedArrivalStation.value != null) {
                  // Clear any previously selected date
                  controller.selectedDate.value = null;
                  controller.dateController.text = '';
                }
              },
              prefixIcon: Icons.train,
              accentColor: Theme.of(context).primaryColor,
              errorText:
                  controller.selectedDepartureStation.value ==
                              controller.selectedArrivalStation.value &&
                          controller.selectedDepartureStation.value != null
                      ? 'Departure and arrival stations cannot be the same'.tr
                      : null,
            ),
          ),
          const SizedBox(height: 16.0),
          Obx(
            () => CustomDropdown(
              items: stations,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.grey[600]! 
                      : const Color(0xFFE2E8F0)
                ),
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              hintText: 'Select arrival station'.tr,
              label: 'to'.tr,
              onChanged: (value) {
                controller.selectedArrivalStation.value = value;
                
                // Reset date when changing stations
                if (controller.selectedDepartureStation.value != null) {
                  // Clear any previously selected date
                  controller.selectedDate.value = null;
                  controller.dateController.text = '';
                }
              },
              prefixIcon: Icons.train,
              accentColor: Theme.of(context).primaryColor,
              errorText:
                  controller.selectedDepartureStation.value ==
                              controller.selectedArrivalStation.value &&
                          controller.selectedArrivalStation.value != null
                      ? 'Departure and arrival stations cannot be the same'.tr
                      : null,
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            'date'.tr,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 8.0),
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
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.grey[600]! 
                          : const Color(0xFFE2E8F0)
                    ),
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8.0),
                          Obx(() => Text(
                            controller.selectedDate.value == null
                                ? 'select_date'.tr
                                : controller.formattedSelectedDate,
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: controller.selectedDate.value == null
                                  ? FontWeight.normal 
                                  : FontWeight.bold,
                              color: controller.selectedDate.value == null
                                  ? (Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Theme.of(context).hintColor)
                                  : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color),
                            ),
                          )),
                        ],
                      ),
                      const SizedBox(height: 8.0),
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
                              'forward_direction_days'.tr,
                              style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                            );
                          } 
                          // Backward direction (Dire Dawa -> Sebeta)
                          else {
                            return Text(
                              'backward_direction_days'.tr,
                              style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                            );
                          }
                        } else if (departure != null && arrival != null) {
                          return Text(
                            'select_valid_stations'.tr,
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
              title: 'nationality'.tr,
              groupValue: controller.selectedCitizenship.value,
              options: const ['Ethiopian', 'Foreign', 'Djiboutian'].map((item) => item.tr).toList(),
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

              ElevatedButton(
                onPressed:
                    controller.isLoading.value ? null : controller.nextPage,
                child: Obx(
                  () =>
                      controller.isLoading.value
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // User Information Form
  Widget buildUserInformation() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "personal_information".tr,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 16.0),
          
          Text(
            "first_name".tr,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isDarkMode ? Colors.white70 : TColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            validator: (value) => value == null || value.isEmpty 
                ? 'first_name_required'.tr 
                : null,
            controller: controller.firstNameController,
            decoration: InputDecoration(
              labelText: 'first_name'.tr,
              hintText: 'enter_first_name'.tr,
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isDarkMode ? Colors.grey[600]! : Colors.grey,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isDarkMode ? Colors.grey[600]! : Colors.grey,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              prefixIcon: Icon(Icons.person, 
                color: isDarkMode ? Colors.white70 : null),
              labelStyle: TextStyle(
                color: isDarkMode ? Colors.white70 : null,
              ),
              hintStyle: TextStyle(
                color: isDarkMode ? Colors.grey[400] : null,
              ),
              filled: isDarkMode,
              fillColor: isDarkMode ? Colors.grey[800] : null,
            ),
          ),
          
          const SizedBox(height: 16.0),
          Text(
            "last_name".tr,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isDarkMode ? Colors.white70 : TColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            validator: (value) => value == null || value.isEmpty 
                ? 'last_name_required'.tr 
                : null,
            controller: controller.lastNameController,
            decoration: InputDecoration(
              labelText: 'last_name'.tr,
              hintText: 'enter_last_name'.tr,
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isDarkMode ? Colors.grey[600]! : Colors.grey,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isDarkMode ? Colors.grey[600]! : Colors.grey,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              prefixIcon: Icon(Icons.person, 
                color: isDarkMode ? Colors.white70 : null),
              labelStyle: TextStyle(
                color: isDarkMode ? Colors.white70 : null,
              ),
              hintStyle: TextStyle(
                color: isDarkMode ? Colors.grey[400] : null,
              ),
              filled: isDarkMode,
              fillColor: isDarkMode ? Colors.grey[800] : null,
            ),
          ),
          
          const SizedBox(height: 16.0),
          Text(
            "email".tr,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isDarkMode ? Colors.white70 : TColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            controller: controller.emailController,
            enabled: false, // Make the field non-editable
            decoration: InputDecoration(
              labelText: 'email'.tr,
              hintText: controller.emailController.text,
              border: OutlineInputBorder(),
              prefixIcon: const Icon(Icons.email),
              filled: true,
              fillColor: Colors.grey[200],
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
            ),
            style: TextStyle(
              color: Colors.black87, // Ensure text is visible even when disabled
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            "phone_number".tr,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isDarkMode ? Colors.white70 : TColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            validator: (value) => value == null || value.isEmpty 
                ? 'phone_number_required'.tr 
                : null,
            controller: controller.phoneController,
            decoration: InputDecoration(
              labelText: 'phone_number'.tr,
              border: OutlineInputBorder(),
              prefixIcon: const Icon(Icons.phone),
              labelStyle: TextStyle(
                color: isDarkMode ? Colors.white70 : null,
              ),
              hintStyle: TextStyle(
                color: isDarkMode ? Colors.grey[400] : null,
              ),
              filled: isDarkMode,
              fillColor: isDarkMode ? Colors.grey[800] : null,
            ),
          ),
          
          // Passport field - only for Foreign and Djiboutian travelers
          Obx(() => controller.selectedCitizenship.value == 'Foreign' || controller.selectedCitizenship.value == 'Djiboutian' ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),
              Text(
                "passport_number".tr,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDarkMode ? Colors.white70 : TColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                validator: (value) => controller.selectedCitizenship.value == 'Ethiopian' ? null : 
                  (value == null || value.isEmpty ? 'passport_number_required'.tr : null),
                controller: controller.passportController,
                decoration: InputDecoration(
                  labelText: 'passport_number'.tr,
                  hintText: 'enter_passport_number'.tr,
                  border: OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.badge),
                  labelStyle: TextStyle(
                    color: isDarkMode ? Colors.white70 : null,
                  ),
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : null,
                  ),
                  filled: isDarkMode,
                  fillColor: isDarkMode ? Colors.grey[800] : null,
                ),
              ),
            ],
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

              ElevatedButton(
                onPressed:
                    controller.isLoading.value ? null : controller.nextPage,
                child: Obx(
                  () =>
                      controller.isLoading.value
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget seatSelection() {
    final controller = Get.find<TicketController>();

    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select Your Seat",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),

          // Seat Type Selection
          Card(
            elevation: 0.5,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            shadowColor: Colors.blue.withOpacity(0.1),
            child: Column(
              children: [
                Obx(
                  () => ListTile(
                    leading: Icon(
                      Icons.airline_seat_recline_normal_rounded,
                      color:
                          controller.selectedSeatType.value == 'regular'
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                    ),
                    title: const Text("Regular Seat"),
                    subtitle: Text(
                      "ETB ${controller.seatPrices['regular']!.toStringAsFixed(2)}",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    trailing: Radio<String>(
                      value: 'regular',
                      groupValue: controller.selectedSeatType.value,
                      onChanged:
                          (value) => controller.setSelectedSeatType(value!),
                    ),
                  ),
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                Obx(
                  () => ListTile(
                    leading: Icon(
                      Icons.hotel_rounded,
                      color:
                          controller.selectedSeatType.value == 'economic'
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                    ),
                    title: const Text("Economic Bed"),
                    subtitle: Text(
                      "Starting from ETB ${controller.seatPrices['economic_upper']!.toStringAsFixed(2)}",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    trailing: Radio<String>(
                      value: 'economic',
                      groupValue: controller.selectedSeatType.value,
                      onChanged:
                          (value) => controller.setSelectedSeatType(value!),
                    ),
                  ),
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                Obx(
                  () => ListTile(
                    leading: Icon(
                      Icons.star_rounded,
                      color:
                          controller.selectedSeatType.value == 'vip'
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                    ),
                    title: const Text("VIP Bed"),
                    subtitle: Text(
                      "Starting from ETB ${controller.seatPrices['vip_upper']!.toStringAsFixed(2)}",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    trailing: Radio<String>(
                      value: 'vip',
                      groupValue: controller.selectedSeatType.value,
                      onChanged:
                          (value) => controller.setSelectedSeatType(value!),
                    ),
                  ),
                ),
              ],
            ),
          ),

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
          // Price Display
          Obx(
            () => Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Price:",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      "ETB ${controller.currentSeatPrice.toStringAsFixed(2)}",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: controller.isLoading.value ? 0 : 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  shadowColor: const Color(0xFF2563EB).withOpacity(0.5),
                ).copyWith(
                  overlayColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed)) {
                        return const Color(0xFF1E40AF);
                      }
                      return null;
                    },
                  ),
                ),
                onPressed:
                    controller.isLoading.value ? null : controller.bookTicket,
                child: Obx(
                  () =>
                      controller.isLoading.value
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 2,
                            ),
                          )
                          : AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                            child: const Text("Book Ticket"),
                          ),
                ),
              ),
            ],
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
      default:
        return const Center(child: Text('Invalid page'));
    }
  }
  
  Widget _buildProgressBar(int currentStep) {
    final int totalSteps = 3;
    final List<String> stepTitles = ['Travel Details', 'Personal Info', 'Seat Selection'];
    
    return Column(
      children: [
        // Progress bar
        Container(
          width: double.infinity,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: MediaQuery.of(context).size.width * 
                    ((currentStep + 1) / totalSteps) - 48, // Adjust for padding
                height: 5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1E40AF),
                      const Color(0xFF3B82F6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Step indicators
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              totalSteps,
              (index) => _buildStepIndicator(
                index,
                currentStep,
                stepTitles[index],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStepIndicator(int step, int currentStep, String title) {
    final bool isCompleted = step < currentStep;
    final bool isCurrent = step == currentStep;
    
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isCompleted || isCurrent 
                ? const Color(0xFF2563EB) 
                : Colors.grey.shade300,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted || isCurrent 
                  ? const Color(0xFF2563EB) 
                  : Colors.grey.shade400,
              width: 2,
            ),
            boxShadow: isCurrent 
                ? [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ] 
                : null,
          ),
          child: Center(
            child: isCompleted 
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ) 
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isCurrent ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: isCurrent ? const Color(0xFF2563EB) : Colors.grey.shade600,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildBedPositionSelection(
    TicketController controller,
    String type,
    List<String> positions,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Choose $type Bed Position",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0.5,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            shadowColor: Colors.blue.withOpacity(0.1),
            child: Column(
              children:
                  positions.map((position) {
                    final String fullPosition =
                        "${type.toLowerCase()}_$position";
                    return Column(
                      children: [
                        _buildBedOptionTile(
                          controller,
                          "${position.substring(0, 1).toUpperCase()}${position.substring(1)} Bed",
                          fullPosition,
                          position == 'upper'
                              ? Icons.arrow_upward_rounded
                              : position == 'middle'
                              ? Icons.drag_handle_rounded
                              : Icons.arrow_downward_rounded,
                        ),
                        if (position != positions.last)
                          Divider(height: 1, color: Colors.grey.shade200),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBedOptionTile(
    TicketController controller,
    String title,
    String position,
    IconData icon,
  ) {
    return Obx(
      () => ListTile(
        leading: Icon(
          icon,
          color:
              controller.selectedBedPosition.value == position.split('_')[1]
                  ? const Color(0xFF2563EB)
                  : const Color(0xFF94A3B8),
        ),
        title: Text(title),
        subtitle: Text(
          "ETB ${controller.seatPrices[position]!.toStringAsFixed(2)}",
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: Radio<String>(
          value: position.split('_')[1],
          groupValue: controller.selectedBedPosition.value,
          onChanged: (value) => controller.setSelectedBedPosition(value!),
        ),
      ),
    );
  }
}
