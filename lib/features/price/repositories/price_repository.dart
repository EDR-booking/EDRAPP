import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/price_model.dart';

class PriceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'prices';
  
  // Get all prices
  Stream<List<PriceModel>> getAllPrices() {
    return _firestore
        .collection(_collectionName)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PriceModel.fromFirestore(doc, null))
          .toList();
    });
  }
  
  // Get all prices for a specific origin
  Stream<List<PriceModel>> getPricesByOrigin(String originId) {
    return _firestore
        .collection(_collectionName)
        .where('originId', isEqualTo: originId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PriceModel.fromFirestore(doc, null))
          .toList();
    });
  }
  
  // Get all prices for a specific destination
  Stream<List<PriceModel>> getPricesByDestination(String destinationId) {
    return _firestore
        .collection(_collectionName)
        .where('destinationId', isEqualTo: destinationId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PriceModel.fromFirestore(doc, null))
          .toList();
    });
  }
  
  // Get price for a specific route (origin to destination)
  Stream<PriceModel?> getPriceByRoute(String originId, String destinationId) {
    return _firestore
        .collection(_collectionName)
        .where('originId', isEqualTo: originId)
        .where('destinationId', isEqualTo: destinationId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return PriceModel.fromFirestore(snapshot.docs.first, null);
      } else {
        return null;
      }
    });
  }
  
  // Add a new price
  Future<void> addPrice(PriceModel price) {
    return _firestore.collection(_collectionName).add(price.toFirestore());
  }
  
  // Update an existing price
  Future<void> updatePrice(PriceModel price) {
    return _firestore
        .collection(_collectionName)
        .doc(price.id)
        .update(price.toFirestore());
  }
  
  // Delete a price
  Future<void> deletePrice(String priceId) {
    return _firestore.collection(_collectionName).doc(priceId).delete();
  }
}
