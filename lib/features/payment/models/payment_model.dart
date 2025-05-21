class PaymentResponse {
  final bool success;
  final String? paymentId;
  final String? checkoutUrl;
  final String message;

  PaymentResponse({
    required this.success,
    this.paymentId,
    this.checkoutUrl,
    required this.message,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      success: json['success'] ?? false,
      paymentId: json['payment_id'],
      checkoutUrl: json['checkout_url'],
      message: json['message'] ?? 'Unknown response',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payment_id': paymentId,
      'checkout_url': checkoutUrl,
      'message': message,
    };
  }
}

class PaymentStatus {
  final String status; // 'pending', 'processing', 'completed', 'failed', 'error'
  final String? paymentId;
  final String? reference;
  final DateTime? completedAt;

  PaymentStatus({
    required this.status,
    this.paymentId,
    this.reference,
    this.completedAt,
  });

  factory PaymentStatus.fromJson(Map<String, dynamic> json) {
    return PaymentStatus(
      status: json['status'] ?? 'unknown',
      paymentId: json['payment_id'],
      reference: json['reference'],
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'payment_id': paymentId,
      'reference': reference,
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending' || status == 'processing';
  bool get isFailed => status == 'failed' || status == 'error';
}
