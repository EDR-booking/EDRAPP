import 'package:cloud_firestore/cloud_firestore.dart';

class TicketModel {
  final String? id;
  final String departure;
  final String arrival;
  final DateTime date;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String passport;
  final String seatType;
  final String bedPosition;
  final double price;
  final String status;
  final DateTime createdAt;
  final String citizenship;

  TicketModel({
    this.id,
    required this.departure,
    required this.arrival,
    required this.date,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.passport = '',
    required this.seatType,
    required this.bedPosition,
    required this.price,
    required this.status,
    required this.citizenship,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'departure': departure,
      'arrival': arrival,
      'date': Timestamp.fromDate(date),
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'passport': passport,
      'seatType': seatType,
      'bedPosition': bedPosition,
      'price': price,
      'status': status,
      'citizenship': citizenship,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create model from JSON
  factory TicketModel.fromJson(Map<String, dynamic> json, String id) {
    return TicketModel(
      id: id,
      departure: json['departure'] ?? '',
      arrival: json['arrival'] ?? '',
      date: (json['date'] as Timestamp).toDate(),
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      passport: json['passport'] ?? '',
      seatType: json['seatType'] ?? '',
      bedPosition: json['bedPosition'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      status: json['status'] ?? '',
      citizenship: json['citizenship'] ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  // Create a copy with updated fields
  TicketModel copyWith({
    String? id,
    String? departure,
    String? arrival,
    DateTime? date,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? passport,
    String? seatType,
    String? bedPosition,
    double? price,
    String? status,
    String? citizenship,
    DateTime? createdAt,
  }) {
    return TicketModel(
      id: id ?? this.id,
      departure: departure ?? this.departure,
      arrival: arrival ?? this.arrival,
      date: date ?? this.date,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      passport: passport ?? this.passport,
      seatType: seatType ?? this.seatType,
      bedPosition: bedPosition ?? this.bedPosition,
      price: price ?? this.price,
      status: status ?? this.status,
      citizenship: citizenship ?? this.citizenship,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
