import 'package:cloud_firestore/cloud_firestore.dart';
import '../../ticket/models/service_model.dart';
import '../../ticket/models/station_model.dart';

class ServiceRecommendationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _servicesCollection = 'services';
  final String _stationsCollection = 'stations';

  // Get all services
  Stream<List<ServiceModel>> getAllServices() {
    return _firestore
        .collection(_servicesCollection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc, null))
          .toList();
    });
  }
  
  // Get all stations
  Stream<List<StationModel>> getAllStations() {
    print('Fetching all stations from collection: $_stationsCollection');
    return _firestore
        .collection(_stationsCollection)
        .snapshots()
        .map((snapshot) {
      final stations = snapshot.docs
          .map((doc) => StationModel.fromFirestore(doc, null))
          .toList();
      print('Fetched ${stations.length} stations from Firestore');
      
      // If we don't have all stations we're expecting, add them to the fallback data in the controller
      if (stations.isEmpty) {
        print('WARNING: No stations found in Firestore!');
      }
      
      return stations;
    });
  }

  // Get recommended services by category
  Stream<List<ServiceModel>> getRecommendedServicesByCategory(String category) {
    return _firestore
        .collection(_servicesCollection)
        .where('category', isEqualTo: category)
        .limit(5)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc, null))
          .toList();
    });
  }

  // Get recommended services by station
  Stream<List<ServiceModel>> getRecommendedServicesByStation(String stationId) {
    return _firestore
        .collection(_servicesCollection)
        .where('stationId', isEqualTo: stationId)
        .limit(10)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc, null))
          .toList();
    });
  }

  // Get top rated services
  Stream<List<ServiceModel>> getTopRatedServices() {
    return _firestore
        .collection(_servicesCollection)
        .limit(5)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc, null))
          .toList();
    });
  }
}
