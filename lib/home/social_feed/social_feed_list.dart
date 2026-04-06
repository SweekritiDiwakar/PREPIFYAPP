import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:prepify/models/post.dart';
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
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.post.imageUrl),
                  fit: BoxFit.cover,
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
            child: Row(
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
