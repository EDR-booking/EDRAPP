import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String imageUrl;
  final String phoneNumber;
  final String alternativePhone;
  final String email;
  final String distanceFromStation;
  final String stationId;
  final String stationName;
  final double rating;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.phoneNumber,
    required this.alternativePhone,
    required this.email,
    required this.distanceFromStation,
    required this.stationId,
    required this.stationName,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    // Handle timestamp fields with null check
    Timestamp createdTimestamp = Timestamp.now();
    Timestamp updatedTimestamp = Timestamp.now();
    
    if (data != null) {
      if (data['createdAt'] != null) {
        createdTimestamp = data['createdAt'] as Timestamp;
      }
      if (data['updatedAt'] != null) {
        updatedTimestamp = data['updatedAt'] as Timestamp;
      }
    }
    
    return ServiceModel(
      id: snapshot.id,
      title: data?['title'] ?? '',
      description: data?['description'] ?? '',
      category: data?['category'] ?? '',
      imageUrl: data?['imageUrl'] ?? '',
      phoneNumber: data?['phoneNumber'] ?? '',
      alternativePhone: data?['alternativePhone'] ?? '',
      email: data?['email'] ?? '',
      distanceFromStation: data?['distanceFromStation'] ?? '',
      stationId: data?['stationId'] ?? '',
      stationName: data?['stationName'] ?? '',
      rating: (data?['rating'] ?? 0.0).toDouble(),
      createdAt: createdTimestamp,
      updatedAt: updatedTimestamp,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'phoneNumber': phoneNumber,
      'alternativePhone': alternativePhone,
      'email': email,
      'distanceFromStation': distanceFromStation,
      'stationId': stationId,
      'stationName': stationName,
      'rating': rating,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
