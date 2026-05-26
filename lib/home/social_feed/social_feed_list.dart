import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:prepify/home/recipe_detail_screen/recipe_detail_screen.dart';
import 'package:prepify/models/recipe.dart';
import 'package:prepify/models/post.dart';
import 'package:prepify/services/recipe_service.dart';
import 'package:prepify/services/social_service.dart';
import 'package:prepify/providers/social_provider.dart';
import 'package:prepify/home/social_feed/comments_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';
import 'package:prepify/screens/public_profile_screen.dart';

class SocialFeedList extends StatelessWidget {
  const SocialFeedList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Post>>(
      stream: SocialService.streamGlobalFeed(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text("No posts yet. Be the first to share one!", style: TextStyle(color: Colors.grey)),
          ));
        }

        final posts = snapshot.data!;
        
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(), // Important because it's inside a SingleChildScrollView
          shrinkWrap: true,
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return PostCard(post: posts[index]);
          },
        );
      },
    );
  }
}

class PostCard extends StatefulWidget {
  final Post post;
  
  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    // Check initial like and favorite status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SocialProvider>();
      provider.checkLikeStatus(widget.post.id, currentUserId);
      provider.checkFavoriteStatus(widget.post.id, currentUserId);
    });
  }

  void _showComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsBottomSheet(postId: widget.post.id),
    );
  }

  void _sharePost() {
    final categoryText = widget.post.category.isNotEmpty ? '\nCategory: ${widget.post.category}' : '';
    SharePlus.instance.share(
      ShareParams(text: 'Check out ${widget.post.username}\'s recipe on Prepify!$categoryText\n\n"${widget.post.description}"'),
    );
  }

  Future<void> _deletePost() async {
    if (currentUserId != widget.post.userId) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete post?'),
        content: const Text('This will remove the post and its comments.'),
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
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await SocialService.deletePost(widget.post.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete post: $e')),
      );
    }
  }

  Future<void> _openLinkedRecipe() async {
    final linkedRecipeId = widget.post.recipeId.trim();
    Recipe? recipe;

    try {
      if (linkedRecipeId.isNotEmpty) {
        recipe = await RecipeService.fetchRecipeById(linkedRecipeId);
      } else if (widget.post.imageUrl.isNotEmpty) {
        // Fallback: try to find a recipe with the same imageUrl
        recipe = await RecipeService.fetchRecipeByImageUrl(widget.post.imageUrl);
      }
      if (!mounted) return;

      if (recipe == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe not found. It may have been deleted or was never linked.')),
        );
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecipeDetailScreen(recipe: recipe!),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to open recipe: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final socialProvider = context.watch<SocialProvider>();
    final isLiked = socialProvider.isLiked(widget.post.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PublicProfileScreen(userId: widget.post.userId),
                  ),
                );
              },
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.post.username,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          
          // Image
          if (widget.post.imageUrl.isNotEmpty)
            GestureDetector(
              onTap: _openLinkedRecipe,
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(widget.post.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                if (widget.post.category.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F8E9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.post.category,
                      style: const TextStyle(
                        color: Color(0xFF558B2F),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Wrap(
              spacing: 2,
              runSpacing: 0,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.black87,
                  ),
                  onPressed: () => socialProvider.toggleLike(widget.post.id, currentUserId),
                ),
                IconButton(
                  icon: Icon(
                    socialProvider.isFavorited(widget.post.id)
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: socialProvider.isFavorited(widget.post.id)
                        ? const Color(0xFF9CCC65)
                        : Colors.black87,
                  ),
                  onPressed: () => socialProvider.toggleFavorite(widget.post.id, currentUserId),
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline, color: Colors.black87),
                  onPressed: _showComments,
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.black87),
                  onPressed: _sharePost,
                ),
                TextButton(
                  onPressed: _openLinkedRecipe,
                  child: const Text('View Recipe'),
                ),
                if (currentUserId == widget.post.userId)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: _deletePost,
                  ),
              ],
              ),
            ),
          
          
          // Likes Count & Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.post.likesCount} likes',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 13),
                    children: [
                      TextSpan(
                        text: '${widget.post.username} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: widget.post.description),
                    ],
                  ),
                ),
                const SizedBox(height: 16), // Bottom spacing
              ],
            ),
          ),
        ],
      ),
    );
  }
}
