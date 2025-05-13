import 'package:flutter/material.dart';
import 'CustomDropdown.dart';

class CustomRadioGroup extends StatelessWidget {
  final String groupValue;
  final List<String> options;
  final String title;
  final ValueChanged<String?>? onChanged;
  final bool isEnabled;
  final Color? accentColor;
  final List<String>? foreignCountries;
  final String? selectedForeignCountry;
  final ValueChanged<String?>? onForeignCountryChanged;

  const CustomRadioGroup({
    Key? key,
    required this.groupValue,
    required this.options,
    required this.title,
    this.onChanged,
    this.isEnabled = true,
    this.accentColor,
    this.foreignCountries,
    this.selectedForeignCountry,
    this.onForeignCountryChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveAccentColor = accentColor ?? theme.primaryColor;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: effectiveAccentColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: effectiveAccentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...options.map(
              (option) => Theme(
                data: Theme.of(context).copyWith(
                  unselectedWidgetColor: effectiveAccentColor.withOpacity(0.5),
                ),
                child: RadioListTile<String>(
                  title: Text(
                    option,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color:
                          groupValue == option
                              ? effectiveAccentColor
                              : theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  value: option,
                  groupValue: groupValue,
                  onChanged: isEnabled ? onChanged : null,
                  activeColor: effectiveAccentColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  tileColor:
                      groupValue == option
                          ? effectiveAccentColor.withOpacity(0.1)
                          : null,
                ),
              ),
            ),
            if (groupValue == 'Foreign' && foreignCountries != null) ...[
              const SizedBox(height: 16),
              CustomDropdown(
                items: foreignCountries!,
                hintText: 'Select your country',
                label: 'Country',
                onChanged: onForeignCountryChanged ?? (_) {},
                prefixIcon: Icons.public,
                accentColor: effectiveAccentColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
