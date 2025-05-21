import 'dart:async';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SmtpEmailService {
  static final SmtpEmailService _instance = SmtpEmailService._internal();
  
  // SMTP server configuration - these should be in your .env file
  late final String _smtpServer;
  late final int _smtpPort;
  late final String _username;
  late final String _password;
  late final String _fromEmail;
  late final String _fromName;
  
  // Initialize SMTP server
  late final SmtpServer _smtpServerConfig;
  
  factory SmtpEmailService() {
    return _instance;
  }
  
  SmtpEmailService._internal() {
    // Initialize SMTP configuration from environment variables
    _smtpServer = dotenv.get('SMTP_SERVER');
    _smtpPort = int.parse(dotenv.get('SMTP_PORT', fallback: '587'));
    _username = dotenv.get('SMTP_USERNAME');
    _password = dotenv.get('SMTP_PASSWORD');
    _fromEmail = dotenv.get('SMTP_FROM_EMAIL');
    _fromName = dotenv.get('SMTP_FROM_NAME', fallback: 'Ethiopian Railway');
    
    // Configure SMTP server
    _smtpServerConfig = SmtpServer(
      _smtpServer,
      port: _smtpPort,
      username: _username,
      password: _password,
      ssl: _smtpPort == 465, // Use SSL for port 465
      allowInsecure: _smtpPort != 465, // Allow insecure only for non-SSL ports
    );
  }
  
  // Send a ticket email with the ticket number
  Future<bool> sendTicketEmail({
    required String toEmail,
    required String ticketNumber,
    String? passengerName,
  }) async {
    try {
      // Create the email message
      final message = Message()
        ..from = Address(_fromEmail, _fromName)
        ..recipients.add(toEmail)
        ..subject = 'Your Ethiopian Railway Ticket #$ticketNumber'
        ..text = _buildPlainTextEmail(ticketNumber, passengerName)
        ..html = _buildHtmlEmail(ticketNumber, passengerName);
      
      // Send the email
      final sendReport = await send(message, _smtpServerConfig);
      
      // Check if the email was sent successfully
      return sendReport != null;
    } catch (e) {
      print('Error sending email: $e');
      return false;
    }
  }
  
  String _buildPlainTextEmail(String ticketNumber, String? passengerName) {
    return '''
Ethiopian Railway - Ticket Confirmation

Dear ${passengerName ?? 'Valued Passenger'},

Thank you for booking with Ethiopian Railway. Your ticket has been confirmed.

Ticket Number: $ticketNumber

Please present this ticket number at the station to board the train. We recommend arriving at least 30 minutes before departure.

For any inquiries, please contact our customer service.

Safe travels,
Ethiopian Railway Team
''';
  }
  
  String _buildHtmlEmail(String ticketNumber, String? passengerName) {
    return '''
<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background-color: #006341; color: white; padding: 20px; text-align: center; }
        .content { padding: 20px; background-color: #f9f9f9; }
        .ticket-number { 
            font-size: 24px; 
            font-weight: bold; 
            color: #006341;
            text-align: center;
            margin: 20px 0;
            padding: 15px;
            background-color: #e6f2ed;
            border-left: 5px solid #006341;
        }
        .footer { 
            margin-top: 20px; 
            font-size: 12px; 
            color: #777; 
            text-align: center; 
            padding: 10px; 
            border-top: 1px solid #eee;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Ethiopian Railway</h1>
            <h2>Ticket Confirmation</h2>
        </div>
        
        <div class="content">
            <p>Dear ${passengerName ?? 'Valued Passenger'},</p>
            
            <p>Thank you for booking with Ethiopian Railway. Your ticket has been confirmed.</p>
            
            <div class="ticket-number">
                Ticket Number: $ticketNumber
            </div>
            
            <p>Please present this ticket number at the station to board the train. We recommend arriving at least 30 minutes before departure.</p>
            
            <p>For any inquiries, please contact our customer service.</p>
            
            <p>Safe travels,<br>The Ethiopian Railway Team</p>
        </div>
        
        <div class="footer">
            <p>This is an automated message. Please do not reply to this email.</p>
            <p>© ${DateTime.now().year} Ethiopian Railway. All rights reserved.</p>
        </div>
    </div>
</body>
</html>
''';
  }
}
