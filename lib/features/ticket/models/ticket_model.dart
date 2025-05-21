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
  final String? ticket_number;
  final String? accessToken;
  final String? ticketCode;
  final int? expiresAt;
  
  // Payment related fields
  final String paymentStatus; // 'pending', 'processing', 'completed', 'failed'
  final String? paymentId;    // ID from payment provider
  final String? paymentMethod; // Method used for payment (e.g., 'card', 'mobile_money')
  final DateTime? paymentDate; // When payment was completed
  final String? paymentReference; // Reference code for payment confirmation

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
    this.ticket_number,
    this.accessToken,
    this.ticketCode,
    this.expiresAt,
    DateTime? createdAt,
    this.paymentStatus = 'pending',
    this.paymentId,
    this.paymentMethod,
    this.paymentDate,
    this.paymentReference,
  }) : this.createdAt = createdAt ?? DateTime.now();

  // Convert model to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
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
      'status': status, // Use the status passed in constructor
      'citizenship': citizenship,
      'createdAt': Timestamp.fromDate(createdAt),
      'ticket_number': ticket_number,
      'paymentStatus': paymentStatus,
    };

    // Add only the accessToken and expiresAt (not ticketCode, isVerified, verifiedAt)
    if (accessToken != null) json['accessToken'] = accessToken;
    if (expiresAt != null) json['expiresAt'] = expiresAt;
    
    // Add payment-related fields if available
    if (paymentId != null) json['paymentId'] = paymentId;
    if (paymentMethod != null) json['paymentMethod'] = paymentMethod;
    if (paymentDate != null) json['paymentDate'] = Timestamp.fromDate(paymentDate!);
    if (paymentReference != null) json['paymentReference'] = paymentReference;
    
    return json;
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
      ticket_number: json['ticket_number'],
      accessToken: json['accessToken'],
      ticketCode: json['ticketCode'],
      expiresAt: json['expiresAt'],
      createdAt: (json['createdAt'] is Timestamp) ? (json['createdAt'] as Timestamp).toDate() : DateTime.now(),
      paymentStatus: json['paymentStatus'] ?? 'pending',
      paymentId: json['paymentId'],
      paymentMethod: json['paymentMethod'],
      paymentDate: (json['paymentDate'] is Timestamp) ? (json['paymentDate'] as Timestamp).toDate() : null,
      paymentReference: json['paymentReference'],
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
    String? ticket_number,
    String? accessToken,
    String? ticketCode,
    int? expiresAt,
    String? paymentStatus,
    String? paymentId,
    String? paymentMethod,
    DateTime? paymentDate,
    String? paymentReference,
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
      ticket_number: ticket_number ?? this.ticket_number,
      accessToken: accessToken ?? this.accessToken,
      ticketCode: ticketCode ?? this.ticketCode,
      expiresAt: expiresAt ?? this.expiresAt,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentId: paymentId ?? this.paymentId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentReference: paymentReference ?? this.paymentReference,
    );
  }
}
