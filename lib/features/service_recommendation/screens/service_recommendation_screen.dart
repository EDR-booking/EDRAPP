import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/service_recommendation_controller.dart';
import '../../ticket/models/service_model.dart';
import 'package:flutter_application_2/features/common/widgets/bottom_nav_screen_header.dart';

// Helper class to manage station information with normalized names
class StationInfo {
  final String originalName;
  final String normalizedName;
  final List<ServiceModel> services;
  
  StationInfo({
    required this.originalName,
    required this.normalizedName,
    required this.services,
  });
  
  int get serviceCount => services.length;
}

class ServiceRecommendationScreen extends StatelessWidget {
  const ServiceRecommendationScreen({super.key});
  
  // Normalize station name by converting to title case and removing station suffix
  String _normalizeStationName(String name) {
    // Remove suffix like '-station' or ' station'
    String cleanName = name.replaceAll(RegExp(r'[-\s]station$', caseSensitive: false), '');
    
    // Convert to title case (capitalize first letter of each word)
    List<String> words = cleanName.split(RegExp(r'[-\s]'));
    words = words.map((word) => word.isNotEmpty 
        ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' 
        : '').toList();
    
    return words.join(' ');
  }
  
  static Widget buildCategoryFilter(ServiceRecommendationController controller, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category title
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categories',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.grey[800],
                ),
              ),
              // Indicator to show scrollable
              Row(
                children: [
                  Icon(Icons.swipe, size: 14, color: isDark ? Colors.white54 : Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Scroll for more',
                    style: TextStyle(
                      fontSize: 12, 
                      color: isDark ? Colors.white54 : Colors.grey[600]
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Scrollable category chips
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              return Obx(() {
                final isSelected = category == controller.selectedCategory.value;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => controller.setSelectedCategory(category),
                      borderRadius: BorderRadius.circular(25),
                      splashColor: controller.getCategoryColor(category).withOpacity(0.3),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? controller.getCategoryColor(category)
                              : isDark ? Colors.grey[800] : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: controller.getCategoryColor(category).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                controller.getCategoryIcon(category),
                                size: 18,
                                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.grey.shade700),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                category,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.grey.shade700),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              });
            },
          ),
        ),
        // Divider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Divider(height: 1, color: isDark ? Colors.grey[800] : Colors.grey[300]),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<ServiceRecommendationController>()
        ? Get.find<ServiceRecommendationController>()
        : Get.put(ServiceRecommendationController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: BottomNavScreenHeader(
        title: 'Station Services',
      ),
      body: Column(
        children: [
          // Station Selection
          _buildStationSelector(context, controller),
          
          // Category Filter
          Obx(() => controller.selectedStation.value.isNotEmpty
              ? ServiceRecommendationScreen._buildCategoryFilter(controller, context)
              : const SizedBox.shrink()
          ),
          
          // Services List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.servicesByStation.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              
              if (controller.servicesByStation.isEmpty) {
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
                        'No service data available',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      TextButton(
                        onPressed: () => controller.loadServices(),
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                );
              }
              
              // Show station list if no station is selected
              if (controller.selectedStation.value.isEmpty) {
                // Normalize and deduplicate station names to prevent redundancy
                final stationMap = <String, StationInfo>{};
                
                // First pass: collect all stations with services and normalize their names
                controller.servicesByStation.forEach((stationName, services) {
                  if (services.isNotEmpty) {
                    // Normalize the station name (convert to title case and remove suffixes)
                    final normalizedName = _normalizeStationName(stationName);
                    
                    // If we already have this station, combine the services
                    if (stationMap.containsKey(normalizedName)) {
                      stationMap[normalizedName]!.services.addAll(services);
                    } else {
                      stationMap[normalizedName] = StationInfo(
                        originalName: stationName,
                        normalizedName: normalizedName,
                        services: List.from(services),
                      );
                    }
                  }
                });
                
                final stationsWithServices = stationMap.values.toList();
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: stationsWithServices.length,
                  itemBuilder: (context, index) {
                    final stationInfo = stationsWithServices[index];
                    final services = stationInfo.services;
                    
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
                          controller.setSelectedStation(stationInfo.originalName);
                          // Use pushReplacement instead of push to ensure proper back navigation
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => StationServicesDetailScreen(station: stationInfo.normalizedName),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.train_outlined,
                                  color: Theme.of(context).primaryColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      stationInfo.normalizedName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.check_circle_outline,
                                                size: 12,
                                                color: Colors.green.shade700,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${stationInfo.serviceCount} services',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.green.shade700,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
              
              // Show filtered services for selected station
              final filteredServices = controller.getFilteredServices();
              
              // If no services match the filter
              if (filteredServices.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No services match your filter',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      TextButton(
                        onPressed: () => controller.setSelectedCategory('All'),
                        child: const Text('Clear filter'),
                      ),
                    ],
                  ),
                );
              }
              
              // Show services for selected station
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredServices.length,
                itemBuilder: (context, index) {
                  final service = filteredServices[index];
                  return SimpleServiceCard(service: service, controller: controller);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // Build station selector with enhanced UI
  Widget _buildStationSelector(BuildContext context, ServiceRecommendationController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(() {
      // Debug output
      print('Building station selector with ${controller.stations.length} stations');
      if (controller.stations.isEmpty) {
        print('WARNING: No stations available in dropdown!');
        // Force reload of stations if empty
        if (!controller.isLoading.value) {
          print('Forcing station reload since list is empty');
          controller.resetStationData();
        }
      } else {
        controller.stations.forEach((station) => print('Available station: ${station.name}'));
      }
      
      // Create station dropdown items from the loaded stations
      final stationItems = controller.stations.map((station) {
        return DropdownMenuItem<String>(
          value: station.name,
          child: Text(
            station.name,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        );
      }).toList();
      
      // If no stations are available, add a temporary item
      if (stationItems.isEmpty && controller.isLoading.value) {
        stationItems.add(
          DropdownMenuItem<String>(
            value: '',
            enabled: false,
            child: Text('Loading stations...', style: TextStyle(color: Colors.grey[600])),
          ),
        );
      } else if (stationItems.isEmpty) {
        stationItems.add(
          DropdownMenuItem<String>(
            value: '',
            enabled: false,
            child: Text('No stations available', style: TextStyle(color: Colors.red)),
          ),
        );
      }
      
      return Column(children: [
        Container(
          margin: const EdgeInsets.all(16),
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
          child: DropdownButtonFormField<String>(
            value: controller.selectedStation.value.isEmpty ? null : controller.selectedStation.value,
            hint: Text(
              'Select a station',
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: isDark ? Colors.grey[800] : Colors.white,
            ),
            dropdownColor: isDark ? Colors.grey[850] : Colors.white,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            iconSize: 24,
            isExpanded: true,
            onChanged: (String? newValue) {
              if (newValue != null) {
                print('Station selected from dropdown: $newValue');
                // The controller's setSelectedStation method will handle getting the ID and loading services
                controller.setSelectedStation(newValue);
                
                // Navigate to the station detail screen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => StationServicesDetailScreen(station: newValue),
                  ),
                );
              }
            },
            items: stationItems,
          ),
        ),
        
        // Show station count for debugging
        if (stationItems.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'No stations available. Please check your connection.',
              style: TextStyle(color: Colors.red[700], fontSize: 14),
            ),
          ),
      ]);
    });
  }

  // Build category filter with enhanced UI and horizontal scrolling
  static Widget _buildCategoryFilter(ServiceRecommendationController controller, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category title
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categories',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.grey[800],
                ),
              ),
              // Indicator to show scrollable
              Row(
                children: [
                  Icon(Icons.swipe, size: 14, color: isDark ? Colors.white54 : Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Scroll for more',
                    style: TextStyle(
                      fontSize: 12, 
                      color: isDark ? Colors.white54 : Colors.grey[600]
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Scrollable category chips
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              return Obx(() {
                final isSelected = category == controller.selectedCategory.value;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => controller.setSelectedCategory(category),
                      borderRadius: BorderRadius.circular(25),
                      splashColor: controller.getCategoryColor(category).withOpacity(0.3),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? controller.getCategoryColor(category)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: controller.getCategoryColor(category).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                controller.getCategoryIcon(category),
                                size: 18,
                                color: isSelected ? Colors.white : Colors.grey.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                category,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected ? Colors.white : Colors.grey.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              });
            },
          ),
        ),
        // Divider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Divider(height: 1, color: Colors.grey[300]),
        ),
      ],
    );
  }
}

class StationServicesDetailScreen extends StatelessWidget {
  final String station;
  
  const StationServicesDetailScreen({super.key, required this.station});
  
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceRecommendationController>();
    
    return WillPopScope(
      onWillPop: () async {
        // Just clear the selected station without reloading everything
        controller.selectedStation.value = '';
        controller.selectedCategory.value = 'All';
        return true;
      },
      child: Scaffold(
        appBar: BottomNavScreenHeader(
          title: station,
          showBackButton: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              // Clear the selected station and category
              controller.selectedStation.value = '';
              controller.selectedCategory.value = 'All';
              // Navigate back
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              }
            },
            tooltip: 'Back to stations',
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Station info banner
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.train_outlined,
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
                        station,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Find services near this station',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Category filter
          ServiceRecommendationScreen._buildCategoryFilter(controller, context),
          
          // Services list
          Expanded(
            child: Obx(() {
              final services = controller.servicesByStation[station] ?? [];
              
              if (services.isEmpty) {
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
                        'No services available for $station',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              // Filter by category
              final filteredServices = controller.selectedCategory.value == 'All'
                  ? services
                  : services.where((service) => service.category == controller.selectedCategory.value).toList();
              
              if (filteredServices.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No services match your filter',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      TextButton(
                        onPressed: () => controller.setSelectedCategory('All'),
                        child: const Text('Clear filter'),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredServices.length,
                itemBuilder: (context, index) {
                  final service = filteredServices[index];
                  return SimpleServiceCard(service: service, controller: controller);
                },
              );
            }),
          ),
        ],
      ),
    ),
    );
  }
}

class SimpleServiceCard extends StatelessWidget {
  final ServiceModel service;
  final ServiceRecommendationController controller;
  
  const SimpleServiceCard({super.key, required this.service, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = controller.getCategoryColor(service.category);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1),
      color: isDark ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.grey[800]! : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ServiceDetailScreen(service: service),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: service.imageUrl.isNotEmpty
                    ? Image.network(
                        service.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: categoryColor.withOpacity(0.2),
                            child: Icon(
                              controller.getCategoryIcon(service.category),
                              color: categoryColor,
                              size: 32,
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: categoryColor.withOpacity(0.2),
                        child: Icon(
                          controller.getCategoryIcon(service.category),
                          color: categoryColor,
                          size: 32,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and category
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            service.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            controller.getCategoryIcon(service.category),
                            size: 12,
                            color: categoryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            service.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: categoryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Rating and distance
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${service.rating}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.map_outlined,
                          color: Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${service.distanceFromStation} m from ${service.stationName}',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.grey[600],
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
      ),
    );
  }
}

class ServiceDetailScreen extends StatelessWidget {
  final ServiceModel service;
  
  const ServiceDetailScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceRecommendationController>();
    final categoryColor = controller.getCategoryColor(service.category);
    
    return Scaffold(
      appBar: BottomNavScreenHeader(
        title: service.title,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service image
            service.imageUrl.isNotEmpty
                ? Image.network(
                    service.imageUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 200,
                        color: categoryColor.withOpacity(0.2),
                        child: Center(
                          child: Icon(
                            controller.getCategoryIcon(service.category),
                            color: categoryColor,
                            size: 64,
                          ),
                        ),
                      );
                    },
                  )
                : Container(
                    width: double.infinity,
                    height: 200,
                    color: categoryColor.withOpacity(0.2),
                    child: Center(
                      child: Icon(
                        controller.getCategoryIcon(service.category),
                        color: categoryColor,
                        size: 64,
                      ),
                    ),
                  ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and category
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              controller.getCategoryIcon(service.category),
                              size: 14,
                              color: categoryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              service.category,
                              style: TextStyle(
                                fontSize: 14,
                                color: categoryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${service.rating}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${service.distanceFromStation} m from ${service.stationName}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service.description,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Contact info
                  const Text(
                    'Contact Information',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Phone
                  if (service.phoneNumber.isNotEmpty)
                    _buildContactItem(
                      context,
                      Icons.phone_outlined,
                      service.phoneNumber,
                      () {
                        // Launch phone call
                      },
                    ),
                  const SizedBox(height: 12),
                  // Email
                  if (service.email.isNotEmpty)
                    _buildContactItem(
                      context,
                      Icons.email_outlined,
                      service.email,
                      () {
                        // Launch email
                      },
                    ),
                  const SizedBox(height: 12),
                  // Alternative phone
                  if (service.alternativePhone.isNotEmpty)
                    _buildContactItem(
                      context,
                      Icons.phone_android_outlined,
                      service.alternativePhone,
                      () {
                        // Launch alternative phone call
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildContactItem(BuildContext context, IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
