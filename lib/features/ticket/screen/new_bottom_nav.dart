import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_2/features/ticket/controllers/bottomNavController.dart';
import 'package:flutter_application_2/features/ticket/screen/ticketScreen.dart';
import 'package:flutter_application_2/features/ticket/screen/my_ticket_screen.dart';
import 'package:flutter_application_2/features/service_recommendation/screens/service_recommendation_screen.dart';
import 'package:flutter_application_2/features/settings/screens/settings_screen.dart';
import 'package:flutter_application_2/home.dart';

class NewBottomNavBar extends StatefulWidget {
  final String selectedCitizenship;
  
  const NewBottomNavBar({
    Key? key,
    required this.selectedCitizenship,
  }) : super(key: key);

  @override
  State<NewBottomNavBar> createState() => _NewBottomNavBarState();
}

class _NewBottomNavBarState extends State<NewBottomNavBar> {
  final BottomNavController navController = Get.put(BottomNavController());
  final RxBool _showBookingScreen = false.obs;
  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();
    
    screens = [
      _buildHomeWithBooking(widget.selectedCitizenship),
      const MyTicketScreen(),
      const ServiceRecommendationScreen(),
      const SettingsScreen(),
    ];
    
    // Close booking screen when switching tabs
    ever(navController.currentIndex, (index) {
      if (index != 0) {
        _showBookingScreen.value = false;
      }
    });
  }

  Widget _buildHomeWithBooking(String selectedCitizenship) {
    return Obx(() {
      return Stack(
        children: [
          // Main home content
          const Home(),
          
          // Semi-transparent overlay and booking screen when active
          if (_showBookingScreen.value) ...[
            // Dark overlay
            GestureDetector(
              onTap: () => _showBookingScreen.value = false,
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            // Ticket screen positioned at the bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: MediaQuery.of(Get.context!).size.height * 0.8,
                decoration: BoxDecoration(
                  color: Theme.of(Get.context!).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Draggable handle
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(
                      child: TicketScreen(selectedCitizenship: selectedCitizenship),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      );
    });
  }


  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    final isSelected = navController.currentIndex.value == index;
    final isActiveItem = isSelected && (isActive || index != 0);
    
    // Handle tap if no custom onTap is provided
    void handleTap() {
      if (onTap != null) {
        onTap();
      } else {
        navController.changeIndex(index);
      }
    }
    
    return InkWell(
      onTap: handleTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActiveItem 
              ? Colors.white.withOpacity(0.2) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActiveItem ? selectedIcon : icon,
              size: 24,
              color: isActiveItem ? Colors.white : Colors.white.withOpacity(0.7),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActiveItem ? Colors.white : Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontWeight: isActiveItem ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: navController.currentIndex.value,
          children: screens,
        ),
      ),
      resizeToAvoidBottomInset: false,
      extendBody: true,
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: 70,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1E40AF).withOpacity(0.95),
                      const Color(0xFF2563EB).withOpacity(0.95),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      icon: Icons.confirmation_number_outlined,
                      selectedIcon: Icons.confirmation_number,
                      label: 'Book Ticket',
                      index: 0,
                      isActive: _showBookingScreen.value,
                      onTap: () {
                        if (navController.currentIndex.value == 0) {
                          _showBookingScreen.toggle();
                        } else {
                          navController.changeIndex(0);
                          _showBookingScreen.value = true;
                        }
                      },
                    ),
                    _buildNavItem(
                      icon: Icons.qr_code_scanner_outlined,
                      selectedIcon: Icons.qr_code_scanner,
                      label: 'My Ticket',
                      index: 1,
                    ),
                    _buildNavItem(
                      icon: Icons.map_outlined,
                      selectedIcon: Icons.map,
                      label: 'Services',
                      index: 2,
                    ),
                    _buildNavItem(
                      icon: Icons.settings_outlined,
                      selectedIcon: Icons.settings,
                      label: 'Settings',
                      index: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Update the main.dart to use this new implementation
// home: NewBottomNavBar(selectedCitizenship: 'Ethiopian')
