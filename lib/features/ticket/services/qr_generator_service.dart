// Removed unused import
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

  // Update the ticket status in Firestore
  static Future<String> updateTicketStatus(String ticketId) async {
    try {
      // Check if this is a ticket_number (10 chars) or an actual Firestore document ID
      if (ticketId.length == 10) {
        // This is likely a ticket_number, not a document ID
        // We need to find the actual document using this ticket_number
        final querySnapshot = await _ticketsCollection
            .where('ticket_number', isEqualTo: ticketId)
            .limit(1)
            .get();
            
        if (querySnapshot.docs.isNotEmpty) {
          // Found the document, use its ID
          String actualDocId = querySnapshot.docs.first.id;
          
          final statusData = {
            'status': 'confirmed',  // Status can be: confirmed, used, refunded
          };
          
          // Update the existing ticket document with status data
          await _ticketsCollection.doc(actualDocId).update(statusData);
          print('Ticket updated with status: confirmed using correct doc ID: $actualDocId');
          
          return ticketId;
        } else {
          print('No ticket found with ticket_number: $ticketId');
          return ticketId;
        }
      } else {
        // This looks like an actual document ID, proceed normally
        final statusData = {
          'status': 'confirmed',  // Status can be: confirmed, used, refunded
        };
        
        // Update the existing ticket document with status data
        await _ticketsCollection.doc(ticketId).update(statusData);
        print('Ticket updated with status: confirmed');
        
        return ticketId;
      }
    } catch (e) {
      print('Error updating ticket status: $e');
      return ticketId;
    }
  }

  // Generate QR code data with ticket details
  static Future<String> generateQRData(String ticketId, String firstName, String lastName, 
      String departure, String arrival, DateTime date) async {
    // Update ticket status in Firebase if needed
    await updateTicketStatus(ticketId);
    
    // Try to get the ticket_number from Firestore
    try {
      DocumentSnapshot ticketDoc = await _ticketsCollection.doc(ticketId).get();
      if (ticketDoc.exists) {
        Map<String, dynamic> ticketData = ticketDoc.data() as Map<String, dynamic>;
        String ticketNumber = ticketData['ticket_number'] ?? '';
        if (ticketNumber.isNotEmpty) {
          return ticketNumber; // Return the ticket_number if available
        }
      }
    } catch (e) {
      print('Error fetching ticket_number from Firestore: $e');
    }
    
    // Return the ticket ID as fallback if ticket_number is not available
    return ticketId;
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
