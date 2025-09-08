// import 'package:flutter/material.dart';
// import '../widgets/doctor_logo_widget.dart';

// class DoctorLogoDemoView extends StatelessWidget {
//   const DoctorLogoDemoView({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Dr. Amal Damara Logo'),
//         backgroundColor: Theme.of(context).primaryColor,
//       ),
//       body: Container(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const SizedBox(height: 40),

//             // Large logo for header
//             const DoctorLogoWidget(
//               size: 200,
//               showBackground: true,
//             ),

//             const SizedBox(height: 40),

//             // Different sizes showcase
//             const Text(
//               'Logo Sizes',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 20),

//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: const [
//                 DoctorLogoWidget(size: 60),
//                 DoctorLogoWidget(size: 80),
//                 DoctorLogoWidget(size: 100),
//                 DoctorLogoWidget(size: 120),
//               ],
//             ),

//             const SizedBox(height: 40),

//             // Variants showcase
//             const Text(
//               'Logo Variants',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 20),

//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: const [
//                 DoctorLogoWidget(size: 100, showBackground: true),
//                 DoctorLogoWidget(size: 100, showBackground: false),
//               ],
//             ),

//             const SizedBox(height: 20),

//             const Text(
//               'With Background / Without Background',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey,
//               ),
//             ),

//             const Spacer(),

//             // Integration info
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.blue.shade50,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Text(
//                 'This logo is built with Flutter widgets for maximum flexibility and scalability across all platforms.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.blue,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

