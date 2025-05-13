import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/service_recommendation_repository.dart';
import '../../../features/ticket/models/service_model.dart';
import '../../../features/ticket/models/station_model.dart';

class ServiceRecommendationController extends GetxController {
  // Service repository
  final ServiceRecommendationRepository _repository = ServiceRecommendationRepository();
  
  // Observable variables
  final RxBool isLoading = true.obs;
  final RxString selectedStation = ''.obs;
  final RxString selectedCategory = 'All'.obs;
  final RxList<ServiceModel> services = <ServiceModel>[].obs;
  final RxMap<String, List<ServiceModel>> servicesByStation = <String, List<ServiceModel>>{}.obs;
  final RxMap<String, List<ServiceModel>> servicesByCategory = <String, List<ServiceModel>>{}.obs;
  final RxList<String> categories = <String>['All', 'Accommodation', 'Dining', 'Transport', 'Tourism', 'Entertainment', 'Shopping', 'Healthcare'].obs;
  
  // Stations from Firebase
  final RxList<StationModel> stations = <StationModel>[].obs;
  final RxMap<String, String> stationNameToId = <String, String>{}.obs;
  
  // Getter for service categories (excluding 'All')
  List<String> get serviceCategories => categories.where((cat) => cat != 'All').toList();
  
  @override
  void onInit() {
    super.onInit();
    print('ServiceRecommendationController initialized');
    // Load stations directly from Firestore
    loadStations();
    // Load services from Firestore
    loadServices();
  }
  
  // Load stations from Firebase 'stations' collection
  void loadStations() {
    isLoading.value = true;
    _repository.getAllStations().listen((stationList) {
      stations.value = stationList;
      
      // Create a mapping of station names to IDs
      final Map<String, String> nameToId = {};
      for (var station in stationList) {
        nameToId[station.name] = station.id;
      }
      stationNameToId.value = nameToId;
      
      print('Loaded ${stations.length} stations from Firebase');
      stationList.forEach((station) => print('Station: ${station.name}'));
      
      isLoading.value = false;
    }, onError: (error) {
      print('Error loading stations: $error');
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to load stations');
      
      // Add fallback data if stations can't be loaded
      if (stations.isEmpty) {
        _addFallbackStationData();
      }
    });
  }
  
  // Add fallback station data for testing when Firebase data is not available
  void _addFallbackStationData() {
    final fallbackStations = [
      // Main stations on the Addis Ababa-Djibouti railway line
      StationModel(id: '1', name: 'Addis Ababa', location: 'Addis Ababa'),
      StationModel(id: '2', name: 'Kaliti', location: 'Kaliti'),
      StationModel(id: '3', name: 'Lebu', location: 'Lebu'),
      StationModel(id: '4', name: 'Akaki', location: 'Akaki'),
      StationModel(id: '5', name: 'Dukem', location: 'Dukem'),
      StationModel(id: '6', name: 'Bishoftu', location: 'Bishoftu'),
    ];
    
    stations.value = fallbackStations;
    
    // Create mapping of names to IDs
    final Map<String, String> nameToId = {};
    for (var station in fallbackStations) {
      nameToId[station.name] = station.id;
    }
    stationNameToId.value = nameToId;
    
    // Add empty service lists for each station
    final Map<String, List<ServiceModel>> emptyServicesByStation = {};
    for (var station in fallbackStations) {
      emptyServicesByStation[station.name] = [];
    }
    servicesByStation.value = emptyServicesByStation;
    
    print('Added fallback station data with ${fallbackStations.length} stations');
    fallbackStations.forEach((station) => print('Fallback station: ${station.name}'));
  }
  
  // Set selected station
  void setSelectedStation(String stationName) {
    selectedStation.value = stationName;
    
    // Get the station ID from the name
    final stationId = stationNameToId[stationName];
    if (stationId != null) {
      print('Loading services for station: $stationName with ID: $stationId');
      loadServicesByStation(stationId);
    } else {
      print('Error: No station ID found for station name: $stationName');
    }
  }
  
  // Reset all station-related data when back button is pressed
  void resetStationData() {
    print('Resetting station data completely');
    
    // Clear selected station
    selectedStation.value = '';
    selectedCategory.value = 'All';
    
    // Clear any cached service data for stations
    servicesByStation.clear();
    
    // First clear the existing stations
    stations.value = [];
    
    // Set loading to true to show loading indicator
    isLoading.value = true;
    
    // Load stations with a timeout to ensure we always get data
    bool stationsLoaded = false;
    
    // Attempt to load from Firebase with a timeout
    _repository.getAllStations().listen((stationList) {
      if (stationList.isNotEmpty) {
        print('Successfully loaded ${stationList.length} stations from Firebase');
        stations.value = stationList;
        
        // Create a mapping of station names to IDs
        final Map<String, String> nameToId = {};
        for (var station in stationList) {
          nameToId[station.name] = station.id;
          print('Station loaded: ${station.name}');
        }
        stationNameToId.value = nameToId;
        stationsLoaded = true;
      } else {
        print('Firebase returned empty station list, using fallback data');
        _addFallbackStationData();
      }
      isLoading.value = false;
    }, onError: (error) {
      print('Error loading stations from Firebase: $error');
      _addFallbackStationData();
      isLoading.value = false;
    }, onDone: () {
      // If no stations were loaded, use fallback data
      if (!stationsLoaded && stations.isEmpty) {
        print('No stations were loaded from Firebase, using fallback data');
        _addFallbackStationData();
        isLoading.value = false;
      }
    });
    
    // Set a timeout to ensure we always display stations even if Firebase is slow
    Future.delayed(const Duration(seconds: 3), () {
      if (stations.isEmpty) {
        print('Station loading timed out, using fallback data');
        _addFallbackStationData();
        isLoading.value = false;
      }
    });
  }
  
  // Set selected category
  void setSelectedCategory(String category) {
    selectedCategory.value = category;
    if (category != 'All') {
      loadServicesByCategory(category);
    }
  }
  
  // Load all services
  void loadServices() {
    isLoading.value = true;
    _repository.getAllServices().listen((serviceList) {
      services.value = serviceList;
      _organizeServicesByStation(serviceList);
      _organizeServicesByCategory(serviceList);
      isLoading.value = false;
    }, onError: (error) {
      print('Error loading services: $error');
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to load services');
    });
  }
  
  // Load services by station
  void loadServicesByStation(String stationId) {
    isLoading.value = true;
    _repository.getRecommendedServicesByStation(stationId).listen((serviceList) {
      if (servicesByStation.containsKey(stationId)) {
        servicesByStation[stationId] = serviceList;
      } else {
        servicesByStation.addAll({stationId: serviceList});
      }
      isLoading.value = false;
    }, onError: (error) {
      print('Error loading services by station: $error');
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to load services for this station');
    });
  }
  
  // Load services by category
  void loadServicesByCategory(String category) {
    isLoading.value = true;
    _repository.getRecommendedServicesByCategory(category).listen((serviceList) {
      if (servicesByCategory.containsKey(category)) {
        servicesByCategory[category] = serviceList;
      } else {
        servicesByCategory.addAll({category: serviceList});
      }
      isLoading.value = false;
    }, onError: (error) {
      print('Error loading services by category: $error');
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to load services for this category');
    });
  }
  
  // Load top rated services
  void loadTopRatedServices() {
    isLoading.value = true;
    _repository.getTopRatedServices().listen((serviceList) {
      services.value = serviceList;
      isLoading.value = false;
    }, onError: (error) {
      print('Error loading top rated services: $error');
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to load top rated services');
    });
  }
  
  // Organize services by station
  void _organizeServicesByStation(List<ServiceModel> serviceList) {
    final Map<String, List<ServiceModel>> stationMap = {};
    
    for (var service in serviceList) {
      // Use station name instead of ID for better display
      final stationName = service.stationName.isNotEmpty ? service.stationName : service.stationId;
      if (!stationMap.containsKey(stationName)) {
        stationMap[stationName] = [];
      }
      stationMap[stationName]?.add(service);
    }
    
    // Print for debugging
    print('Organized services by station - found ${stationMap.keys.length} stations');
    stationMap.keys.forEach((station) {
      print('Station: $station has ${stationMap[station]?.length} services');
    });
    
    servicesByStation.value = stationMap;
  }
  
  // Organize services by category
  void _organizeServicesByCategory(List<ServiceModel> serviceList) {
    final Map<String, List<ServiceModel>> categoryMap = {};
    
    for (var service in serviceList) {
      final category = service.category;
      if (!categoryMap.containsKey(category)) {
        categoryMap[category] = [];
      }
      categoryMap[category]?.add(service);
    }
    
    servicesByCategory.value = categoryMap;
  }
  
  // Get filtered services based on selected category
  List<ServiceModel> getFilteredServices() {
    if (selectedStation.value.isEmpty) {
      return [];
    }
    
    final stationServices = servicesByStation[selectedStation.value] ?? [];
    
    if (selectedCategory.value == 'All') {
      return stationServices;
    } else {
      return stationServices.where((service) => 
        service.category == selectedCategory.value).toList();
    }
  }
  
  // Get category color based on category name
  Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'accommodation': return Colors.blue.shade700;
      case 'dining': return Colors.orange.shade700;
      case 'transport': return Colors.green.shade700;
      case 'tourism': return Colors.purple.shade700;
      case 'shopping': return Colors.pink.shade700;
      case 'entertainment': return Colors.red.shade700;
      case 'healthcare': return Colors.teal.shade700;
      default: return Colors.grey.shade700;
    }
  }
  
  // Get category icon based on category name
  IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'accommodation': return Icons.hotel_outlined;
      case 'dining': return Icons.restaurant_outlined;
      case 'transport': return Icons.directions_car_outlined;
      case 'tourism': return Icons.photo_camera_outlined;
      case 'shopping': return Icons.shopping_bag_outlined;
      case 'entertainment': return Icons.movie_outlined;
      case 'healthcare': return Icons.local_hospital_outlined;
      default: return Icons.category_outlined;
    }
  }
}
