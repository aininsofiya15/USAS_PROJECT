import 'package:flutter/material.dart';
import '../../provider/manage_fees_provider.dart';

class StudentListCard extends StatelessWidget {
  final StudentFeeStatus student;
  final VoidCallback onTap;

  const StudentListCard({
    super.key,
    required this.student,
    required this.onTap,
  });

  Color _getStatusColor() {
    if (student.status == 'paid') return Colors.green;
    if (student.isBlocked) return Colors.red;
    return Colors.orange;
  }

  String _getStatusText() {
    if (student.status == 'paid') return 'Paid';
    if (student.isBlocked) return 'Blocked';
    return 'Unpaid';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(
            student.name.isNotEmpty ? student.name[0].toUpperCase() : 'S',
            style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          student.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            // FIX: Changed student_id to matricId
            Text('Matric: ${student.matricId}'), 
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.attach_money, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 2),
                Text(
                  // FIX: Changed balance to outstandingAmount
                  'Balance: RM ${student.outstandingAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: student.outstandingAmount > 0 ? Colors.red.shade700 : Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _getStatusColor().withOpacity(0.3)),
          ),
          child: Text(
            _getStatusText(),
            style: TextStyle(
              color: _getStatusColor(),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}