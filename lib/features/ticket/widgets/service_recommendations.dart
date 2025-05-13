import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/service_controller.dart';
import '../models/service_model.dart';
import 'dart:ui';

// Default image URL for services
const String DEFAULT_SERVICE_IMAGE = 'https://via.placeholder.com/300';

// Move the category selection state to a controller to persist it
class ServiceCategoryController extends GetxController {
  final RxString selectedCategory = 'all'.obs;
  
  void setCategory(String category) {
    selectedCategory.value = category;
  }
}

class ServiceRecommendations extends StatefulWidget {
  final String stationId;

  const ServiceRecommendations({super.key, required this.stationId});

  @override
  State<ServiceRecommendations> createState() => _ServiceRecommendationsState();
}

class _ServiceRecommendationsState extends State<ServiceRecommendations> {
  // Get or put the controllers
  final ServiceController serviceController = Get.put(ServiceController());
  final ServiceCategoryController categoryController = Get.put(ServiceCategoryController());
  
  // Scroll controller for the horizontal category list
  final ScrollController _scrollController = ScrollController();

  // Define service categories
  final List<Map<String, dynamic>> categories = [
    {'id': 'all', 'name': 'All', 'icon': Icons.category},
    {'id': 'accommodation', 'name': 'Accommodation', 'icon': Icons.hotel},
    {'id': 'dining', 'name': 'Dining', 'icon': Icons.restaurant},
    {'id': 'shopping', 'name': 'Shopping', 'icon': Icons.shopping_bag},
    {'id': 'transport', 'name': 'Transport', 'icon': Icons.local_taxi},
    {'id': 'entertainment', 'name': 'Entertainment', 'icon': Icons.movie},
  ];
  
  @override
  void initState() {
    super.initState();
    // Initialize service controller with station ID
    serviceController.loadServices(stationId: widget.stationId);
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  // Function to determine if a service belongs to a category
  bool isServiceInCategory(ServiceModel service, String categoryId) {
    if (categoryId == 'all') return true;
    
    final title = service.title.toLowerCase();
    final description = service.description.toLowerCase();
    
    switch (categoryId) {
      case 'accommodation':
        return title.contains('hotel') || 
               title.contains('accommodation') || 
               title.contains('lodge') ||
               description.contains('hotel') || 
               description.contains('accommodation');
      case 'dining':
        return title.contains('restaurant') || 
               title.contains('café') || 
               title.contains('cafe') ||
               title.contains('food') ||
               description.contains('restaurant') || 
               description.contains('food');
      case 'shopping':
        return title.contains('shop') || 
               title.contains('store') || 
               title.contains('market') ||
               description.contains('shop') || 
               description.contains('store');
      case 'transport':
        return title.contains('taxi') || 
               title.contains('transport') || 
               title.contains('car') ||
               description.contains('taxi') || 
               description.contains('transport');
      case 'entertainment':
        return title.contains('cinema') || 
               title.contains('theater') || 
               title.contains('entertainment') ||
               description.contains('entertainment');
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    
    return Obx(() {
      if (serviceController.isLoading.value) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 40, 
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading services...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }

      if (serviceController.services.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.store_mall_directory_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No services available',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Check back later for recommendations',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section with icon and title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.recommend,
                  color: primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Recommended Services',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 8, bottom: 16),
            child: Text(
              'Services and amenities near your station',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          
          // Scrollable category tabs - Explicit height and fixed ScrollPhysics
          SizedBox(
            height: 60,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = categoryController.selectedCategory.value == category['id'];
                
                return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 0 : 8,
                    right: index == categories.length - 1 ? 0 : 8,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      categoryController.setCategory(category['id'] as String);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected ? primaryColor : Colors.grey.shade300,
                          width: 1.5,
                        ),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ] : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            category['icon'] as IconData,
                            color: isSelected ? Colors.white : Colors.grey.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            category['name'] as String,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey.shade800,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Visible separation between filters and content
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          
          // Services list with improved cards
          Obx(() {
            // Filter services based on selected category
            final filteredServices = serviceController.services
                .where((service) => isServiceInCategory(service, categoryController.selectedCategory.value))
                .toList();
            
            if (filteredServices.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 48,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No ${categoryController.selectedCategory.value == "all" ? "services" : categoryController.selectedCategory.value} available',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try selecting a different category',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredServices.length,
              itemBuilder: (context, index) {
                final service = filteredServices[index];
                
                // Calculate service type icon
                IconData serviceIcon = Icons.store;
                Color serviceIconColor = Colors.blue;
                
                // Assign icons and colors based on service type
                if (service.title.toLowerCase().contains('hotel') || 
                    service.title.toLowerCase().contains('accommodation')) {
                  serviceIcon = Icons.hotel;
                  serviceIconColor = Colors.indigo;
                } else if (service.title.toLowerCase().contains('restaurant') || 
                           service.title.toLowerCase().contains('café') ||
                           service.title.toLowerCase().contains('cafe')) {
                  serviceIcon = Icons.restaurant;
                  serviceIconColor = Colors.orange;
                } else if (service.title.toLowerCase().contains('taxi') || 
                           service.title.toLowerCase().contains('transport')) {
                  serviceIcon = Icons.local_taxi;
                  serviceIconColor = Colors.amber;
                } else if (service.title.toLowerCase().contains('shop') || 
                           service.title.toLowerCase().contains('store') ||
                           service.title.toLowerCase().contains('market')) {
                  serviceIcon = Icons.shopping_bag;
                  serviceIconColor = Colors.green;
                }
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Service image with gradient overlay and rating banner
                      Stack(
                        children: [
                          // Service image
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: AspectRatio(
                              aspectRatio: 16/9,
                              child: Image.network(
                                service.imageUrl ?? DEFAULT_SERVICE_IMAGE,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.network(
                                    DEFAULT_SERVICE_IMAGE,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                          ),
                          
                          // Gradient overlay
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.5),
                                    ],
                                    stops: const [0.6, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          // Service title overlay at bottom
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Service name with backdrop filter
                                  Expanded(
                                    child: Text(
                                      service.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 4,
                                            color: Colors.black45,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  
                                  // Rating chip
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8, 
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          service.rating.toStringAsFixed(1),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Service type icon badge
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                serviceIcon,
                                color: serviceIconColor,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Service details
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Description
                            Text(
                              service.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[800],
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 16),
                            
                            // Distance and directions
                            Row(
                              children: [
                                // Distance info
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[50],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.near_me,
                                          color: Colors.blue[700],
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Distance',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                '${service.distanceFromStation}m',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                ' from station',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // View details button
                                ElevatedButton(
                                  onPressed: () {
                                    // TODO: Navigate to service details
                                    Get.snackbar(
                                      'Service Details', 
                                      'View more details about ${service.title}',
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                  ),
                                  child: const Text('View Details'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
          
          // See all button
          Obx(() => categoryController.selectedCategory.value == 'all' ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  // TODO: Navigate to all services
                  Get.snackbar(
                    'All Services', 
                    'View all services near your station',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                icon: Icon(
                  Icons.format_list_bulleted,
                  color: primaryColor,
                  size: 18,
                ),
                label: Text(
                  'View All Services',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: primaryColor.withOpacity(0.3)),
                  ),
                ),
              ),
            ),
          ) : const SizedBox.shrink()),
        ],
      );
    });
  }
}
