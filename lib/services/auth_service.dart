import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user.dart' as app_user;

/// Service class for handling Firebase Authentication and Firestore operations
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection name for users in Firestore (changed to project-specific collection)
  static const String _usersCollection = 'harvest_users';

  /// Get the current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Get the current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Register a new user with email and password
  /// 
  /// [name] - User's full name
  /// [email] - User's email address
  /// [password] - User's password (min 6 characters)
  /// 
  /// Returns the created User object
  /// Throws [FirebaseAuthException] on authentication errors
  /// Throws [FirebaseException] on Firestore errors
  Future<app_user.User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Validate input
      if (name.trim().isEmpty || name.trim().length < 2) {
        throw FirebaseAuthException(
          code: 'invalid-name',
          message: 'Name must be at least 2 characters long',
        );
      }

      if (password.length < 6) {
        throw FirebaseAuthException(
          code: 'weak-password',
          message: 'Password must be at least 6 characters long',
        );
      }

      // Create user in Firebase Authentication
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw FirebaseAuthException(
          code: 'user-creation-failed',
          message: 'Failed to create user account',
        );
      }

      // Create user document in Firestore using server timestamps
      final Map<String, dynamic> userDoc = {
        'name': name.trim(),
        'email': email.trim(),
        'paddyFieldCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'passwordHash': _hashPassword(password),
      };

      await _firestore.collection(_usersCollection).doc(firebaseUser.uid).set(userDoc);

      // Return a local app_user.User instance (some fields will be null until server timestamp resolves)
      return app_user.User(
        id: firebaseUser.uid,
        name: name.trim(),
        email: email.trim(),
        paddyFieldCount: 0,
        createdAt: null,
        updatedAt: null,
        passwordHash: _hashPassword(password),
      );
    } on FirebaseAuthException catch (e) {
      // Re-throw Firebase Auth exceptions with user-friendly messages
      throw _handleAuthException(e);
    } on FirebaseException catch (e) {
      // Handle Firestore errors
      throw Exception('Failed to save user data: ${e.message}');
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  /// Sign in with email and password
  /// 
  /// [email] - User's email address
  /// [password] - User's password
  /// 
  /// Returns the authenticated User object
  /// Throws [FirebaseAuthException] on authentication errors
  Future<app_user.User> login({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with Firebase Authentication
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw FirebaseAuthException(
          code: 'sign-in-failed',
          message: 'Failed to sign in',
        );
      }

      // Fetch user data from Firestore
      final DocumentSnapshot userDoc = await _firestore
          .collection(_usersCollection)
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('User data not found in database');
      }

      return app_user.User.fromFirestore(
        userDoc.data() as Map<String, dynamic>,
        firebaseUser.uid,
      );
    } on FirebaseAuthException catch (e) {
      // Re-throw Firebase Auth exceptions with user-friendly messages
      throw _handleAuthException(e);
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch user data: ${e.message}');
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Sign out the current user
  /// 
  /// Throws [FirebaseAuthException] on errors
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw Exception('Logout failed: ${e.message}');
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  /// Delete the current user's account
  /// 
  /// This will:
  /// 1. Delete user data from Firestore
  /// 2. Delete user from Firebase Authentication
  /// 
  /// Throws [FirebaseAuthException] on errors
  Future<void> deleteAccount({String? recentPassword}) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      final String userId = user.uid;

      // If password is provided, attempt re-authentication first
      if (recentPassword != null && (user.email != null && user.email!.isNotEmpty)) {
        final AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: recentPassword,
        );
        await user.reauthenticateWithCredential(credential);
      }

      // Delete user data from Firestore
      await _firestore.collection(_usersCollection).doc(userId).delete();

      // Delete user from Firebase Authentication
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } on FirebaseException catch (e) {
      throw Exception('Failed to delete user data: ${e.message}');
    } catch (e) {
      throw Exception('Account deletion failed: $e');
    }
  }

  /// Re-authenticate the current user using their password (email/password accounts only).
  /// Useful before sensitive operations like delete or change email.
  Future<void> reauthenticateWithPassword(String password) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }
    if (user.email == null || user.email!.isEmpty) {
      throw Exception('Current user does not have an email associated');
    }
    try {
      final AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Get user data from Firestore
  /// 
  /// [userId] - The user ID to fetch (defaults to current user)
  /// 
  /// Returns the User object
  /// Throws [Exception] if user not found or on errors
  Future<app_user.User> getUserData([String? userId]) async {
    try {
      final String uid = userId ?? currentUserId ?? '';
      if (uid.isEmpty) {
        throw Exception('No user ID provided and no user is signed in');
      }

      final DocumentSnapshot userDoc =
          await _firestore.collection(_usersCollection).doc(uid).get();

      if (!userDoc.exists) {
        throw Exception('User data not found');
      }

      return app_user.User.fromFirestore(
        userDoc.data() as Map<String, dynamic>,
        uid,
      );
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch user data: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  /// Get current user's name
  Future<String> getCurrentUserName() async {
    try {
      final userData = await getUserData();
      return userData.name;
    } catch (e) {
      return 'User';
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await logout();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  /// Update user data in Firestore
  /// 
  /// [userId] - The user ID to update (defaults to current user)
  /// [updates] - Map of fields to update
  /// 
  /// Throws [Exception] on errors
  Future<void> updateUserData(
    Map<String, dynamic> updates, [
    String? userId,
  ]) async {
    try {
      final String uid = userId ?? currentUserId ?? '';
      if (uid.isEmpty) {
        throw Exception('No user ID provided and no user is signed in');
      }

      updates['updatedAt'] = DateTime.now();

      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .update(updates);
    } on FirebaseException catch (e) {
      throw Exception('Failed to update user data: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update user data: $e');
    }
  }

  /// Handle Firebase Auth exceptions and return user-friendly messages
  FirebaseAuthException _handleAuthException(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'weak-password':
        message = 'The password provided is too weak.';
        break;
      case 'email-already-in-use':
        message = 'An account already exists with this email address.';
        break;
      case 'invalid-email':
        message = 'The email address is invalid.';
        break;
      case 'user-disabled':
        message = 'This user account has been disabled.';
        break;
      case 'user-not-found':
        message = 'No account found with this email address.';
        break;
      case 'wrong-password':
        message = 'Incorrect password. Please try again.';
        break;
      case 'invalid-credential':
        message = 'Invalid email or password. Please try again.';
        break;
      case 'network-request-failed':
        message = 'Network error. Please check your internet connection.';
        break;
      case 'too-many-requests':
        message =
            'Too many failed attempts. Please try again later or reset your password.';
        break;
      default:
        message = e.message ?? 'An authentication error occurred.';
    }
    return FirebaseAuthException(code: e.code, message: message);
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

