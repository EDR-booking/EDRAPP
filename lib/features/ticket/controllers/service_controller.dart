import 'package:get/get.dart';
import '../models/service_model.dart';
import '../repositories/service_repository.dart';

// Default image URL for services
const String DEFAULT_SERVICE_IMAGE = 'https://via.placeholder.com/300';

class ServiceController extends GetxController {
  final ServiceRepository _serviceRepository = ServiceRepository();
  final RxList<ServiceModel> services = <ServiceModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedStationId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadServices();
  }

  void loadServices({String? stationId}) {
    if (stationId != null) {
      selectedStationId.value = stationId;
    }
    
    if (selectedStationId.value.isNotEmpty) {
      isLoading.value = true;
      _serviceRepository
          .getServicesForStation(selectedStationId.value)
          .listen((newServices) {
        if (newServices.isEmpty) {
          // Log the issue
          print('No services found for station: $selectedStationId');
          // You might want to show a message to the user
          Get.snackbar('No Services', 'No services found for this station');
        } else {
          services.value = newServices;
        }
        isLoading.value = false;
      }, onError: (error) {
        print('Error loading services: $error');
        Get.snackbar('Error', 'Failed to load services');
        isLoading.value = false;
      });
    }
  }

  Future<void> addService(ServiceModel service) async {
    isLoading.value = true;
    try {
      await _serviceRepository.addService(service);
      loadServices();
    } catch (e) {
      Get.snackbar('Error', 'Failed to add service: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateService(ServiceModel service) async {
    isLoading.value = true;
    try {
      await _serviceRepository.updateService(service);
      loadServices();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update service: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteService(String id) async {
    isLoading.value = true;
    try {
      await _serviceRepository.deleteService(id);
      loadServices();
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete service: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
