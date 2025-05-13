import 'package:cloud_firestore/cloud_firestore.dart';

class PriceModel {
  final String id;
  final String originId;
  final String originName;
  final String destinationId;
  final String destinationName;
  
  // Regular ticket prices
  final double regularETH;
  final double regularDJI;
  final double regularFOR;
  
  // Bed Lower ticket prices
  final double bedLowerETH;
  final double bedLowerDJI;
  final double bedLowerFOR;
  
  // Bed Middle ticket prices
  final double bedMiddleETH;
  final double bedMiddleDJI;
  final double bedMiddleFOR;
  
  // Bed Upper ticket prices
  final double bedUpperETH;
  final double bedUpperDJI;
  final double bedUpperFOR;
  
  // VIP Lower ticket prices
  final double vipLowerETH;
  final double vipLowerDJI;
  final double vipLowerFOR;
  
  // VIP Upper ticket prices
  final double vipUpperETH;
  final double vipUpperDJI;
  final double vipUpperFOR;
  
  final String currency;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  PriceModel({
    required this.id,
    required this.originId,
    required this.originName,
    required this.destinationId,
    required this.destinationName,
    this.regularETH = 0.0,
    this.regularDJI = 0.0,
    this.regularFOR = 0.0,
    this.bedLowerETH = 0.0,
    this.bedLowerDJI = 0.0,
    this.bedLowerFOR = 0.0,
    this.bedMiddleETH = 0.0,
    this.bedMiddleDJI = 0.0,
    this.bedMiddleFOR = 0.0,
    this.bedUpperETH = 0.0,
    this.bedUpperDJI = 0.0,
    this.bedUpperFOR = 0.0,
    this.vipLowerETH = 0.0,
    this.vipLowerDJI = 0.0,
    this.vipLowerFOR = 0.0,
    this.vipUpperETH = 0.0,
    this.vipUpperDJI = 0.0,
    this.vipUpperFOR = 0.0,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PriceModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    if (data == null) {
      throw Exception('Document data is null');
    }
    
    print('Processing document ${snapshot.id}');
    print('Field regularETH: ${data['regularETH']}');
    print('Field bedLowerETH: ${data['bedLowerETH']}');
    
    // Helper function to safely convert various numeric types to double
    double toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          print('Error parsing string to double: $value');
          return 0.0;
        }
      }
      print('Unknown type for value: $value (${value.runtimeType})');
      return 0.0;
    }
    
    return PriceModel(
      id: snapshot.id,
      originId: data['originId'] ?? '',
      originName: data['originName'] ?? '',
      destinationId: data['destinationId'] ?? '',
      destinationName: data['destinationName'] ?? '',
      regularETH: toDouble(data['regularETH']),
      regularDJI: toDouble(data['regularDJI']),
      regularFOR: toDouble(data['regularFOR']),
      bedLowerETH: toDouble(data['bedLowerETH']),
      bedLowerDJI: toDouble(data['bedLowerDJI']),
      bedLowerFOR: toDouble(data['bedLowerFOR']),
      bedMiddleETH: toDouble(data['bedMiddleETH']),
      bedMiddleDJI: toDouble(data['bedMiddleDJI']),
      bedMiddleFOR: toDouble(data['bedMiddleFOR']),
      bedUpperETH: toDouble(data['bedUpperETH']),
      bedUpperDJI: toDouble(data['bedUpperDJI']),
      bedUpperFOR: toDouble(data['bedUpperFOR']),
      vipLowerETH: toDouble(data['vipLowerETH']),
      vipLowerDJI: toDouble(data['vipLowerDJI']),
      vipLowerFOR: toDouble(data['vipLowerFOR']),
      vipUpperETH: toDouble(data['vipUpperETH']),
      vipUpperDJI: toDouble(data['vipUpperDJI']),
      vipUpperFOR: toDouble(data['vipUpperFOR']),
      currency: data['currency'] ?? 'ETB',
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
      updatedAt: data['updatedAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'originId': originId,
      'originName': originName,
      'destinationId': destinationId,
      'destinationName': destinationName,
      'regularETH': regularETH,
      'regularDJI': regularDJI,
      'regularFOR': regularFOR,
      'bedLowerETH': bedLowerETH,
      'bedLowerDJI': bedLowerDJI,
      'bedLowerFOR': bedLowerFOR,
      'bedMiddleETH': bedMiddleETH,
      'bedMiddleDJI': bedMiddleDJI,
      'bedMiddleFOR': bedMiddleFOR,
      'bedUpperETH': bedUpperETH,
      'bedUpperDJI': bedUpperDJI,
      'bedUpperFOR': bedUpperFOR,
      'vipLowerETH': vipLowerETH,
      'vipLowerDJI': vipLowerDJI,
      'vipLowerFOR': vipLowerFOR,
      'vipUpperETH': vipUpperETH,
      'vipUpperDJI': vipUpperDJI,
      'vipUpperFOR': vipUpperFOR,
      'currency': currency,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Method to get specific price based on ticket type and currency
  double getPriceByTypeAndCurrency(String ticketType, String currency) {
    print('Getting price for type: $ticketType, currency: $currency');
    
    switch ('${ticketType}_$currency') {
      case 'regular_ETH':
        print('Returning regularETH: $regularETH');
        return regularETH;
      case 'regular_DJI':
        return regularDJI;
      case 'regular_FOR':
        return regularFOR;
      case 'bedLower_ETH':
        print('Returning bedLowerETH: $bedLowerETH');
        return bedLowerETH;
      case 'bedLower_DJI':
        return bedLowerDJI;
      case 'bedLower_FOR':
        return bedLowerFOR;
      case 'bedMiddle_ETH':
        return bedMiddleETH;
      case 'bedMiddle_DJI':
        return bedMiddleDJI;
      case 'bedMiddle_FOR':
        return bedMiddleFOR;
      case 'bedUpper_ETH':
        return bedUpperETH;
      case 'bedUpper_DJI':
        return bedUpperDJI;
      case 'bedUpper_FOR':
        return bedUpperFOR;
      case 'vipLower_ETH':
        return vipLowerETH;
      case 'vipLower_DJI':
        return vipLowerDJI;
      case 'vipLower_FOR':
        return vipLowerFOR;
      case 'vipUpper_ETH':
        return vipUpperETH;
      case 'vipUpper_DJI':
        return vipUpperDJI;
      case 'vipUpper_FOR':
        return vipUpperFOR;
      default:
        print('No match found for ${ticketType}_$currency');
        return 0.0;
    }
  }
}
