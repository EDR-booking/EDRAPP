import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/ticket/controllers/bottomNavController.dart';
import 'package:flutter_application_2/features/ticket/screen/ticketScreen.dart';
import 'package:flutter_application_2/features/ticket/screen/my_ticket_screen.dart';
import 'package:flutter_application_2/features/service_recommendation/screens/service_recommendation_screen.dart';
import 'package:flutter_application_2/features/settings/screens/settings_screen.dart';
import 'package:get/get.dart';
import 'dart:ui';

class CustomBottomNavigationBar extends StatelessWidget {
  final String selectedCitizenship;

  CustomBottomNavigationBar({super.key, required this.selectedCitizenship});

  final BottomNavController navController = Get.put(BottomNavController());

  late final List<Widget> screens = [
    TicketScreen(selectedCitizenship: selectedCitizenship),
    const MyTicketScreen(),
    const ServiceRecommendationScreen(),
    const SettingsScreen(),
  ];

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
  
  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
  }) {
    final isSelected = navController.currentIndex.value == index;
    
    return InkWell(
      onTap: () => navController.changeIndex(index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.white.withOpacity(0.2) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected 
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ] 
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
