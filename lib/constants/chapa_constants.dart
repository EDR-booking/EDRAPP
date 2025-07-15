class ChapaConstants {
  // Chapa API Keys (using the test key from .env file)
  static const String chapaPublicKey = 'CHAPUBK_TEST-XruT6GlarWjIC5EIUsIO915GK3xbdFLE';
  
  // Payment methods supported by Chapa
  static const List<String> paymentMethods = ['telebirr', 'cbebirr', 'mpesa', 'ebirr'];
  
  // Default currency
  static const String defaultCurrency = 'ETB';
}
