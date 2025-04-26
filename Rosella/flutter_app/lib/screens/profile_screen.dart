// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _currentUser = _auth.currentUser;

      if (_currentUser != null) {
        DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(_currentUser!.uid).get();

        if (userDoc.exists) {
          setState(() {
            _userData = userDoc.data() as Map<String, dynamic>?;
          });
        } else {
          // Create a default profile if none exists
          await _firestore.collection('users').doc(_currentUser!.uid).set({
            'username': _currentUser!.displayName ?? 'User',
            'email': _currentUser!.email ?? '',
            'createdAt': DateTime.now(),
            'personalInfo': {
              'dateOfBirth': '',
              'height': '',
              'weight': '',
            },
            'cycleInfo': {
              'averageCycleLength': '',
              'averagePeriodLength': '',
              'lastPeriod': '',
            },
          });

          // Reload data after creating default profile
          DocumentSnapshot newUserDoc =
          await _firestore.collection('users').doc(_currentUser!.uid).get();
          setState(() {
            _userData = newUserDoc.data() as Map<String, dynamic>?;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatJoinDate() {
    if (_userData != null && _userData!.containsKey('createdAt')) {
      Timestamp timestamp = _userData!['createdAt'];
      DateTime dateTime = timestamp.toDate();
      return DateFormat('MMMM yyyy').format(dateTime);
    }
    return 'Unknown';
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      Navigator.pushReplacementNamed(context, '/auth');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  void _navigateToEditProfile() async {
    if (_userData != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfileScreen(userData: _userData!),
        ),
      );

      if (result == true) {
        // Reload user data if profile was updated
        _loadUserData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Profile'),
          backgroundColor: const Color(0xFFE75A7C),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE75A7C)),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFFE75A7C),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEditProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(
                      'assets/images/profile_avatar.png',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _userData?['username'] ?? 'User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Member since ${_formatJoinDate()}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Personal Information
            const Text(
              'Personal Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoItem(
              Icons.calendar_today,
              'Date of Birth',
              _userData?['personalInfo']?['dateOfBirth'] ?? 'Not set',
            ),
            _buildInfoItem(
              Icons.height,
              'Height',
              _userData?['personalInfo']?['height'] ?? 'Not set',
            ),
            _buildInfoItem(
              Icons.monitor_weight,
              'Weight',
              _userData?['personalInfo']?['weight'] ?? 'Not set',
            ),

            const SizedBox(height: 32),

            // Cycle Information
            const Text(
              'Cycle Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoItem(
              Icons.loop,
              'Average Cycle Length',
              _userData?['cycleInfo']?['averageCycleLength'] ?? 'Not set',
            ),
            _buildInfoItem(
              Icons.water_drop,
              'Average Period Length',
              _userData?['cycleInfo']?['averagePeriodLength'] ?? 'Not set',
            ),
            _buildInfoItem(
              Icons.calendar_month,
              'Last Period',
              _userData?['cycleInfo']?['lastPeriod'] ?? 'Not set',
            ),

            const SizedBox(height: 32),

            // Settings
            const Text(
              'Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSettingsItem(Icons.notifications, 'Notifications'),
            _buildSettingsItem(Icons.privacy_tip, 'Privacy'),
            _buildSettingsItem(Icons.help, 'Help & Support'),
            _buildSettingsItem(Icons.logout, 'Logout', onTap: _signOut),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFE75A7C)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey[600])),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, {Function()? onTap}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFE75A7C)),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
