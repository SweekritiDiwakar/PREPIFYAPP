import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prepify/home/add_recipe_screen/add_recipe_screen.dart';
import 'package:prepify/providers/recipe_provider.dart';
import 'package:prepify/providers/social_provider.dart';
import 'package:prepify/services/social_service.dart';
import 'package:prepify/models/recipe.dart';
import 'package:prepify/models/post.dart';

class RecipeSection {
  final String? sectionTitle;
  final List<String> ingredients;
  final List<String> steps;

  RecipeSection({
    this.sectionTitle,
    required this.ingredients,
    required this.steps,
  });
}

class RecipeDetailScreen extends StatefulWidget {
  final String title;
  final String imagePath;
  final String duration;
  final String difficulty;
  final List<RecipeSection> sections;
  final Recipe? recipe;

  const RecipeDetailScreen({
    super.key,
    required this.title,
    required this.imagePath,
    required this.duration,
    required this.difficulty,
    required this.sections,
    this.recipe,
  });

  factory RecipeDetailScreen.fromRecipe({required Recipe recipe}) {
    return RecipeDetailScreen(
      title: recipe.title,
      imagePath: recipe.imageUrl,
      duration: '35 minutes', // Default to match photo feel
      difficulty: 'Medium',
      sections: [
        RecipeSection(
          sectionTitle: null,
          ingredients: recipe.ingredients,
          steps: recipe.steps,
        ),
      ],
      recipe: recipe,
    );
  }

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Recipe? _localRecipe;
  Post? _linkedPost;
  bool _loadingSocial = true;

  Recipe get _recipe {
    if (_localRecipe != null) return _localRecipe!;
    if (widget.recipe != null) return widget.recipe!;

    // Build a lightweight Recipe from the provided ad-hoc fields (used by dashboard quick-cards).
    final ingredients = <String>[];
    final steps = <String>[];
    for (var s in widget.sections) {
      ingredients.addAll(s.ingredients);
      steps.addAll(s.steps);
    }

    return Recipe(
      id: '',
      title: widget.title,
      description: '${widget.duration} · ${widget.difficulty}',
      ingredients: ingredients,
      steps: steps,
      imageUrl: widget.imagePath,
      createdBy: '',
      createdAt: null,
      likes: 0,
      tags: const [],
    );
  }

  @override
  void initState() {
    super.initState();
    _localRecipe = widget.recipe;
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _loadSocialPost();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSocialPost() async {
    final recipeId = _recipe.id;
    if (recipeId.isEmpty) {
      setState(() => _loadingSocial = false);
      return;
    }
    
    try {
      final post = await SocialService.fetchPostByRecipeId(recipeId);
      if (!mounted) return;
      
      setState(() {
        _linkedPost = post;
        _loadingSocial = false;
      });

      if (post != null) {
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        if (currentUserId != null) {
          context.read<SocialProvider>().checkLikeStatus(post.id, currentUserId);
          context.read<SocialProvider>().checkFavoriteStatus(post.id, currentUserId);
        }
      }
    } catch (e) {
      debugPrint('Error loading social post: $e');
      if (mounted) {
        setState(() => _loadingSocial = false);
      }
    }
  }

  Future<void> _handleLike() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to like recipes.')),
      );
      return;
    }

    if (_linkedPost == null) {
      final recipe = _recipe;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUserId).get();
      final username = userDoc.data()?['username'] as String? ?? 'Prepify User';
      
      await SocialService.createPost(
        recipeId: recipe.id,
        imageUrl: recipe.imageUrl,
        description: 'Check out my recipe: ${recipe.title}!\n\n${recipe.description}',
        category: recipe.tags.isNotEmpty ? recipe.tags.first : 'General',
        username: username,
      );
      
      final post = await SocialService.fetchPostByRecipeId(recipe.id);
      if (post == null) return;
      _linkedPost = post;
    }

    if (_linkedPost != null) {
      await context.read<RecipeProvider>().likeRecipe(_recipe.id);
      await context.read<SocialProvider>().toggleLike(_linkedPost!.id, currentUserId);
    }
  }

  Future<void> _handleFavorite() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to save recipes.')),
      );
      return;
    }

    if (_linkedPost == null) {
      final recipe = _recipe;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUserId).get();
      final username = userDoc.data()?['username'] as String? ?? 'Prepify User';
      
      await SocialService.createPost(
        recipeId: recipe.id,
        imageUrl: recipe.imageUrl,
        description: 'Check out my recipe: ${recipe.title}!\n\n${recipe.description}',
        category: recipe.tags.isNotEmpty ? recipe.tags.first : 'General',
        username: username,
      );
      
      final post = await SocialService.fetchPostByRecipeId(recipe.id);
      if (post == null) return;
      _linkedPost = post;
    }

    if (_linkedPost != null) {
      await context.read<SocialProvider>().toggleFavorite(_linkedPost!.id, currentUserId);
    }
  }

  void _showActionMenu(Recipe recipe, bool canManage) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: const Color(0xFFFEF2EF),
      builder: (context) {
        final isFavorited = _linkedPost != null && context.watch<SocialProvider>().isFavorited(_linkedPost!.id);
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canManage) ...[
                _buildActionMenuItem(
                  Icons.edit_outlined,
                  'Edit Recipe',
                  onTap: () async {
                    final updated = await Navigator.push<Recipe>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddRecipeScreen(recipe: recipe),
                      ),
                    );

                    if (updated != null && mounted) {
                      setState(() {
                        _localRecipe = updated;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Recipe updated successfully.')),
                      );
                    }
                  },
                ),
                const Divider(height: 1, color: Colors.black12),
                _buildActionMenuItem(
                  Icons.delete_outline,
                  'Delete Recipe',
                  isDestructive: true,
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          title: const Text('Delete recipe?'),
                          content: const Text('This cannot be undone.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmed != true || !mounted) return;

                    final success = await context.read<RecipeProvider>().deleteRecipe(recipe);
                    if (!mounted) return;

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Recipe deleted.')),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            context.read<RecipeProvider>().errorMessage ?? 'Delete failed.',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
                const Divider(height: 1, color: Colors.black12),
              ],
              _buildActionMenuItem(Icons.info_outline, 'Nutrition Facts'),
              const Divider(height: 1, color: Colors.black12),
              _buildActionMenuItem(Icons.note_add_outlined, 'Add Notes'),
              const Divider(height: 1, color: Colors.black12),
              _buildActionMenuItem(Icons.share_outlined, 'Share'),
              const Divider(height: 1, color: Colors.black12),
              _buildActionMenuItem(Icons.print_outlined, 'Print'),
              const Divider(height: 1, color: Colors.black12),
              _buildActionMenuItem(Icons.feedback_outlined, 'Feedback For The Chef'),
              const Divider(height: 1, color: Colors.black12),
              _buildActionMenuItem(
                isFavorited ? Icons.collections_bookmark : Icons.collections_bookmark_outlined,
                isFavorited ? 'Remove From Collections' : 'Add To Collections',
                onTap: _handleFavorite,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionMenuItem(IconData icon, String title, {VoidCallback? onTap, bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.redAccent : Colors.black54),
      title: Text(title,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: isDestructive ? Colors.redAccent : Colors.black87)),
      onTap: () {
        Navigator.pop(context);
        onTap?.call();
      },
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Combine all sections for the tabs if there are multiple
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final canManage = currentUserId != null && currentUserId == _recipe.createdBy;
    List<String> allIngredients = [];
    List<String> allSteps = [];
    for (var section in widget.sections) {
      allIngredients.addAll(section.ingredients);
      allSteps.addAll(section.steps);
    }

    final socialProvider = context.watch<SocialProvider>();
    final isLiked = _linkedPost != null && socialProvider.isLiked(_linkedPost!.id);
    
    return Scaffold(
      backgroundColor: const Color(0xFFFEF2EF), // Light pinkish background from photo
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: const Color(0xFFFEF2EF),
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.more_horiz, color: Colors.black),
                        onPressed: () => _showActionMenu(_recipe, canManage),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: ClipRRect(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                    child: _recipe.imageUrl.startsWith('assets')
                        ? Image.asset(
                            _recipe.imageUrl,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            _recipe.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey[300],
                              child: const Center(child: Icon(Icons.restaurant, size: 50, color: Colors.grey)),
                            ),
                          ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF2EF),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _recipe.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'serif',
                                color: Colors.black87,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${widget.duration} • 2 servings', // Servings mocked as in photo
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: _handleLike,
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.black,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.black87,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: const Color(0xFFFFCCBC), // Light orange background for active tab
                      border: Border.all(color: Colors.orange, width: 1.5),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    dividerColor: Colors.transparent,
                    tabs: [
                      _buildTab('Ingredients', 0),
                      _buildTab('Instructions', 1),
                    ],
                  ),
                ),
              ),
              SliverFillRemaining(
                child: Container(
                  color: const Color(0xFFFEF2EF),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildIngredientsTab(allIngredients),
                      _buildInstructionsTab(allSteps),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        bool isSelected = _tabController.index == index;
        return Tab(
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected ? Colors.transparent : Colors.grey[300]!,
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildIngredientsTab(List<String> ingredients) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100, top: 10),
      itemCount: ingredients.length,
      itemBuilder: (context, index) {
        final ing = ingredients[index];
        final isEven = index % 2 == 0;
        
        return Container(
          color: isEven ? Colors.transparent : const Color(0xFFF9EAE8), // light pinkish row background
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  ing,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                ),
              ),
              const Expanded(
                flex: 1,
                child: Text(
                  '', // No separate quantity field in data, so keeping it blank like we decided
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInstructionsTab(List<String> steps) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black45,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      steps[index],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height + 20; 
  @override
  double get maxExtent => tabBar.preferredSize.height + 20;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFFFEF2EF),
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
