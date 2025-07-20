// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'appointment_model.dart'; // Import your appointment model
//
// class EmailTemplates {
//   static String doctorRequest(Appointment appointment, String baseUrl, BuildContext context) {
//     return '''
//       <h2>New Appointment Request</h2>
//       <p>Patient: ${appointment.userName}</p>
//       <p>Date: ${DateFormat('MMM dd, yyyy').format(appointment.date)}</p>
//       <p>Time: ${appointment.time.format(context)}</p>
//       <div>
//         <a href="$baseUrl/confirm?appointmentId=${appointment.id}">
//           Confirm Appointment
//         </a>
//         <a href="$baseUrl/cancel?appointmentId=${appointment.id}">
//           Cancel Appointment
//         </a>
//       </div>
//     ''';
//   }
//
//   static String userConfirmation(Appointment appointment, BuildContext context) {
//     return '''
//       <h2>Your Appointment Has Been Confirmed</h2>
//       <p>With: ${appointment.dermatologistName}</p>
//       <p>Date: ${DateFormat('MMM dd, yyyy').format(appointment.date)}</p>
//       <p>Time: ${appointment.time.format(context)}</p>
//       <p>Contact: ${appointment.dermatologistPhone ?? 'N/A'}</p>
//     ''';
//   }
//
//   static String cancellationNotice(Appointment appointment, BuildContext context) {
//     return '''
//       <h2>Appointment Cancellation Notice</h2>
//       <p>Your appointment with ${appointment.dermatologistName} has been cancelled.</p>
//       <p>Original Date: ${DateFormat('MMM dd, yyyy').format(appointment.date)}</p>
//       <p>Time: ${appointment.time.format(context)}</p>
//       ${appointment.cancellationReason != null ?
//     '<p>Reason: ${appointment.cancellationReason}</p>' : ''}
//     ''';
//   }
// }

import 'package:intl/intl.dart';
import 'appointment_model.dart';

class EmailTemplates {
  // Helper function to format time using raw hour and minute values
  static String _formatTime(int hour, int minute) {
    // Convert to 12-hour format
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12
        ? hour - 12
        : (hour == 0 ? 12 : hour);

    // Format minute with leading zero
    final formattedMinute = minute.toString().padLeft(2, '0');

    return '$displayHour:$formattedMinute $period';
  }

  static String doctorRequestEmail(
      Appointment appointment,
      String confirmUrl,
      String cancelUrl,
      ) {
    return '''
      <h2>New Appointment Request</h2>
      <p>Patient: ${appointment.userName}</p>
      <p>Date: ${DateFormat('MMM dd, yyyy').format(appointment.date)}</p>
      <p>Time: ${_formatTime(appointment.time.hour, appointment.time.minute)}</p>
      <div style="margin-top: 20px;">
        <a href="$confirmUrl" style="
          display: inline-block;
          padding: 10px 20px;
          background-color: #4CAF50;
          color: white;
          text-decoration: none;
          border-radius: 4px;
          margin-right: 10px;
        ">Confirm Appointment</a>
        
        <a href="$cancelUrl" style="
          display: inline-block;
          padding: 10px 20px;
          background-color: #f44336;
          color: white;
          text-decoration: none;
          border-radius: 4px;
        ">Cancel Appointment</a>
      </div>
    ''';
  }

  static String userConfirmationEmail(Appointment appointment) {
    return '''
      <h2>Your Appointment Has Been Confirmed</h2>
      <p>With: Dr. ${appointment.dermatologistName}</p>
      <p>Date: ${DateFormat('MMM dd, yyyy').format(appointment.date)}</p>
      <p>Time: ${_formatTime(appointment.time.hour, appointment.time.minute)}</p>
      <p>Consultation Fee: Rs. ${appointment.consultationFee.toStringAsFixed(2)}</p>
      <p>Contact: ${appointment.dermatologistPhone ?? 'N/A'}</p>
    ''';
  }

  static String cancellationNoticeEmail(Appointment appointment) {
    return '''
      <h2>Appointment Cancellation Notice</h2>
      <p>Your appointment with Dr. ${appointment.dermatologistName} has been cancelled.</p>
      <p>Original Date: ${DateFormat('MMM dd, yyyy').format(appointment.date)}</p>
      <p>Time: ${_formatTime(appointment.time.hour, appointment.time.minute)}</p>
      ${appointment.cancellationReason != null ? '<p>Reason: ${appointment.cancellationReason}</p>' : ''}
      <p>Refund Status: Your consultation fee will be refunded within 3-5 business days</p>
    ''';
  }
}