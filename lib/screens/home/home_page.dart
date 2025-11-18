import 'package:flutter/material.dart';
import '../../models/paddy_field.dart';
import '../../services/auth_service.dart';
import '../../widgets/delete_confirmation_dialog.dart';
import 'add_paddy_field_page.dart';
import 'paddy_details_page.dart';
import '../profile/profile_page.dart';
import '../disease/detect_disease_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<PaddyField> _paddyFields = [];
  final AuthService _authService = AuthService();

  final Color primary = const Color(0xFF36883B);
  final Color lightGreen = const Color(0xFFD1E6D0);
  StreamSubscription<QuerySnapshot>? _fieldsSubscription;

  @override
  void initState() {
    super.initState();
    _subscribeToPaddyFields();
  }

  @override
  void dispose() {
    _fieldsSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToPaddyFields() {
    final userId = _authService.currentUserId;
    if (userId == null) return;
    _fieldsSubscription?.cancel();
    _fieldsSubscription = FirebaseFirestore.instance
        .collection('harvest_users')
        .doc(userId)
        .collection('paddy_fields')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          final next = snapshot.docs.map((doc) {
            final data = doc.data();
            return PaddyField(
              id: doc.id,
              name: data['name'] ?? '',
              location: data['location'] ?? '',
              areaSize: (data['areaSize'] as num?)?.toDouble() ?? 0.0,
              createdAt: (data['createdAt'] is Timestamp)
                  ? (data['createdAt'] as Timestamp).toDate()
                  : DateTime.tryParse('${data['createdAt']}') ?? DateTime.now(),
            );
          }).toList();
          if (mounted) {
            setState(() {
              _paddyFields
                ..clear()
                ..addAll(next);
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildPaddyFieldsPage(),
          ProfilePage(
            key: ValueKey(
              'profile_${_authService.currentUserId}_${_paddyFields.length}',
            ), // Rebuild when user or count changes
            paddyFieldCount: _paddyFields.length,
          ),
          const DetectDiseasePage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => _navigateToAddField(),
              backgroundColor: Colors.orange,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildPaddyFieldsPage() {
    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: primary,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 48), // Balance spacing
              Expanded(
                child: Center(
                  child: Text(
                    'Paddy Fields',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 1; // Navigate to Profile tab
                  });
                  // Force reload profile data when profile icon is clicked
                  Future.microtask(() {
                    if (mounted) {
                      setState(() {});
                    }
                  });
                },
                icon: const Icon(Icons.person, color: Colors.white, size: 28),
                tooltip: 'View Profile',
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: _paddyFields.isEmpty
                ? _buildEmptyState()
                : _buildPaddyFieldsList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Click here to add a paddy field',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => _navigateToAddField(),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.add, size: 60, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaddyFieldsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _paddyFields.length,
      itemBuilder: (context, index) {
        final field = _paddyFields[index];
        return _buildPaddyFieldCard(field);
      },
    );
  }

  Widget _buildPaddyFieldCard(PaddyField field) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaddyDetailsPage(paddyField: field),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Text(
                  field.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaddyDetailsPage(paddyField: field),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.black87,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteDialog(field),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(PaddyField field) async {
    final result = await DeleteConfirmationDialog.show(context, field.name);
    if (result == true) {
      final userId = _authService.currentUserId;
      if (userId == null) return;
      await FirebaseFirestore.instance
          .collection('harvest_users')
          .doc(userId)
          .collection('paddy_fields')
          .doc(field.id)
          .delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paddy field deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _navigateToAddField() async {
    final result = await Navigator.push<PaddyField>(
      context,
      MaterialPageRoute(builder: (context) => AddPaddyFieldPage()),
    );

    if (result != null) {
      final userId = _authService.currentUserId;
      if (userId == null) return;
      final ref = FirebaseFirestore.instance
          .collection('harvest_users')
          .doc(userId)
          .collection('paddy_fields')
          .doc(result.id);
      await ref.set({
        'name': result.name,
        'location': result.location,
        'areaSize': result.areaSize,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paddy field added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            // Force reload profile data when profile tab is selected
            if (index == 1) {
              // Trigger rebuild of ProfilePage by updating the key
              Future.microtask(() {
                if (mounted) {
                  setState(() {});
                }
              });
            }
          },
          backgroundColor: primary,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: lightGreen,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _currentIndex == 0 ? primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.agriculture, size: 24),
              ),
              label: 'Paddy Fields',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person, size: 24),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.search, size: 24),
              label: 'Detect Disease',
            ),
          ],
        ),
      ),
    );
  }
}
