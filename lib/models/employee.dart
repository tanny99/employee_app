import 'package:cloud_firestore/cloud_firestore.dart';

class Employee {
  final String name;
  final DateTime joinDate;
  final bool isActive;

  Employee(
      {required this.name, required this.joinDate, required this.isActive});

  factory Employee.fromFirestore(Map<String, dynamic> data) {
    return Employee(
      name: data['name'],
      joinDate: (data['joinDate'] as Timestamp).toDate(),
      isActive: data['isActive'],
    );
  }
}
