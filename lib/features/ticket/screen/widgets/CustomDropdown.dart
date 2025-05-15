// A simplified and reliable dropdown implementation that works with Flutter's standard widgets
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomDropdown extends StatefulWidget {
  final List<String> items;
  final String? selectedValue;
  final Function(String?) onChanged;
  final String hintText;
  final String? label;
  final IconData? prefixIcon;
  final Color? accentColor;
  final String? errorText;
  final BoxDecoration? decoration;

  const CustomDropdown({
    Key? key,
    required this.items,
    required this.onChanged,
    required this.hintText,
    this.selectedValue,
    this.label,
    this.prefixIcon,
    this.accentColor,
    this.errorText,
    this.decoration,
  }) : super(key: key);

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedValue;
  }

  @override
  void didUpdateWidget(CustomDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValue != oldWidget.selectedValue) {
      _selectedValue = widget.selectedValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.accentColor ?? Theme.of(context).primaryColor;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
        ],
        
        Container(
          height: 56,
          decoration: widget.decoration ?? BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.errorText != null 
                  ? Colors.red[700]! 
                  : isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
              width: widget.errorText != null ? 2 : 1, // Thicker border for error state
            ),
            // Add subtle shadow effect when there's an error
            boxShadow: widget.errorText != null ? [
              BoxShadow(
                color: Colors.red.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ] : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedValue,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: primaryColor),
              hint: Row(
                children: [
                  if (widget.prefixIcon != null) ...[
                    Icon(widget.prefixIcon!, color: primaryColor, size: 20),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    widget.hintText,
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              items: widget.items.map((String item) {
                final isSelected = _selectedValue == item;
                return DropdownMenuItem<String>(
                  value: item,
                  child: Row(
                    children: [
                      if (widget.prefixIcon != null) ...[
                        Icon(
                          widget.prefixIcon!, 
                          color: isSelected ? primaryColor : Colors.grey[500],
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                      ],
                      Text(
                        item,
                        style: TextStyle(
                          color: isSelected ? primaryColor : isDarkMode ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                // Play a subtle haptic feedback when selection changes
                HapticFeedback.selectionClick();
                
                setState(() {
                  _selectedValue = value;
                });
                widget.onChanged(value);
                
                // Add a slight delay to let the UI update before scrolling
                Future.delayed(Duration(milliseconds: 50), () {
                  // Ensure widget is still mounted
                  if (mounted) {
                    // Automatically scroll to next field if it's in a scrollable container
                    Scrollable.ensureVisible(
                      context,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                });
              },
            ),
          ),
        ),
        
        if (widget.errorText != null) ...[          
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.error_outline, size: 14, color: Colors.red[700]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.errorText!,
                  style: TextStyle(
                    color: Colors.red[700]!,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
