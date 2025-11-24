import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/user_profile.dart';
import '../models/buddy.dart';
import '../models/accountability_group.dart';
import 'database_helper.dart';

class SocialService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  // Share Achievement
  Future<void> shareAchievement(String title, String description, {String? imagePath}) async {
    final String text = '¡He desbloqueado un nuevo logro en Streakify! 🏆\n\n$title\n$description\n\n#Streakify #Habits #Goals';
    
    if (imagePath != null) {
      await Share.shareXFiles([XFile(imagePath)], text: text);
    } else {
      await Share.share(text);
    }
  }

  // Share Streak
  Future<void> shareStreak(String activityName, int days) async {
    final String text = '¡Llevo una racha de $days días en $activityName! 🔥\n\n¿Puedes superarme?\n\n#Streakify #$activityName #Streak';
    await Share.share(text);
  }

  // Profile Management
  Future<UserProfile> getUserProfile() async {
    final profile = await _dbHelper.getUserProfile();
    if (profile != null) {
      return profile;
    }
    
    // Create default profile if not exists
    final newProfile = UserProfile(
      id: 'local_user',
      username: 'Usuario',
      displayName: 'Mi Perfil',
      joinedDate: DateTime.now(),
    );
    await _dbHelper.insertOrUpdateUserProfile(newProfile);
    return newProfile;
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    await _dbHelper.insertOrUpdateUserProfile(profile);
  }

  // Buddy System
  Future<List<Buddy>> getBuddies() async {
    return await _dbHelper.getBuddies();
  }

  Future<void> addBuddy(String name) async {
    // Create a mock buddy locally for demonstration
    final newBuddy = Buddy(
      id: _uuid.v4(),
      userId: 'user_${_uuid.v4().substring(0, 8)}',
      name: name,
      currentStreak: 0,
      status: 'active',
      lastInteraction: DateTime.now(),
    );
    await _dbHelper.insertBuddy(newBuddy);
  }

  // Accountability Groups
  Future<List<AccountabilityGroup>> getGroups() async {
    return await _dbHelper.getAccountabilityGroups();
  }

  Future<void> createGroup(String name, String description) async {
    final newGroup = AccountabilityGroup(
      id: _uuid.v4(),
      name: name,
      description: description,
      memberCount: 1, // You are the first member
      totalGroupStreak: 0,
      createdDate: DateTime.now(),
    );
    await _dbHelper.insertAccountabilityGroup(newGroup);
  }
}
