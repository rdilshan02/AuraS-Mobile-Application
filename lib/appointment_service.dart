import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'appointment_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'email_service.dart';

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final EmailService _emailService = EmailService();

  // Enhanced booking with email notification
  Future<void> bookAppointment(Appointment appointment) async {
    try {
      debugPrint('Starting booking process...');
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');
      debugPrint('User UID: ${user.uid}');

      // Fetch user details from 'users' collection
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      debugPrint('User document exists: ${userDoc.exists}');
      if (!userDoc.exists) throw Exception('User document not found');

      final userData = userDoc.data()!;

      // Extract user details
      final userEmail = userData['email']?.toString() ?? '';
      final userPhone = userData['phoneNumber']?.toString() ?? '';
      final userName = userData['username']?.toString() ?? '';

      debugPrint('''
      Extracted user details:
      Email: $userEmail
      Phone: $userPhone
      Username: $userName
      ''');

      // Validate required fields
      if (userEmail.isEmpty) throw Exception('User email missing');
      if (userPhone.isEmpty) throw Exception('User phone missing');
      if (userName.isEmpty) throw Exception('Username missing');

      // Create complete appointment with user details
      final completeAppointment = appointment.copyWith(
        userId: user.uid,
        userEmail: userEmail,
        userPhone: userPhone,
        userName: userName,
      );

      debugPrint('Complete appointment: ${completeAppointment.toFirestore()}');

      // Save appointment to Firestore
      await _firestore
          .collection('appointments')
          .doc(appointment.id)
          .set(completeAppointment.toFirestore());

      debugPrint('Appointment successfully written to Firestore');

      // Send email notification to dermatologist
      await _emailService.sendAppointmentRequestEmail(completeAppointment);
      debugPrint('Email sent to dermatologist');

    } catch (e) {
      debugPrint('Error booking appointment: $e');
      throw Exception('Failed to book appointment: $e');
    }
  }

  // Get appointments for a specific user - Fixed to avoid index requirement
  Stream<List<Appointment>> getUserAppointments(String userId) {
    return _firestore
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      var appointments = snapshot.docs
          .map((doc) => Appointment.fromFirestore(doc))
          .toList();

      // Sort in Dart instead of Firestore to avoid index requirement
      appointments.sort((a, b) => a.date.compareTo(b.date));

      return appointments;
    });
  }

  // Get appointments for a specific dermatologist - Fixed to avoid potential index issues
  Stream<List<Appointment>> getDermatologistAppointments(String dermatologistId) {
    return _firestore
        .collection('appointments')
        .where('dermatologistId', isEqualTo: dermatologistId)
        .snapshots()
        .map((snapshot) {
      var appointments = snapshot.docs
          .map((doc) => Appointment.fromFirestore(doc))
          .toList();

      // Sort in Dart instead of Firestore
      appointments.sort((a, b) => a.date.compareTo(b.date));

      return appointments;
    });
  }

  // Check slot availability
  // Future<bool> isSlotAvailable(
  //     String dermatologistId, DateTime date, TimeOfDay time) async {
  //   try {
  //     final snapshot = await _firestore
  //         .collection('appointments')
  //         .where('dermatologistId', isEqualTo: dermatologistId)
  //         .where('date', isEqualTo: Timestamp.fromDate(date))
  //         .where('status', whereNotIn: ['cancelled'])
  //         .get();
  //
  //     final hour = time.hour;
  //     final minute = time.minute;
  //
  //     return !snapshot.docs.any((doc) {
  //       final data = doc.data();
  //       return data['time']['hour'] == hour && data['time']['minute'] == minute;
  //     });
  //   } catch (e) {
  //     debugPrint('Error checking slot availability: $e');
  //     return false;
  //   }
  Future<bool> isSlotAvailable(
      String dermatologistId,
      DateTime date,
      TimeOfDay time,
      ) async {
    try {
      // Normalize date to UTC to avoid timezone issues
      final utcDate = DateTime.utc(date.year, date.month, date.day);
      final nextDay = utcDate.add(const Duration(days: 1));

      // Query Firestore for overlapping appointments
      final QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .where('dermatologistId', isEqualTo: dermatologistId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(utcDate))
          .where('date', isLessThan: Timestamp.fromDate(nextDay))
          .where('status', whereIn: ['pending', 'confirmed'])
          .get();

      // Convert time to minutes for easier comparison
      final selectedMinutes = time.hour * 60 + time.minute;

      // Check if any appointment overlaps with the selected time
      final isSlotTaken = snapshot.docs.any((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final timeData = data['time'] as Map<String, dynamic>;
        final appointmentMinutes = timeData['hour'] * 60 + timeData['minute'];

        // Consider appointments within the same time slot
        return appointmentMinutes == selectedMinutes;
      });

      return !isSlotTaken;
    } catch (e) {
      debugPrint("Error checking slot availability: $e");
      return false;
    }

  }

  // Confirm appointment (called via email link)
  Future<void> confirmAppointment(String appointmentId) async {
    try {
      final appointmentDoc = await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .get();

      if (!appointmentDoc.exists) {
        throw Exception('Appointment not found');
      }

      final appointment = Appointment.fromFirestore(appointmentDoc);

      // Update appointment status
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'confirmed',
        'confirmedAt': FieldValue.serverTimestamp(),
      });

      // Send confirmation email to user
      final updatedAppointment = appointment.copyWith(
        status: 'confirmed',
        confirmedAt: DateTime.now(),
      );

      await _emailService.sendAppointmentConfirmationEmail(updatedAppointment);
      debugPrint('Confirmation email sent to user');

    } catch (e) {
      debugPrint('Error confirming appointment: $e');
      throw Exception('Failed to confirm appointment: $e');
    }
  }

  // Cancel appointment with reason
  Future<void> cancelAppointment(String appointmentId, String reason) async {
    try {
      final appointmentDoc = await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .get();

      if (!appointmentDoc.exists) {
        throw Exception('Appointment not found');
      }

      final appointment = Appointment.fromFirestore(appointmentDoc);

      // Update appointment status
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'cancelled',
        'cancellationReason': reason,
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      // Send cancellation email to user
      final updatedAppointment = appointment.copyWith(
        status: 'cancelled',
        cancellationReason: reason,
        cancelledAt: DateTime.now(),
      );

      await _emailService.sendAppointmentCancellationEmail(updatedAppointment);
      debugPrint('Cancellation email sent to user');

    } catch (e) {
      debugPrint('Error cancelling appointment: $e');
      throw Exception('Failed to cancel appointment: $e');
    }
  }

  // Get appointment by ID
  Future<Appointment?> getAppointmentById(String appointmentId) async {
    try {
      final doc = await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .get();

      if (!doc.exists) return null;

      return Appointment.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error getting appointment: $e');
      return null;
    }
  }

  // Get appointments by status - FIXED to avoid composite index requirement
  Stream<List<Appointment>> getAppointmentsByStatus(String userId, String status) {
    return _firestore
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: status)
    // Removed orderBy to avoid composite index requirement
        .snapshots()
        .map((snapshot) {
      var appointments = snapshot.docs
          .map((doc) => Appointment.fromFirestore(doc))
          .toList();

      // Sort by date in Dart instead of Firestore
      appointments.sort((a, b) => a.date.compareTo(b.date));

      return appointments;
    });
  }

  // Alternative method if you want to optimize further by querying all user appointments
  // and filtering by status in Dart (useful if you have many status filters)
  Stream<List<Appointment>> getAppointmentsByStatusOptimized(String userId, String status) {
    return _firestore
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      var appointments = snapshot.docs
          .map((doc) => Appointment.fromFirestore(doc))
          .where((appointment) => appointment.status.toLowerCase() == status.toLowerCase())
          .toList();

      // Sort by date
      appointments.sort((a, b) => a.date.compareTo(b.date));

      return appointments;
    });
  }

  // Get all appointments for a user (useful for dashboard/overview)
  Stream<List<Appointment>> getAllUserAppointments(String userId) {
    return _firestore
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      var appointments = snapshot.docs
          .map((doc) => Appointment.fromFirestore(doc))
          .toList();

      // Sort by date (newest first for overview)
      appointments.sort((a, b) => b.date.compareTo(a.date));

      return appointments;
    });
  }

  // Get recent appointments (last 30 days)
  Stream<List<Appointment>> getRecentAppointments(String userId) {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    return _firestore
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(thirtyDaysAgo))
        .snapshots()
        .map((snapshot) {
      var appointments = snapshot.docs
          .map((doc) => Appointment.fromFirestore(doc))
          .toList();

      appointments.sort((a, b) => b.date.compareTo(a.date));

      return appointments;
    });
  }

  // Get upcoming appointments
  Stream<List<Appointment>> getUpcomingAppointments(String userId) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    return _firestore
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('status', whereIn: ['pending', 'confirmed'])
        .snapshots()
        .map((snapshot) {
      var appointments = snapshot.docs
          .map((doc) => Appointment.fromFirestore(doc))
          .toList();

      appointments.sort((a, b) => a.date.compareTo(b.date));

      return appointments;
    });
  }
}