import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final double? elevation;
  
  const CustomAppBar({
    Key? key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.backgroundColor,
    this.elevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Customize back button color
    final backButtonColor = isDarkMode ? Colors.white : null;
    
    return AppBar(
      title: Text(title.tr),
      centerTitle: true,
      backgroundColor: backgroundColor,
      elevation: elevation,
      iconTheme: isDarkMode ? IconThemeData(color: Colors.white) : null,
      leading: showBackButton ? IconButton(
        icon: Icon(Icons.arrow_back, color: backButtonColor),
        onPressed: () {
          // Make sure navigator has history first
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            // Fallback to Get.back if Navigator has no history
            // This ensures we always handle the back navigation properly
            Get.back();
          }
        },
      ) : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
