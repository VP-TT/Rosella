// lib/screens/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TextEditingController _usernameController;
  late TextEditingController _dobController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _cycleLengthController;
  late TextEditingController _periodLengthController;
  late TextEditingController _lastPeriodController;

  bool _isLoading = false;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();

    Map<String, dynamic> personalInfo = widget.userData['personalInfo'] ?? {};
    Map<String, dynamic> cycleInfo = widget.userData['cycleInfo'] ?? {};

    _usernameController = TextEditingController(text: widget.userData['username']);
    _dobController = TextEditingController(text: personalInfo['dateOfBirth'] ?? '');
    _heightController = TextEditingController(text: personalInfo['height'] ?? '');
    _weightController = TextEditingController(text: personalInfo['weight'] ?? '');
    _cycleLengthController = TextEditingController(text: cycleInfo['averageCycleLength'] ?? '');
    _periodLengthController = TextEditingController(text: cycleInfo['averagePeriodLength'] ?? '');
    _lastPeriodController = TextEditingController(text: cycleInfo['lastPeriod'] ?? '');

    // Try to parse the date of birth if it exists
    if (personalInfo['dateOfBirth'] != null && personalInfo['dateOfBirth'].isNotEmpty) {
      try {
        _selectedDate = DateFormat('d MMMM yyyy').parse(personalInfo['dateOfBirth']);
      } catch (e) {
        // If parsing fails, leave _selectedDate as null
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _dobController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _cycleLengthController.dispose();
    _periodLengthController.dispose();
    _lastPeriodController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE75A7C),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE75A7C),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('d MMMM yyyy').format(picked);
      });
    }
  }

  Future<void> _selectLastPeriodDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE75A7C),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE75A7C),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _lastPeriodController.text = DateFormat('d MMMM yyyy').format(picked);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        User? currentUser = _auth.currentUser;

        if (currentUser != null) {
          await _firestore.collection('users').doc(currentUser.uid).update({
            'username': _usernameController.text,
            'personalInfo': {
              'dateOfBirth': _dobController.text,
              'height': _heightController.text,
              'weight': _weightController.text,
            },
            'cycleInfo': {
              'averageCycleLength': _cycleLengthController.text,
              'averagePeriodLength': _periodLengthController.text,
              'lastPeriod': _lastPeriodController.text,
            },
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );

          Navigator.pop(context, true); // Return true to indicate successful update
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFFE75A7C),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE75A7C)),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Username
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  icon: const Icon(Icons.person, color: Color(0xFFE75A7C)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFFE75A7C),
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),
              const Text(
                'Personal Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Date of Birth
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dobController,
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      icon: const Icon(Icons.calendar_today, color: Color(0xFFE75A7C)),
                      hintText: 'Select your date of birth',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFFE75A7C),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Height
              TextFormField(
                controller: _heightController,
                decoration: InputDecoration(
                  labelText: 'Height',
                  icon: const Icon(Icons.height, color: Color(0xFFE75A7C)),
                  hintText: 'e.g., 165 cm',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFFE75A7C),
                      width: 2,
                    ),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),

              // Weight
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: 'Weight',
                  icon: const Icon(Icons.monitor_weight, color: Color(0xFFE75A7C)),
                  hintText: 'e.g., 58 kg',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFFE75A7C),
                      width: 2,
                    ),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 24),
              const Text(
                'Cycle Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Average Cycle Length
              TextFormField(
                controller: _cycleLengthController,
                decoration: InputDecoration(
                  labelText: 'Average Cycle Length',
                  icon: const Icon(Icons.loop, color: Color(0xFFE75A7C)),
                  hintText: 'e.g., 28 days',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFFE75A7C),
                      width: 2,
                    ),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),

              // Average Period Length
              TextFormField(
                controller: _periodLengthController,
                decoration: InputDecoration(
                  labelText: 'Average Period Length',
                  icon: const Icon(Icons.water_drop, color: Color(0xFFE75A7C)),
                  hintText: 'e.g., 5 days',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFFE75A7C),
                      width: 2,
                    ),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),

              // Last Period
              GestureDetector(
                onTap: () => _selectLastPeriodDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _lastPeriodController,
                    decoration: InputDecoration(
                      labelText: 'Last Period',
                      icon: const Icon(Icons.calendar_month, color: Color(0xFFE75A7C)),
                      hintText: 'Select your last period date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFFE75A7C),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Center(
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE75A7C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Save Profile',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
