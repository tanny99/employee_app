import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee_app/models/employee.dart';

class EmployeeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Employee>> getEmployees() {
    return _firestore.collection('employees').snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => Employee.fromFirestore(doc.data()))
            .toList());
  }
}
