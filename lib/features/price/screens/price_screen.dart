import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/price_controller.dart';
import '../models/price_model.dart';
import 'package:flutter_application_2/utils/widgets/custom_app_bar.dart';

class PriceScreen extends StatelessWidget {
  const PriceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<PriceController>()
        ? Get.find<PriceController>()
        : Get.put(PriceController());
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: 'Ticket Prices',
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.prices.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (controller.prices.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No price data available',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                TextButton(
                  onPressed: () => controller.loadPrices(),
                  child: const Text('Refresh'),
                ),
              ],
            ),
          );
        }
        
        return Column(
          children: [
            // Route selector
            _buildRouteSelector(controller, context),
            
            // Ticket type selector
            _buildTicketTypeSelector(controller, context),
            
            // Currency selector
            _buildCurrencySelector(controller, context),
            
            // Prices list
            Expanded(
              child: controller.filteredPrices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No routes match your selection',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _buildPricesList(controller, context),
            ),
          ],
        );
      }),
    );
  }
  
  Widget _buildRouteSelector(PriceController controller, BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Route',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          // Origin dropdown
          DropdownButtonFormField<String>(
            value: controller.selectedOrigin.value.isEmpty
                ? null
                : controller.selectedOrigin.value,
            hint: const Text('Select Origin'),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              prefixIcon: const Icon(Icons.train_outlined),
            ),
            isExpanded: true,
            onChanged: (String? value) {
              if (value != null) {
                controller.setSelectedOrigin(value);
              }
            },
            items: controller.origins.map((origin) {
              return DropdownMenuItem<String>(
                value: origin,
                child: Text(origin),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Destination dropdown
          DropdownButtonFormField<String>(
            value: controller.selectedDestination.value.isEmpty
                ? null
                : controller.selectedDestination.value,
            hint: const Text('Select Destination'),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              prefixIcon: const Icon(Icons.location_on_outlined),
            ),
            isExpanded: true,
            onChanged: (String? value) {
              if (value != null) {
                controller.setSelectedDestination(value);
              }
            },
            items: controller.destinations.map((destination) {
              return DropdownMenuItem<String>(
                value: destination,
                child: Text(destination),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTicketTypeSelector(PriceController controller, BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(controller.ticketTypes.length, (index) {
            final ticketType = controller.ticketTypes[index];
            final displayName = controller.getTicketTypeDisplayName(ticketType);
            return Obx(() {
              final isSelected = ticketType == controller.selectedTicketType.value;
              return GestureDetector(
                onTap: () => controller.setSelectedTicketType(ticketType),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.indigo.shade700
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.indigo.shade700.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        ticketType.contains('vip') 
                            ? Icons.airline_seat_recline_extra
                            : ticketType.contains('bed') 
                                ? Icons.bed
                                : Icons.event_seat,
                        size: 18,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        displayName,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
          }),
        ),
      ),
    );
  }
  
  Widget _buildCurrencySelector(PriceController controller, BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(controller.currencies.length, (index) {
            final currency = controller.currencies[index];
            return Obx(() {
              final isSelected = currency == controller.selectedCurrency.value;
              return GestureDetector(
                onTap: () => controller.setSelectedCurrency(currency),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blue.shade700
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.blue.shade700.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.monetization_on_outlined,
                        size: 18,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        currency,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
          }),
        ),
      ),
    );
  }
  
  Widget _buildPricesList(PriceController controller, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: controller.filteredPrices.length,
        itemBuilder: (context, index) {
          final price = controller.filteredPrices[index];
          return PriceCard(price: price, controller: controller);
        },
      ),
    );
  }
}

class PriceCard extends StatelessWidget {
  final PriceModel price;
  final PriceController controller;
  
  const PriceCard({super.key, required this.price, required this.controller});

  @override
  Widget build(BuildContext context) {
    final selectedCurrency = controller.selectedCurrency.value;
    final selectedTicketType = controller.selectedTicketType.value;
    final currentPrice = price.getPriceByTypeAndCurrency(selectedTicketType, selectedCurrency);
    final priceCardColor = controller.getPriceCardColor(currentPrice);
    final priceTextColor = controller.getPriceTextColor(currentPrice);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          Get.to(() => RouteDetailScreen(price: price));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Route information
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.getRouteName(price),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.train_outlined,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              price.originName,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_right_alt,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              price.destinationName,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Ticket type
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                controller.getTicketTypeDisplayName(selectedTicketType),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: priceCardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Obx(() {
                      return Text(
                        controller.formatPriceDisplay(price),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: priceTextColor,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RouteDetailScreen extends StatelessWidget {
  final PriceModel price;
  
  const RouteDetailScreen({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PriceController>();
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Route Details',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Route Card
              Card(
                elevation: 3,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Route header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.route,
                              color: Colors.blue.shade700,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.getRouteName(price),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Updated on ${price.updatedAt.toDate().toLocal().toString().substring(0, 10)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Journey visualization
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.train,
                                    color: Colors.green.shade700,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  price.originName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 2,
                              color: Colors.grey.shade300,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.location_on,
                                    color: Colors.red.shade700,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  price.destinationName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Price information
              const Text(
                'Price Information',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              // Regular ticket price
              _buildPriceItem('Regular', price.getPriceByTypeAndCurrency('regular', 'ETH'), 'ETH', context, false),
              _buildPriceItem('Regular', price.getPriceByTypeAndCurrency('regular', 'DJI'), 'DJI', context, false),
              _buildPriceItem('Regular', price.getPriceByTypeAndCurrency('regular', 'FOR'), 'FOR', context, false),
              
              // Bed tickets (if available)
              if (price.bedLowerETH > 0) _buildSectionDivider('Bed Class Tickets', context),
              if (price.bedLowerETH > 0) _buildPriceItem('Lower Bed', price.getPriceByTypeAndCurrency('bedLower', 'ETH'), 'ETH', context, false),
              if (price.bedLowerDJI > 0) _buildPriceItem('Lower Bed', price.getPriceByTypeAndCurrency('bedLower', 'DJI'), 'DJI', context, false),
              if (price.bedLowerFOR > 0) _buildPriceItem('Lower Bed', price.getPriceByTypeAndCurrency('bedLower', 'FOR'), 'FOR', context, false),
              
              if (price.bedMiddleETH > 0) _buildPriceItem('Middle Bed', price.getPriceByTypeAndCurrency('bedMiddle', 'ETH'), 'ETH', context, false),
              if (price.bedMiddleDJI > 0) _buildPriceItem('Middle Bed', price.getPriceByTypeAndCurrency('bedMiddle', 'DJI'), 'DJI', context, false),
              if (price.bedMiddleFOR > 0) _buildPriceItem('Middle Bed', price.getPriceByTypeAndCurrency('bedMiddle', 'FOR'), 'FOR', context, false),
              
              if (price.bedUpperETH > 0) _buildPriceItem('Upper Bed', price.getPriceByTypeAndCurrency('bedUpper', 'ETH'), 'ETH', context, false),
              if (price.bedUpperDJI > 0) _buildPriceItem('Upper Bed', price.getPriceByTypeAndCurrency('bedUpper', 'DJI'), 'DJI', context, false),
              if (price.bedUpperFOR > 0) _buildPriceItem('Upper Bed', price.getPriceByTypeAndCurrency('bedUpper', 'FOR'), 'FOR', context, false),
              
              // VIP tickets (if available)
              if (price.vipLowerETH > 0) _buildSectionDivider('VIP Class Tickets', context),
              if (price.vipLowerETH > 0) _buildPriceItem('VIP Lower', price.getPriceByTypeAndCurrency('vipLower', 'ETH'), 'ETH', context, false),
              if (price.vipLowerDJI > 0) _buildPriceItem('VIP Lower', price.getPriceByTypeAndCurrency('vipLower', 'DJI'), 'DJI', context, false),
              if (price.vipLowerFOR > 0) _buildPriceItem('VIP Lower', price.getPriceByTypeAndCurrency('vipLower', 'FOR'), 'FOR', context, false),
              
              if (price.vipUpperETH > 0) _buildPriceItem('VIP Upper', price.getPriceByTypeAndCurrency('vipUpper', 'ETH'), 'ETH', context, false),
              if (price.vipUpperDJI > 0) _buildPriceItem('VIP Upper', price.getPriceByTypeAndCurrency('vipUpper', 'DJI'), 'DJI', context, false),
              if (price.vipUpperFOR > 0) _buildPriceItem('VIP Upper', price.getPriceByTypeAndCurrency('vipUpper', 'FOR'), 'FOR', context, true),
              
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.amber.shade800,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Prices may vary depending on the season, ticket class, and availability.',
                        style: TextStyle(
                          color: Colors.amber.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionDivider(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
  
  Widget _buildPriceItem(String label, double price, String currency, BuildContext context, bool isLast) {
    final formattedPrice = '$price $currency';
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                ),
              ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label ($currency)',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            formattedPrice,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
