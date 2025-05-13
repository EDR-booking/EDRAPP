import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_model.dart';

class ServiceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'services';

  // Get services for a specific station
  Stream<List<ServiceModel>> getServicesForStation(String stationId) {
    return _firestore
        .collection(_collectionName)
        .where('stationId', isEqualTo: stationId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc, null))
          .toList();
    });
  }

  // Add a new service
  Future<void> addService(ServiceModel service) {
    return _firestore.collection(_collectionName).add(service.toFirestore());
  }

  // Update an existing service
  Future<void> updateService(ServiceModel service) {
    return _firestore
        .collection(_collectionName)
        .doc(service.id)
        .update(service.toFirestore());
  }

  // Delete a service
  Future<void> deleteService(String id) {
    return _firestore.collection(_collectionName).doc(id).delete();
  }
}
