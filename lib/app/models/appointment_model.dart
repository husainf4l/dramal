import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum AppointmentStatus {
  scheduled,
  confirmed,
  completed,
  cancelled,
  noShow,
}

extension AppointmentStatusExtension on AppointmentStatus {
  String get displayName {
    switch (this) {
      case AppointmentStatus.scheduled:
        return 'Scheduled';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.noShow:
        return 'No Show';
    }
  }

  Color get color {
    switch (this) {
      case AppointmentStatus.scheduled:
        return Colors.blue;
      case AppointmentStatus.confirmed:
        return Colors.green;
      case AppointmentStatus.completed:
        return Colors.grey;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.noShow:
        return Colors.orange;
    }
  }
}

class AppointmentData {
  final String id;
  final String kidId;
  final String doctorName;
  final String doctorSpecialty;
  final String clinicName;
  final DateTime appointmentDate;
  final TimeOfDay appointmentTime;
  final Duration duration;
  final String appointmentType;
  final String reason;
  final AppointmentStatus status;
  final String location;
  final String phoneNumber;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppointmentData({
    required this.id,
    required this.kidId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.clinicName,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.duration,
    required this.appointmentType,
    required this.reason,
    required this.status,
    required this.location,
    required this.phoneNumber,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // Get full date and time
  DateTime get fullDateTime {
    return DateTime(
      appointmentDate.year,
      appointmentDate.month,
      appointmentDate.day,
      appointmentTime.hour,
      appointmentTime.minute,
    );
  }

  // Check if appointment is upcoming
  bool get isUpcoming {
    return fullDateTime.isAfter(DateTime.now());
  }

  // Check if appointment is today
  bool get isToday {
    final now = DateTime.now();
    return appointmentDate.year == now.year &&
           appointmentDate.month == now.month &&
           appointmentDate.day == now.day;
  }

  // Get time until appointment
  Duration get timeUntilAppointment {
    return fullDateTime.difference(DateTime.now());
  }

  // Get formatted appointment time
  String get formattedTime {
    final hour = appointmentTime.hourOfPeriod;
    final minute = appointmentTime.minute.toString().padLeft(2, '0');
    final period = appointmentTime.period.name.toUpperCase();
    return '$hour:$minute $period';
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kidId': kidId,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'clinicName': clinicName,
      'appointmentDate': appointmentDate.toIso8601String(),
      'appointmentTime': '${appointmentTime.hour}:${appointmentTime.minute}',
      'duration': duration.inMinutes,
      'appointmentType': appointmentType,
      'reason': reason,
      'status': status.name,
      'location': location,
      'phoneNumber': phoneNumber,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory AppointmentData.fromJson(Map<String, dynamic> json) {
    final timeParts = (json['appointmentTime'] as String).split(':');
    return AppointmentData(
      id: json['id'],
      kidId: json['kidId'],
      doctorName: json['doctorName'],
      doctorSpecialty: json['doctorSpecialty'],
      clinicName: json['clinicName'],
      appointmentDate: DateTime.parse(json['appointmentDate']),
      appointmentTime: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      duration: Duration(minutes: json['duration']),
      appointmentType: json['appointmentType'],
      reason: json['reason'],
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AppointmentStatus.scheduled,
      ),
      location: json['location'],
      phoneNumber: json['phoneNumber'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class AppointmentController extends GetxController {
  final RxList<AppointmentData> appointments = <AppointmentData>[].obs;
  final RxBool isLoading = false.obs;

  // Get appointments for specific kid
  List<AppointmentData> getAppointmentsForKid(String kidId) {
    return appointments.where((appt) => appt.kidId == kidId).toList();
  }

  // Get upcoming appointments
  List<AppointmentData> get upcomingAppointments {
    final now = DateTime.now();
    return appointments.where((appt) =>
      appt.fullDateTime.isAfter(now) &&
      appt.status != AppointmentStatus.cancelled
    ).toList()
    ..sort((a, b) => a.fullDateTime.compareTo(b.fullDateTime));
  }

  // Get today's appointments
  List<AppointmentData> get todaysAppointments {
    final now = DateTime.now();
    return appointments.where((appt) =>
      appt.appointmentDate.year == now.year &&
      appt.appointmentDate.month == now.month &&
      appt.appointmentDate.day == now.day
    ).toList()
    ..sort((a, b) => a.appointmentTime.hour.compareTo(b.appointmentTime.hour));
  }

  // Get appointments by status
  List<AppointmentData> getAppointmentsByStatus(AppointmentStatus status) {
    return appointments.where((appt) => appt.status == status).toList();
  }

  // Add new appointment
  void addAppointment(AppointmentData appointment) {
    appointments.add(appointment);
    appointments.sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
  }

  // Update appointment status
  void updateAppointmentStatus(String appointmentId, AppointmentStatus newStatus) {
    final index = appointments.indexWhere((appt) => appt.id == appointmentId);
    if (index != -1) {
      final updatedAppointment = AppointmentData(
        id: appointments[index].id,
        kidId: appointments[index].kidId,
        doctorName: appointments[index].doctorName,
        doctorSpecialty: appointments[index].doctorSpecialty,
        clinicName: appointments[index].clinicName,
        appointmentDate: appointments[index].appointmentDate,
        appointmentTime: appointments[index].appointmentTime,
        duration: appointments[index].duration,
        appointmentType: appointments[index].appointmentType,
        reason: appointments[index].reason,
        status: newStatus,
        location: appointments[index].location,
        phoneNumber: appointments[index].phoneNumber,
        notes: appointments[index].notes,
        createdAt: appointments[index].createdAt,
        updatedAt: DateTime.now(),
      );
      appointments[index] = updatedAppointment;
    }
  }

  // Get next appointment for kid
  AppointmentData? getNextAppointment(String kidId) {
    final kidAppointments = getAppointmentsForKid(kidId)
      .where((appt) => appt.isUpcoming && appt.status != AppointmentStatus.cancelled)
      .toList()
      ..sort((a, b) => a.fullDateTime.compareTo(b.fullDateTime));

    return kidAppointments.isNotEmpty ? kidAppointments.first : null;
  }
}
