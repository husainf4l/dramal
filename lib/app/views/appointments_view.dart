import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../data/demo_data_provider.dart';
import '../models/appointment_model.dart';
import '../models/kid_model.dart';
import '../controllers/kid_controller.dart';

class AppointmentsView extends StatefulWidget {
  const AppointmentsView({Key? key}) : super(key: key);

  @override
  State<AppointmentsView> createState() => _AppointmentsViewState();
}

class _AppointmentsViewState extends State<AppointmentsView>
    with SingleTickerProviderStateMixin {
  final KidController kidController = Get.find<KidController>();
  late List<AppointmentData> appointments;
  late TabController _tabController;
  late KidData selectedKid;

  @override
  void initState() {
    super.initState();
    selectedKid = kidController.selectedKid.value ?? DemoDataProvider.getDemoKids().first;
    appointments = DemoDataProvider.getDemoAppointments(selectedKid.id);
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        backgroundColor: Theme.of(context).primaryColor,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming', icon: Icon(Icons.schedule)),
            Tab(text: 'Today', icon: Icon(Icons.today)),
            Tab(text: 'All', icon: Icon(Icons.calendar_view_month)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddAppointmentDialog(),
            tooltip: 'Schedule Appointment',
          ),
        ],
      ),
      body: Column(
        children: [
          // Kid Selector
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Obx(() {
              final kids = kidController.kids;
              if (kids.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Child',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<KidData>(
                    value: selectedKid,
                    isExpanded: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: kids.map((kid) {
                      return DropdownMenuItem<KidData>(
                        value: kid,
                        child: Text(kid.name),
                      );
                    }).toList(),
                    onChanged: (KidData? newKid) {
                      if (newKid != null) {
                        setState(() {
                          selectedKid = newKid;
                          appointments = DemoDataProvider.getDemoAppointments(newKid.id);
                        });
                      }
                    },
                  ),
                ],
              );
            }),
          ),

          // Appointments List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAppointmentsList(_getUpcomingAppointments()),
                _buildAppointmentsList(_getTodaysAppointments()),
                _buildAppointmentsList(appointments),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<AppointmentData> _getUpcomingAppointments() {
    final now = DateTime.now();
    return appointments
      .where((appt) => appt.fullDateTime.isAfter(now) &&
                      appt.status != AppointmentStatus.cancelled)
      .toList()
      ..sort((a, b) => a.fullDateTime.compareTo(b.fullDateTime));
  }

  List<AppointmentData> _getTodaysAppointments() {
    final now = DateTime.now();
    return appointments
      .where((appt) => appt.appointmentDate.year == now.year &&
                      appt.appointmentDate.month == now.month &&
                      appt.appointmentDate.day == now.day)
      .toList()
      ..sort((a, b) => a.appointmentTime.hour.compareTo(b.appointmentTime.hour));
  }

  Widget _buildAppointmentsList(List<AppointmentData> appointmentsList) {
    if (appointmentsList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 80,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No appointments found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to schedule a new appointment',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointmentsList.length,
      itemBuilder: (context, index) {
        final appointment = appointmentsList[index];
        return _buildAppointmentCard(appointment);
      },
    );
  }

  Widget _buildAppointmentCard(AppointmentData appointment) {
    final isToday = appointment.isToday;
    final isUpcoming = appointment.isUpcoming;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showAppointmentDetails(appointment),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status and type
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: appointment.status.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: appointment.status.color.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      appointment.status.displayName,
                      style: TextStyle(
                        color: appointment.status.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (isToday)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Today',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Doctor and clinic info
              Text(
                appointment.doctorName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                '${appointment.doctorSpecialty} • ${appointment.clinicName}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 8),

              // Appointment details
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM dd, yyyy').format(appointment.appointmentDate),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    appointment.formattedTime,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Location
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      appointment.location,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Reason
              if (appointment.reason.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          appointment.reason,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showAppointmentDetails(AppointmentData appointment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      appointment.appointmentType,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: appointment.status.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      appointment.status.displayName,
                      style: TextStyle(
                        color: appointment.status.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Doctor Info
              _buildDetailRow('Doctor', appointment.doctorName),
              _buildDetailRow('Specialty', appointment.doctorSpecialty),
              _buildDetailRow('Clinic', appointment.clinicName),

              const SizedBox(height: 16),

              // Date & Time
              _buildDetailRow('Date',
                DateFormat('EEEE, MMMM dd, yyyy').format(appointment.appointmentDate)),
              _buildDetailRow('Time', appointment.formattedTime),
              _buildDetailRow('Duration', '${appointment.duration.inMinutes} minutes'),

              const SizedBox(height: 16),

              // Location & Contact
              _buildDetailRow('Location', appointment.location),
              _buildDetailRow('Phone', appointment.phoneNumber),

              const SizedBox(height: 16),

              // Reason & Notes
              if (appointment.reason.isNotEmpty)
                _buildDetailRow('Reason', appointment.reason),

              if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Notes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  appointment.notes!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Call clinic
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Calling ${appointment.phoneNumber}')),
                        );
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('Call Clinic'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to location
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Opening maps...')),
                        );
                      },
                      icon: const Icon(Icons.directions),
                      label: const Text('Get Directions'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAppointmentDialog() {
    final doctorController = TextEditingController();
    final clinicController = TextEditingController();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Appointment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: doctorController,
                decoration: const InputDecoration(
                  labelText: 'Doctor Name',
                  hintText: 'Enter doctor\'s name',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: clinicController,
                decoration: const InputDecoration(
                  labelText: 'Clinic/Hospital',
                  hintText: 'Enter clinic name',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for Visit',
                  hintText: 'Enter appointment reason',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (doctorController.text.isNotEmpty &&
                  clinicController.text.isNotEmpty) {
                // In a real app, this would open a date/time picker
                final newAppointment = AppointmentData(
                  id: 'appt_${DateTime.now().millisecondsSinceEpoch}',
                  kidId: selectedKid.id,
                  doctorName: doctorController.text,
                  doctorSpecialty: 'Pediatrician',
                  clinicName: clinicController.text,
                  appointmentDate: DateTime.now().add(const Duration(days: 7)),
                  appointmentTime: const TimeOfDay(hour: 10, minute: 0),
                  duration: const Duration(minutes: 30),
                  appointmentType: 'Well-child checkup',
                  reason: reasonController.text,
                  status: AppointmentStatus.scheduled,
                  location: '${clinicController.text}, City, State',
                  phoneNumber: '+1 (555) 123-4567',
                  notes: 'Follow-up appointment',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                setState(() {
                  appointments.add(newAppointment);
                });

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Appointment scheduled!')),
                );
              }
            },
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }
}
