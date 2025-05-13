import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QRGeneratorService {
  // Collection reference for tickets
  static final CollectionReference _ticketsCollection = 
      FirebaseFirestore.instance.collection('tickets');

  // Update ticket status in Firebase
  static Future<String> updateTicketStatus(String ticketId) async {
    try {
      // Create verification data to update the ticket
      final Map<String, dynamic> statusData = {
        'status': 'unused',  // Status can be: unused, used, expired
        'issuedAt': FieldValue.serverTimestamp(),
        'isVerified': false,
        'verifiedAt': null,
        'verifiedBy': null,
      };
      
      // Update the existing ticket document with status data
      await _ticketsCollection.doc(ticketId).update(statusData);
      print('Ticket updated with status: unused');
      
      return ticketId;
    } catch (e) {
      print('Error updating ticket status: $e');
      return ticketId;
    }
  }

  // Generate QR code data based on ticket information
  static Future<String> generateQRData(String ticketId, String firstName, String lastName, 
      String departure, String arrival, DateTime date) async {
    // Update ticket status in Firebase
    await updateTicketStatus(ticketId);
    
    // Create a simple map with essential ticket data - using ticketId directly
    final Map<String, dynamic> ticketData = {
      'id': ticketId,
      'firstName': firstName,
      'lastName': lastName,
      'departure': departure,
      'arrival': arrival,
      'date': date.millisecondsSinceEpoch,
      'issuedAt': DateTime.now().millisecondsSinceEpoch,
    };
    
    // Convert to JSON string and encode to base64 for security
    return base64Encode(utf8.encode(jsonEncode(ticketData)));
  }
  
  // Generate a QR code widget with the provided data
  static QrImageView generateQRCodeWidget(String data, {double size = 200}) {
    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: size,
      backgroundColor: const Color(0xFFFFFFFF),
      errorCorrectionLevel: QrErrorCorrectLevel.H,
      gapless: true,
      // Removed embedded image to avoid asset loading errors
    );
  }
  
  // Generate a QR code image as bytes (more reliable than trying to render a widget)
  static Future<Uint8List> generateQRImageBytes(String data, {double size = 200}) async {
    try {
      // Create a QR painter
      final qrPainter = QrPainter(
        data: data,
        version: QrVersions.auto,
        color: Colors.black,
        emptyColor: Colors.white,
        gapless: true,
        errorCorrectionLevel: QrErrorCorrectLevel.H,
      );
      
      // Calculate size with padding
      final padding = 20.0;
      final fullSize = size + (padding * 2);
      
      // Create a PictureRecorder and Canvas
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      
      // Fill with white background
      canvas.drawRect(
        Rect.fromLTWH(0, 0, fullSize, fullSize),
        Paint()..color = Colors.white,
      );
      
      // Paint the QR code at position with padding
      canvas.save();
      canvas.translate(padding, padding);
      qrPainter.paint(canvas, Size(size, size));
      canvas.restore();
      
      // Convert to image
      final picture = recorder.endRecording();
      final img = await picture.toImage(fullSize.toInt(), fullSize.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        throw Exception('Failed to generate QR image bytes');
      }
      
      return byteData.buffer.asUint8List();
    } catch (e) {
      print('Error generating QR image bytes: $e');
      throw Exception('Failed to generate QR image bytes: $e');
    }
  }
}
