import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/price_model.dart';
import '../repositories/price_repository.dart';

class PriceController extends GetxController {
  final PriceRepository _repository = PriceRepository();
  final prices = <PriceModel>[].obs;
  final filteredPrices = <PriceModel>[].obs;
  final originPrices = <String, List<PriceModel>>{}.obs;
  
  final origins = <String>[].obs;
  final destinations = <String>[].obs;
  
  final selectedOrigin = ''.obs;
  final selectedDestination = ''.obs;
  final selectedCurrency = 'ETH'.obs;
  final selectedTicketType = 'regular'.obs;
  
  final isLoading = false.obs;
  
  // List of available currencies
  final currencies = ['ETH', 'DJI', 'FOR'].obs;
  
  // List of available ticket types
  final ticketTypes = [
    'regular',
    'bedLower',
    'bedMiddle',
    'bedUpper',
    'vipLower',
    'vipUpper',
  ].obs;
  
  // Map of ticket type to display name
  final Map<String, String> ticketTypeNames = {
    'regular': 'Regular',
    'bedLower': 'Bed - Lower',
    'bedMiddle': 'Bed - Middle',
    'bedUpper': 'Bed - Upper',
    'vipLower': 'VIP - Lower',
    'vipUpper': 'VIP - Upper',
  };
  
  @override
  void onInit() {
    super.onInit();
    loadPrices();
  }
  
  // Load all prices from the repository
  void loadPrices() {
    isLoading.value = true;
    print('Loading prices from Firestore...');
    _repository.getAllPrices().listen((priceList) {
      prices.value = priceList;
      print('Loaded ${priceList.length} prices from Firestore');
      
      // Debug: print the first price to see what's coming from Firestore
      if (priceList.isNotEmpty) {
        final price = priceList[0];
        print('Sample price data:');
        print('Origin: ${price.originName}');
        print('Destination: ${price.destinationName}');
        print('Regular ETH: ${price.regularETH}');
        print('Regular DJI: ${price.regularDJI}');
        print('Regular FOR: ${price.regularFOR}');
        print('Bed Lower ETH: ${price.bedLowerETH}');
        // and so on...
      }
      
      _extractOriginsAndDestinations(priceList);
      _organizeByOrigin(priceList);
      isLoading.value = false;
    }, onError: (error) {
      print('Error loading prices: $error');
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to load prices');
    });
  }
  
  // Extract unique origins and destinations from price list
  void _extractOriginsAndDestinations(List<PriceModel> priceList) {
    final Set<String> originSet = {};
    final Set<String> destinationSet = {};
    
    for (var price in priceList) {
      originSet.add(price.originName);
      destinationSet.add(price.destinationName);
    }
    
    origins.value = originSet.toList()..sort();
    destinations.value = destinationSet.toList()..sort();
    
    // Set initial values if not already set
    if (selectedOrigin.value.isEmpty && origins.isNotEmpty) {
      selectedOrigin.value = origins[0];
    }
    
    if (selectedDestination.value.isEmpty && destinations.isNotEmpty) {
      selectedDestination.value = destinations[0];
    }
  }
  
  // Organize prices by origin
  void _organizeByOrigin(List<PriceModel> priceList) {
    final Map<String, List<PriceModel>> pricesByOrigin = {};
    
    for (var price in priceList) {
      if (!pricesByOrigin.containsKey(price.originName)) {
        pricesByOrigin[price.originName] = [];
      }
      pricesByOrigin[price.originName]!.add(price);
    }
    
    originPrices.value = pricesByOrigin;
    _filterPrices();
  }
  
  // Set selected origin
  void setSelectedOrigin(String origin) {
    selectedOrigin.value = origin;
    _filterPrices();
  }
  
  // Set selected destination
  void setSelectedDestination(String destination) {
    selectedDestination.value = destination;
    _filterPrices();
  }
  
  // Set selected currency
  void setSelectedCurrency(String currency) {
    selectedCurrency.value = currency;
  }
  
  // Set selected ticket type
  void setSelectedTicketType(String ticketType) {
    selectedTicketType.value = ticketType;
  }
  
  // Filter prices based on selected origin and destination
  void _filterPrices() {
    if (selectedOrigin.value.isEmpty) {
      filteredPrices.value = [];
      return;
    }
    
    var filtered = prices.where((price) {
      bool originMatch = true;
      bool destinationMatch = true;
      
      if (selectedOrigin.value.isNotEmpty) {
        originMatch = price.originName == selectedOrigin.value;
      }
      
      if (selectedDestination.value.isNotEmpty) {
        destinationMatch = price.destinationName == selectedDestination.value;
      }
      
      return originMatch && destinationMatch;
    }).toList();
    
    filteredPrices.value = filtered;
    
    // Debug: print filtered prices
    print('Filtered to ${filtered.length} prices');
    if (filtered.isNotEmpty) {
      final price = filtered[0];
      print('Sample filtered price:');
      print('Origin: ${price.originName}');
      print('Destination: ${price.destinationName}');
      print('Selected ticket type: $selectedTicketType');
      print('Selected currency: $selectedCurrency');
      print('Price: ${price.getPriceByTypeAndCurrency(selectedTicketType.value, selectedCurrency.value)}');
    }
  }
  
  // Get route name (Origin to Destination)
  String getRouteName(PriceModel price) {
    return '${price.originName} to ${price.destinationName}';
  }
  
  // Format price display with currency
  String formatPriceDisplay(PriceModel price) {
    final currentPrice = price.getPriceByTypeAndCurrency(
      selectedTicketType.value,
      selectedCurrency.value
    );
    return '$currentPrice ${selectedCurrency.value}';
  }
  
  // Get ticket type display name
  String getTicketTypeDisplayName(String ticketType) {
    return ticketTypeNames[ticketType] ?? ticketType;
  }
  
  // Get price card color based on price value
  Color getPriceCardColor(double price) {
    if (price <= 0) {
      return Colors.grey.shade200;
    } else if (price < 150) {
      return Colors.green.shade50;
    } else if (price < 250) {
      return Colors.blue.shade50;
    } else {
      return Colors.purple.shade50;
    }
  }
  
  // Get price text color based on price value
  Color getPriceTextColor(double price) {
    if (price <= 0) {
      return Colors.grey.shade700;
    } else if (price < 150) {
      return Colors.green.shade700;
    } else if (price < 250) {
      return Colors.blue.shade700;
    } else {
      return Colors.purple.shade700;
    }
  }
}
