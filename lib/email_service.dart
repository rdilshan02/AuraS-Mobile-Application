import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'appointment_model.dart';
import 'package:skincare_app/email_templates.dart';

class EmailService {
  // Replace with your actual email service configuration
  static const String _baseUrl = 'https://your-backend-server.com/api';
  static const String _apiKey = 'your-email-service-api-key';

  // For this example, I'll use a generic HTTP service
  // You can replace this with your preferred email service (SendGrid, Mailgun, etc.)

  Future<void> sendAppointmentRequestEmail(Appointment appointment) async {
    try {
      final confirmUrl = '$_baseUrl/confirm-appointment?appointmentId=${appointment.id}';
      final cancelUrl = '$_baseUrl/cancel-appointment?appointmentId=${appointment.id}';

      final emailBody = EmailTemplates.doctorRequestEmail(
          appointment,
          confirmUrl,
          cancelUrl
      );

      await _sendEmail(
        to: appointment.dermatologistEmail,
        subject: 'New Appointment Request from ${appointment.userName}',
        htmlBody: emailBody,
      );

      debugPrint('Appointment request email sent to: ${appointment.dermatologistEmail}');
    } catch (e) {
      debugPrint('Error sending appointment request email: $e');
      throw Exception('Failed to send appointment request email: $e');
    }
  }

  Future<void> sendAppointmentConfirmationEmail(Appointment appointment) async {
    try {
      final emailBody = EmailTemplates.userConfirmationEmail(appointment);

      await _sendEmail(
        to: appointment.userEmail,
        subject: 'Appointment Confirmed with Dr. ${appointment.dermatologistName}',
        htmlBody: emailBody,
      );

      debugPrint('Confirmation email sent to: ${appointment.userEmail}');
    } catch (e) {
      debugPrint('Error sending confirmation email: $e');
      throw Exception('Failed to send confirmation email: $e');
    }
  }

  Future<void> sendAppointmentCancellationEmail(Appointment appointment) async {
    try {
      final emailBody = EmailTemplates.cancellationNoticeEmail(appointment);

      await _sendEmail(
        to: appointment.userEmail,
        subject: 'Appointment Cancellation Notice',
        htmlBody: emailBody,
      );

      debugPrint('Cancellation email sent to: ${appointment.userEmail}');
    } catch (e) {
      debugPrint('Error sending cancellation email: $e');
      throw Exception('Failed to send cancellation email: $e');
    }
  }

  Future<void> _sendEmail({
    required String to,
    required String subject,
    required String htmlBody,
  }) async {
    try {
      // Example implementation using a generic HTTP service
      // Replace this with your actual email service implementation

      final response = await http.post(
        Uri.parse('$_baseUrl/send-email'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'to': to,
          'subject': subject,
          'html': htmlBody,
          'from': 'noreply@yourskincare.app',
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Email service responded with status: ${response.statusCode}');
      }

      debugPrint('Email sent successfully to: $to');
    } catch (e) {
      debugPrint('Error in _sendEmail: $e');
      throw Exception('Failed to send email: $e');
    }
  }

  // Alternative implementation using Firebase Cloud Functions
  // You can use this instead of the HTTP service above
  Future<void> sendEmailViaCloudFunction({
    required String to,
    required String subject,
    required String htmlBody,
    required String type,
  }) async {
    try {
      // This would call your Firebase Cloud Function
      final response = await http.post(
        Uri.parse('https://your-project.cloudfunctions.net/sendEmail'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'to': to,
          'subject': subject,
          'html': htmlBody,
          'type': type,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Cloud function responded with status: ${response.statusCode}');
      }

      debugPrint('Email sent via Cloud Function to: $to');
    } catch (e) {
      debugPrint('Error sending email via Cloud Function: $e');
      throw Exception('Failed to send email via Cloud Function: $e');
    }
  }
}