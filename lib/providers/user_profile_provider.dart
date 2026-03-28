import 'dart:io';

import 'package:flutter/material.dart';
import 'package:prepify/models/app_user.dart';
import 'package:prepify/services/auth_service.dart';
import 'package:prepify/services/user_profile_service.dart';

class UserProfileProvider extends ChangeNotifier {
  AppUser? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasUser => _user != null;

  Future<void> initializeCurrentUser() async {
    if (_isLoading) return;
    _setLoading(true);
    _errorMessage = null;
    try {
      if (AuthService.currentUser == null) {
        _user = null;
      } else {
        _user = await UserProfileService.fetchCurrentUserProfile();
      }
    } catch (e) {
      _errorMessage = 'Failed to load profile. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() async {
    await initializeCurrentUser();
  }

  Future<void> updateName(String name) async {
    final current = _user;
    if (current == null || name.trim().isEmpty) return;
    _setLoading(true);
    _errorMessage = null;
    try {
      _user = await UserProfileService.updateName(uid: current.uid, name: name);
    } catch (e) {
      _errorMessage = 'Unable to update name right now.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfileImage(File imageFile) async {
    final current = _user;
    if (current == null) return;
    _setLoading(true);
    _errorMessage = null;
    try {
      _user = await UserProfileService.updateProfileImage(
        uid: current.uid,
        imageFile: imageFile,
      );
    } catch (e) {
      _errorMessage = 'Unable to upload image right now.';
    } finally {
      _setLoading(false);
    }
  }

  void clearUser() {
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
