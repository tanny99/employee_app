import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:employee_app/models/employee.dart';
import 'package:employee_app/functions/fetch_employee_data.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Employee App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EmployeeListScreen(),
    );
  }
}

class EmployeeListScreen extends StatelessWidget {
  final EmployeeService _employeeService = EmployeeService();

  EmployeeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
      ),
      body: StreamBuilder<List<Employee>>(
        stream: _employeeService.getEmployees(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final employees = snapshot.data ?? [];

          return ListView.builder(
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final employee = employees[index];
              final bool flag = employee.isActive &&
                  DateTime.now().difference(employee.joinDate).inDays > 5 * 365;
              return ListTile(
                title: Text(employee.name),
                subtitle: Text(
                    'Joined on: ${employee.joinDate.toLocal().toString().split(' ')[0]}'),
                tileColor: flag ? Colors.green[100] : null,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEmployeeScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddEmployeeScreenState createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final TextEditingController _nameController = TextEditingController();
  DateTime? _joinDate;
  final bool _isActive = true; // Assuming the new employee is active by default

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _joinDate) {
      setState(() {
        _joinDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Employee'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  _joinDate == null
                      ? 'Please choose a date->'
                      : 'Join Date: ${DateFormat('dd.MM.yyyy').format(_joinDate!)}',
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child:
                      Text(_joinDate == null ? 'Select date' : 'Change Date'),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty && _joinDate != null) {
                final name = _nameController.text;
                final joinDate = _joinDate!;
                final isActive = _isActive;

                FirebaseFirestore.instance.collection('employees').add({
                  'name': name,
                  'joinDate': Timestamp.fromDate(joinDate),
                  'isActive': isActive,
                }).then((_) {
                  Navigator.pop(context);
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter all fields')),
                );
              }
            },
            child: const Text('Add Employee'),
          ),
        ),
      ),
    );
  }
}
