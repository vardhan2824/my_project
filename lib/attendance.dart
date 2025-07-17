import 'package:flutter/material.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy subject-wise attendance data
    final List<Map<String, dynamic>> subjects = [
      {'code': 'MATH101', 'held': 20, 'attended': 18},
      {'code': 'PHY102', 'held': 20, 'attended': 15},
      {'code': 'CHEM103', 'held': 20, 'attended': 16},
      {'code': 'CS104', 'held': 20, 'attended': 20},
    ];

    // Calculate total held and attended
    final int totalHeld = subjects.fold(0, (sum, subj) => sum + (subj['held'] as int));
    final int totalAttended = subjects.fold(0, (sum, subj) => sum + (subj['attended'] as int));

    final double totalPercentage = (totalAttended / totalHeld) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Records'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Subject-wise Attendance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DataTable(
              columns: const [
                DataColumn(label: Text('Subject Code')),
                DataColumn(label: Text('Held')),
                DataColumn(label: Text('Attended')),
                DataColumn(label: Text('Percentage')),
              ],
              rows: subjects.map((subject) {
                final double percentage = (subject['attended'] / subject['held']) * 100;
                return DataRow(cells: [
                  DataCell(Text(subject['code'])),
                  DataCell(Text('${subject['held']}')),
                  DataCell(Text('${subject['attended']}')),
                  DataCell(Text('${percentage.toStringAsFixed(1)}%')),
                ]);
              }).toList(),
            ),
            const SizedBox(height: 20),
            Divider(),
            Text(
              'Total Attendance: $totalAttended / $totalHeld (${totalPercentage.toStringAsFixed(1)}%)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
