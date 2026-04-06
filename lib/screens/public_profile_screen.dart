import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prepify/models/user_model.dart';
import 'package:prepify/services/user_service.dart';
import 'package:prepify/services/follow_service.dart';

class PublicProfileScreen extends StatefulWidget {
  final String userId;

  const PublicProfileScreen({super.key, required this.userId});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  UserModel? _user;
  bool _isFollowing = false;
  bool _isLoading = true;
  int _followersCount = 0;
  int _followingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await UserService.getUserById(widget.userId);
      if (user != null) {
        setState(() => _user = user);
        _followersCount = await FollowService.getFollowersCount(widget.userId);
        _followingCount = await FollowService.getFollowingCount(widget.userId);
        _isFollowing = await FollowService.isFollowing(widget.userId);
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFollow() async {
    if (_user == null) return;

    try {
      if (_isFollowing) {
        await FollowService.unfollowUser(_user!.uid);
        setState(() {
          _isFollowing = false;
          _followersCount--;
        });
      } else {
        await FollowService.followUser(_user!.uid);
        setState(() {
          _isFollowing = true;
          _followersCount++;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return const Scaffold(
        body: Center(child: Text('User not found')),
      );
    }

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isOwnProfile = currentUserId == _user!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(_user!.username),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _user!.photoUrl.isNotEmpty
                        ? NetworkImage(_user!.photoUrl)
                        : null,
                    child: _user!.photoUrl.isEmpty
                        ? Text(_user!.username[0].toUpperCase(),
                            style: const TextStyle(fontSize: 40))
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _user!.username,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  if (_user!.bio.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(_user!.bio, textAlign: TextAlign.center),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStat('Followers', _followersCount),
                      const SizedBox(width: 32),
                      _buildStat('Following', _followingCount),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (!isOwnProfile)
                    ElevatedButton(
                      onPressed: _toggleFollow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFollowing ? Colors.grey : Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(_isFollowing ? 'Unfollow' : 'Follow'),
                    ),
                ],
              ),
            ),

            // Tabs for Recipes and Favorites
            DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Recipes'),
                      Tab(text: 'Favorites'),
                    ],
                  ),
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      children: [
                        _buildRecipesTab(),
                        _buildFavoritesTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildRecipesTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: UserService.streamUserRecipes(_user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final recipes = snapshot.data ?? [];
        if (recipes.isEmpty) {
          return const Center(child: Text('No recipes yet'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            return Card(
              child: Column(
                children: [
                  Expanded(
                    child: Image.network(
                      recipe['imageUrl'] ?? '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      recipe['title'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFavoritesTab() {
    if (!_user!.showFavoritesPublicly) {
      return const Center(child: Text('Favorites are private'));
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: UserService.streamUserFavorites(_user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final favorites = snapshot.data ?? [];
        if (favorites.isEmpty) {
          return const Center(child: Text('No favorites yet'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final recipe = favorites[index];
            return Card(
              child: Column(
                children: [
                  Expanded(
                    child: Image.network(
                      recipe['imageUrl'] ?? '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      recipe['title'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
