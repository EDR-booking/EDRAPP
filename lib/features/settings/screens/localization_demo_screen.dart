import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_2/utils/localization/app_translations.dart';
import 'package:flutter_application_2/utils/widgets/custom_app_bar.dart';

class LocalizationDemoScreen extends StatelessWidget {
  const LocalizationDemoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'localization_demo',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(
              title: 'current_language'.tr,
              content: AppTranslations.getCurrentLanguageName(),
              icon: Icons.language,
            ),
            const SizedBox(height: 20),
            _buildDemoCard(
              title: 'common_phrases'.tr,
              items: [
                {'label': 'hello'.tr, 'original': 'hello'},
                {'label': 'welcome'.tr, 'original': 'welcome'},
                {'label': 'ok'.tr, 'original': 'ok'},
                {'label': 'cancel'.tr, 'original': 'cancel'},
                {'label': 'yes'.tr, 'original': 'yes'},
                {'label': 'no'.tr, 'original': 'no'},
              ],
            ),
            const SizedBox(height: 20),
            _buildDemoCard(
              title: 'navigation'.tr,
              items: [
                {'label': 'home'.tr, 'original': 'home'},
                {'label': 'profile'.tr, 'original': 'profile'},
                {'label': 'settings'.tr, 'original': 'settings'},
                {'label': 'search'.tr, 'original': 'search'},
              ],
            ),
            const SizedBox(height: 20),
            _buildDemoCard(
              title: 'tickets_and_booking'.tr,
              items: [
                {'label': 'tickets'.tr, 'original': 'tickets'},
                {'label': 'book_ticket'.tr, 'original': 'book_ticket'},
                {'label': 'my_tickets'.tr, 'original': 'my_tickets'},
                {'label': 'from'.tr, 'original': 'from'},
                {'label': 'to'.tr, 'original': 'to'},
                {'label': 'departure'.tr, 'original': 'departure'},
                {'label': 'arrival'.tr, 'original': 'arrival'},
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.toNamed('/settings');
              },
              child: Text('change_language'.tr),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, size: 24),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoCard({
    required String title,
    required List<Map<String, String>> items,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Divider(),
            ...items.map((item) => _buildTranslationRow(
                  translated: item['label']!,
                  original: item['original']!,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslationRow({
    required String translated,
    required String original,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              translated,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '($original)',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
