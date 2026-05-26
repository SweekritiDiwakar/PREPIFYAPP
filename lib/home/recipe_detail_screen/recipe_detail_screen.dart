import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prepify/home/add_recipe_screen/add_recipe_screen.dart';
import 'package:prepify/models/recipe.dart';
import 'package:prepify/providers/recipe_provider.dart';
import 'package:video_player/video_player.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key, required this.recipe});

  final Recipe recipe;

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  VideoPlayerController? _videoController;
  Recipe? _localRecipe;

  @override
  void initState() {
    super.initState();
    _localRecipe = widget.recipe;
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);

    if (_isVideoUrl(widget.recipe.imageUrl)) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.recipe.imageUrl))
        ..initialize().then((_) {
          if (mounted) setState(() {});
        })
        ..setLooping(true)
        ..play();
    }
  }

  bool _isVideoUrl(String url) {
    final lower = url.toLowerCase();
    return lower.contains('.mp4') || lower.contains('.mov') || lower.contains('.webm') || lower.contains('.avi') || lower.contains('.mkv');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _showActionMenu(Recipe recipe, bool canManage) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: const Color(0xFFFEF2EF),
      builder: (context) {
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
                          content: Text(context.read<RecipeProvider>().errorMessage ?? 'Delete failed.'),
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
              _buildActionMenuItem(Icons.collections_bookmark_outlined, 'Add To Collections'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionMenuItem(IconData icon, String title, {VoidCallback? onTap, bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.redAccent : Colors.black54),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: isDestructive ? Colors.redAccent : Colors.black87,
        ),
      ),
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
    return Scaffold(
      backgroundColor: const Color(0xFFFEF2EF),
      body: Consumer<RecipeProvider>(
        builder: (context, provider, _) {
          final index = provider.recipesList.indexWhere((item) => item.id == widget.recipe.id);
          final baseRecipe = _localRecipe ?? widget.recipe;
          final liveRecipe = index >= 0 ? provider.recipesList[index] : baseRecipe;
          final currentUserId = FirebaseAuth.instance.currentUser?.uid;
          final canManage = currentUserId != null && currentUserId == liveRecipe.createdBy;

          return Stack(
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
                            onPressed: () => _showActionMenu(liveRecipe, canManage),
                          ),
                        ),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: ClipRRect(
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                        child: _isVideoUrl(liveRecipe.imageUrl)
                            ? (_videoController != null && _videoController!.value.isInitialized
                                ? FittedBox(
                                    fit: BoxFit.cover,
                                    child: SizedBox(
                                      width: _videoController!.value.size.width,
                                      height: _videoController!.value.size.height,
                                      child: VideoPlayer(_videoController!),
                                    ),
                                  )
                                : Container(
                                    color: Colors.black12,
                                    child: const Center(child: CircularProgressIndicator()),
                                  ))
                            : Image.network(
                                liveRecipe.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.grey[300],
                                  child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
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
                                  liveRecipe.title,
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
                                  '35 minutes • 2 servings',
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
                            onPressed: () => provider.likeRecipe(liveRecipe.id),
                            icon: Icon(
                              liveRecipe.likes > 0 ? Icons.favorite : Icons.favorite_border,
                              color: liveRecipe.likes > 0 ? Colors.red : Colors.black,
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
                          color: const Color(0xFFFFCCBC),
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
                          _buildIngredientsTab(liveRecipe.ingredients),
                          _buildInstructionsTab(liveRecipe.steps),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        final isSelected = _tabController.index == index;
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
          color: isEven ? Colors.transparent : const Color(0xFFF9EAE8),
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
                  '',
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
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}
