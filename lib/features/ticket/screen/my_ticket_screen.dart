import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/features/ticket/models/ticket_model.dart';
import 'package:flutter_application_2/features/ticket/screen/ticket_view_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class MyTicketScreen extends StatefulWidget {
  const MyTicketScreen({Key? key}) : super(key: key);

  @override
  State<MyTicketScreen> createState() => _MyTicketScreenState();
}

class _MyTicketScreenState extends State<MyTicketScreen> {
  final TextEditingController _ticketNumberController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
  }
  


  @override
  void dispose() {
    _ticketNumberController.dispose();
    super.dispose();
  }

  Future<void> _lookupTicket() async {
    final String ticketNumber = _ticketNumberController.text.trim();
    
    if (ticketNumber.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a ticket number';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Query Firestore for the ticket using ticket_number field
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('tickets')
          .where('ticket_number', isEqualTo: ticketNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Ticket not found. Please check the ticket number and try again.';
        });
        return;
      }

      // Get the first document from the query results
      final DocumentSnapshot ticketDoc = querySnapshot.docs.first;
      
      // Create ticket model from document data
      final Map<String, dynamic> data = ticketDoc.data() as Map<String, dynamic>;
      final TicketModel ticket = TicketModel.fromJson(data, ticketDoc.id);

      setState(() {
        _isLoading = false;
      });

      // Navigate to ticket view screen
      Get.to(() => TicketViewScreen(ticket: ticket));
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error looking up ticket: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find My Ticket'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ticket lookup form
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter Your Ticket Number',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please enter your ticket number to access your ticket details',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _ticketNumberController,
                      decoration: InputDecoration(
                        labelText: 'Ticket Number',
                        hintText: 'Enter your 10-character ticket number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.confirmation_number_outlined),
                      ),
                      maxLength: 10, // Ensure exactly 10 characters
                      onSubmitted: (_) => _lookupTicket(),
                    ),
                    if (_errorMessage != null) ...[                      
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _lookupTicket,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : Text(
                                'Find My Ticket',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Instructions
            Text(
              'How to find your ticket',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildInstructionStep(
              context,
              number: '1',
              text: 'Enter your 10-character ticket number from your email',
            ),
            _buildInstructionStep(
              context,
              number: '2',
              text: 'Click "Find My Ticket" to view your ticket details',
            ),
            _buildInstructionStep(
              context,
              number: '3',
              text: 'You can download the QR code or send the ticket to your email again if needed',
            ),
          ],
        ),
      ),
    );
  }
  


  Widget _buildInstructionStep(
    BuildContext context, {
    required String number,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF1E40AF),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
