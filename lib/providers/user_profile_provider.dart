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

  Future<void> incrementCompletedRecipes() async {
    final currentUser = _user;
    if (currentUser == null) return;

    final newCount = currentUser.completedRecipes + 1;
    final List<String> newBadges = List.from(currentUser.badges);
    bool badgesChanged = false;
    
    if (newCount >= 1 && !newBadges.contains('First Recipe Master')) {
      newBadges.add('First Recipe Master');
      badgesChanged = true;
    }
    if (newCount >= 5 && !newBadges.contains('5 Recipes Pro')) {
      newBadges.add('5 Recipes Pro');
      badgesChanged = true;
    }
    if (newCount >= 10 && !newBadges.contains('10 Recipes Chef')) {
      newBadges.add('10 Recipes Chef');
      badgesChanged = true;
    }

    _user = currentUser.copyWith(
      completedRecipes: newCount,
      badges: newBadges,
    );
    notifyListeners();

    try {
      await UserProfileService.incrementCompletedRecipes(
        uid: currentUser.uid,
        newCount: newCount,
        badges: badgesChanged ? newBadges : null,
      );
    } catch (e) {
      _user = currentUser;
      notifyListeners();
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
