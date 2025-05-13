import 'package:cloud_firestore/cloud_firestore.dart';

class StationModel {
  final String id;
  final String name;
  final String location;
  final String? image;

  StationModel({
    required this.id,
    required this.name,
    required this.location,
    this.image,
  });

  factory StationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return StationModel(
      id: snapshot.id,
      name: data?['name'] ?? '',
      location: data?['location'] ?? '',
      image: data?['image'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'location': location,
      if (image != null) 'image': image,
    };
  }
}
