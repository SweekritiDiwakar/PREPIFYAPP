import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prepify/home/profile_screen/controllers/profile_controller.dart';
import 'package:prepify/home/profile_screen/recipe_details/recipe_detail_screen.dart';
import 'package:prepify/home/social_feed/social_feed_list.dart';
import 'package:prepify/models/post.dart';
import 'package:prepify/providers/user_profile_provider.dart';
import 'package:prepify/services/social_service.dart';
import 'package:provider/provider.dart';
import 'package:prepify/models/recipe.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prepify/screens/user_search_screen.dart';
import 'package:prepify/screens/favorites_screen.dart';
import 'package:prepify/screens/settings_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ProfileController _profileController = Get.put(ProfileController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Refresh user profile data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProfileProvider>().refresh();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              pinned: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                "Profile",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'serif'),
              ),
              centerTitle: true,
              actions: [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'search':
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const UserSearchScreen()),
                        );
                        break;
                      case 'favorites':
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FavoritesScreen()),
                        );
                        break;
                      case 'settings':
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SettingsScreen()),
                        );
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'search',
                      child: Text('Search Users'),
                    ),
                    const PopupMenuItem(
                      value: 'favorites',
                      child: Text('My Favorites'),
                    ),
                    const PopupMenuItem(
                      value: 'settings',
                      child: Text('Settings'),
                    ),
                  ],
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFEEEEEE), width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/images/me.jpeg'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Obx(() => Text(
                    _profileController.name.value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'serif',
                      color: Colors.black,
                    ),
                  )),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      "Passionate home cook sharing my kitchen adventures. Lover of spicy food and fresh ingredients! 🌶️",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Consumer<UserProfileProvider>(
                            builder: (context, provider, _) {
                              final count = provider.user?.completedRecipes ?? 0;
                              return _buildStatItem("$count", "Completed");
                            }
                          ),
                          _buildStatItem("1.2k", "Followers"),
                          _buildStatItem("240", "Following"),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Consumer<UserProfileProvider>(
                    builder: (context, provider, _) {
                      final badges = provider.user?.badges ?? [];
                      if (badges.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Achievements 🏆", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: badges.map((b) => Chip(
                                label: Text(b, style: const TextStyle(fontSize: 12)),
                                backgroundColor: const Color(0xFFFBE9E7),
                                side: BorderSide.none,
                              )).toList(),
                            ),
                          ],
                        )
                      );
                    }
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: const Color(0xFF9CCC65),
                  labelColor: const Color(0xFF9CCC65),
                  unselectedLabelColor: Colors.grey,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: "My Recipes"),
                    Tab(text: "Liked"),
                    Tab(text: "Collections"),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildRecipeGrid(),
            _buildLikedPostTab(currentUserId),
            _buildFavoritesTab(currentUserId),
          ],
        ),
      ),
    );
  }

  Widget _buildLikedPostTab(String currentUserId) {
    return StreamBuilder<List<Post>>(
      stream: SocialService.streamUserLikedPosts(currentUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final posts = snapshot.data ?? [];
        if (posts.isEmpty) {
          return const Center(child: Text('No liked posts yet.', style: TextStyle(color: Colors.black54)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return PostCard(post: posts[index]);
          },
        );
      },
    );
  }

  Widget _buildFavoritesTab(String currentUserId) {
    return StreamBuilder<List<Post>>(
      stream: SocialService.streamUserFavoritePosts(currentUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final posts = snapshot.data ?? [];
        if (posts.isEmpty) {
          return const Center(child: Text('No saved recipes yet.', style: TextStyle(color: Colors.black54)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return PostCard(post: posts[index]);
          },
        );
      },
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildRecipeGrid() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      // No orderBy — avoids composite index requirement. Sort client-side.
      stream: FirebaseFirestore.instance
          .collection('recipes')
          .where('createdBy', isEqualTo: currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Could not load recipes.', style: TextStyle(color: Colors.black54)),
          );
        }
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final recipes = snapshot.data!.docs
            .map((doc) {
              try {
                return Recipe.fromFirestore(doc.id, doc.data());
              } catch (_) {
                return null;
              }
            })
            .whereType<Recipe>()
            .toList();

        // Sort client-side by createdAt descending
        recipes.sort((a, b) {
          final aTs = a.createdAt?.seconds ?? 0;
          final bTs = b.createdAt?.seconds ?? 0;
          return bTs.compareTo(aTs);
        });

        if (recipes.isEmpty) {
          return const Center(
            child: Text('No recipes yet.', style: TextStyle(color: Colors.black54)),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailScreen.fromRecipe(recipe: recipe),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: recipe.imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(recipe.imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: Colors.grey[300],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        recipe.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
