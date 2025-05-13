import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/ticket/models/ticket_model.dart';

class TicketRepository {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'tickets';

  // Create a new ticket
  Future<String> createTicket(TicketModel ticket) async {
    try {
      // Generate a document reference if ticket.id is null
      final DocumentReference docRef = ticket.id == null 
          ? _db.collection(_collection).doc() 
          : _db.collection(_collection).doc(ticket.id);
      
      // Save the ticket data
      await docRef.set(ticket.toJson());
      
      // Return the document ID
      return docRef.id;
    } catch (e) {
      throw 'Error creating ticket: $e';
    }
  }

  // Get all tickets
  Stream<List<TicketModel>> getAllTickets() {
    return _db
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TicketModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  // Get tickets by email
  Stream<List<TicketModel>> getTicketsByEmail(String email) {
    return _db
        .collection(_collection)
        .where('email', isEqualTo: email)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TicketModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  // Get tickets by date
  Stream<List<TicketModel>> getTicketsByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _db
        .collection(_collection)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('date')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TicketModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  // Get a single ticket
  Future<TicketModel?> getTicket(String ticketId) async {
    try {
      final doc = await _db.collection(_collection).doc(ticketId).get();
      if (doc.exists) {
        return TicketModel.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw 'Error getting ticket: $e';
    }
  }

  // Update a ticket
  Future<void> updateTicket(String ticketId, TicketModel ticket) async {
    try {
      await _db.collection(_collection).doc(ticketId).update(ticket.toJson());
    } catch (e) {
      throw 'Error updating ticket: $e';
    }
  }

  // Delete a ticket
  Future<void> deleteTicket(String ticketId) async {
    try {
      await _db.collection(_collection).doc(ticketId).delete();
    } catch (e) {
      throw 'Error deleting ticket: $e';
    }
  }

  // Update ticket status
  Future<void> updateTicketStatus(String ticketId, String status) async {
    try {
      // First, verify the document exists to avoid not-found errors
      final docSnapshot = await _db.collection(_collection).doc(ticketId).get();
      
      if (!docSnapshot.exists) {
        print('Warning: Document $ticketId not found');
        return; // Silently return if document doesn't exist (alternative to throwing exception)
      }
      
      await _db.collection(_collection).doc(ticketId).update({'status': status});
    } catch (e) {
      print('Error updating ticket status: $e');
      // Don't throw exception to prevent UI crashes
    }
  }
}
