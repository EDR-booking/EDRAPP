import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../features/authentication/services/supabase_otp_service.dart';

class OtpVerificationDialog extends StatefulWidget {
  final String email;
  final Function() onVerified;

  const OtpVerificationDialog({
    Key? key,
    required this.email,
    required this.onVerified,
  }) : super(key: key);

  @override
  _OtpVerificationDialogState createState() => _OtpVerificationDialogState();
}

class _OtpVerificationDialogState extends State<OtpVerificationDialog> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _otpService = SupabaseOtpService();
  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final isValid = await _otpService.verifyOTP(widget.email, _otpController.text);
      
      if (isValid) {
        Navigator.of(context).pop(); // Close the dialog
        widget.onVerified();
      } else {
        setState(() {
          _errorMessage = 'Invalid OTP. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendOTP() async {
    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    try {
      final success = await _otpService.sendOTP(widget.email);
      if (!success) {
        setState(() {
          _errorMessage = 'Failed to resend OTP. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Verify Your Email'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('We sent a 6-digit verification code to ${widget.email}'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Enter OTP',
                border: OutlineInputBorder(),
                counterText: '',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the OTP';
                }
                if (value.length != 6) {
                  return 'OTP must be 6 digits';
                }
                return null;
              },
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isResending
              ? null
              : () {
                  _resendOTP();
                },
          child: _isResending
              ? const Text('Sending...')
              : const Text('Resend Code'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _verifyOTP,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Verify'),
        ),
      ],
    );
  }
}
