import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../widgets/delete_account_confirmation_dialog.dart';
import '../../widgets/logout_confirmation_dialog.dart';
import '../../widgets/reauth_password_dialog.dart';
import '../auth/login_screen.dart';

/// Profile page displaying user information and account actions
class ProfilePage extends StatefulWidget {
  final int paddyFieldCount;

  const ProfilePage({
    super.key,
    this.paddyFieldCount = 0,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;
  String? _lastLoadedUserId;

  final Color primary = const Color(0xFF36883B);
  final Color lightGreen = const Color(0xFFD1E6D0);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didUpdateWidget(ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Always reload data when widget is updated to ensure we have the latest user data
    final currentUserId = _authService.currentUserId;
    if (currentUserId != null) {
      // Reload if user changed or if we don't have data yet
      if (currentUserId != _lastLoadedUserId || _currentUser == null) {
        _loadUserData();
      }
    }
  }

  /// Loads user data from Firestore
  Future<void> _loadUserData() async {
    final currentUserId = _authService.currentUserId;
    
    // If no user is logged in, show error
    if (currentUserId == null) {
      setState(() {
        _errorMessage = 'No user is currently signed in';
        _isLoading = false;
      });
      return;
    }

    // If we already loaded this user's data, skip reload
    if (_lastLoadedUserId == currentUserId && _currentUser != null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get the current user ID again to ensure we're fetching the right user
      final userId = _authService.currentUserId;
      if (userId == null || userId != currentUserId) {
        // User changed or logged out during fetch
        if (mounted) {
          setState(() {
            _errorMessage = 'User session expired. Please login again.';
            _isLoading = false;
          });
        }
        return;
      }

      final user = await _authService.getUserData(userId);
      if (mounted) {
        setState(() {
          _currentUser = user.copyWith(paddyFieldCount: widget.paddyFieldCount);
          _lastLoadedUserId = userId;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load user data: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadUserData,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _currentUser == null
                        ? const Center(
                            child: Text('No user data available'),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: _buildProfileContent(),
                          ),
          ),
        ],
      ),
    );
  }

  /// Builds the header section with profile icon and title
  Widget _buildHeader() {
    return Container(
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
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey.shade300,
            child: Icon(
              Icons.person,
              size: 32,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'My Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the main profile content section
  Widget _buildProfileContent() {
    if (_currentUser == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileField(
            label: 'Name:',
            value: _currentUser!.name,
          ),
          const SizedBox(height: 20),
          _buildProfileField(
            label: 'E-mail:',
            value: _currentUser!.email,
            isEmail: true,
          ),
          const SizedBox(height: 20),
          _buildPaddyFieldCount(),
          const SizedBox(height: 32),
          _buildActionButtons(),
        ],
      ),
    );
  }

  /// Builds a profile information field
  Widget _buildProfileField({
    required String label,
    required String value,
    bool isEmail = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: isEmail ? Colors.blue.shade700 : Colors.black87,
              decoration: isEmail ? TextDecoration.underline : null,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the paddy field count display
  Widget _buildPaddyFieldCount() {
    if (_currentUser == null) return const SizedBox.shrink();

    return Row(
      children: [
        const Text(
          'No. of Paddy Fields:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _currentUser!.paddyFieldCount.toString().padLeft(2, '0'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the action buttons section
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            label: 'Delete Account',
            color: Colors.red,
            onPressed: _handleDeleteAccount,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            label: 'Log out',
            color: const Color(0xFF36883B), // Green color matching palette
            onPressed: _handleLogout,
          ),
        ),
      ],
    );
  }

  /// Builds an individual action button
  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered)) {
                // Hover color matching green palette
                return label == 'Delete Account'
                    ? Colors.red.withOpacity(0.1)
                    : const Color(0xFF36883B).withOpacity(0.1);
              }
              return null;
            },
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Handles delete account action
  Future<void> _handleDeleteAccount() async {
    final result = await DeleteAccountConfirmationDialog.show(context);

    if (result != true || !mounted) return;

    // Show loading indicator
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    try {
      await _authService.deleteAccount();

      if (!mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success notification
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Account deleted successfully',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate to login screen
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      final errorMsg = e.toString();
      if (errorMsg.contains('requires-recent-login')) {
        // Ask user for password and retry
        final password = await ReauthPasswordDialog.show(context);
        if (password != null) {
          // Show loading again
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(child: CircularProgressIndicator()),
          );
          try {
            await _authService.deleteAccount(recentPassword: password);

            if (!mounted) return;

            Navigator.of(context).pop(); // close loading

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Account deleted successfully',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );

            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            }
            return;
          } catch (err) {
            if (mounted) {
              Navigator.of(context).pop(); // close loading
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Re-authentication failed: ${err.toString()}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 4),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        }
      } else {
        // Show error notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Failed to delete account: ${e.toString()}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Handles logout action
  Future<void> _handleLogout() async {
    final result = await LogoutConfirmationDialog.show(context);

    if (result != true || !mounted) return;

    try {
      await _authService.logout();

      if (!mounted) return;

      // Show success notification
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Logged out successfully',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate to login screen
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;

      // Show error notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Failed to logout: ${e.toString()}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
