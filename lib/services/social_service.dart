import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prepify/models/post.dart';

class SocialService {
  SocialService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static CollectionReference<Map<String, dynamic>> get _posts => _db.collection('posts');

  static Future<void> createPost({
    required String imageUrl,
    required String description,
    required String username,
    required String category,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Not logged in');

    await _posts.add({
      'userId': user.uid,
      'username': username,
      'imageUrl': imageUrl,
      'description': description,
      'category': category,
      'timestamp': FieldValue.serverTimestamp(),
      'likesCount': 0,
    });
  }

  static Stream<List<Post>> streamGlobalFeed() {
    return _posts.orderBy('timestamp', descending: true).snapshots().map(
      (snap) => snap.docs.map((doc) => Post.fromFirestore(doc.id, doc.data())).toList()
    );
  }

  // Using in-memory sorting to avoid composite index requirements for the user
  static Future<List<Post>> fetchUserPosts(String userId) async {
    final snapshot = await _posts.where('userId', isEqualTo: userId).get();
    final list = snapshot.docs.map((doc) => Post.fromFirestore(doc.id, doc.data())).toList();
    list.sort((a, b) => (b.timestamp?.seconds ?? 0).compareTo(a.timestamp?.seconds ?? 0));
    return list;
  }

  static Stream<List<Post>> streamUserPosts(String userId) {
    return _posts.where('userId', isEqualTo: userId).snapshots().map(
      (snap) {
        final list = snap.docs.map((doc) => Post.fromFirestore(doc.id, doc.data())).toList();
        list.sort((a, b) => (b.timestamp?.seconds ?? 0).compareTo(a.timestamp?.seconds ?? 0));
        return list;
      }
    );
  }

  static Future<bool> isPostLikedByUser(String postId, String userId) async {
    final doc = await _posts.doc(postId).collection('likes').doc(userId).get();
    return doc.exists;
  }

  static Future<void> toggleLike(String postId, String userId, bool currentlyLiked) async {
    final postRef = _posts.doc(postId);
    final likeRef = postRef.collection('likes').doc(userId);
    final userLikeRef = _db.collection('users').doc(userId).collection('likedPosts').doc(postId);

    await _db.runTransaction((transaction) async {
      final postDoc = await transaction.get(postRef);
      if (!postDoc.exists) return;

      int currentLikes = (postDoc.data()?['likesCount'] as num?)?.toInt() ?? 0;

      if (currentlyLiked) {
        // Unlike
        transaction.delete(likeRef);
        transaction.delete(userLikeRef);
        transaction.update(postRef, {'likesCount': currentLikes - 1});
      } else {
        // Like
        transaction.set(likeRef, {'timestamp': FieldValue.serverTimestamp()});
        final postData = postDoc.data()!;
        transaction.set(userLikeRef, {
          'userId': postData['userId'] ?? '',
          'username': postData['username'] ?? '',
          'imageUrl': postData['imageUrl'] ?? '',
          'description': postData['description'] ?? '',
          'category': postData['category'] ?? '',
          'timestamp': postData['timestamp'] ?? FieldValue.serverTimestamp(),
          'likesCount': postData['likesCount'] ?? 0,
          'likedAt': FieldValue.serverTimestamp(),
        });
        transaction.update(postRef, {'likesCount': currentLikes + 1});
      }
    });
  }

  static Stream<List<Post>> streamUserLikedPosts(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('likedPosts')
        .orderBy('likedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Post.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  static Future<bool> isPostFavoritedByUser(String postId, String userId) async {
    final doc = await _db.collection('users').doc(userId).collection('favorites').doc(postId).get();
    return doc.exists;
  }

  static Future<void> toggleFavorite(String postId, String userId, bool currentlyFavorited) async {
    final favRef = _db.collection('users').doc(userId).collection('favorites').doc(postId);
    if (currentlyFavorited) {
      await favRef.delete();
    } else {
      final postDoc = await _posts.doc(postId).get();
      if (!postDoc.exists) return;
      final postData = postDoc.data()!;
      await favRef.set({
        'userId': postData['userId'] ?? '',
        'username': postData['username'] ?? '',
        'imageUrl': postData['imageUrl'] ?? '',
        'description': postData['description'] ?? '',
        'category': postData['category'] ?? '',
        'timestamp': postData['timestamp'] ?? FieldValue.serverTimestamp(),
        'likesCount': postData['likesCount'] ?? 0,
        'favoritedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  static Stream<List<Post>> streamUserFavoritePosts(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .orderBy('favoritedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Post.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  static Stream<List<Comment>> streamComments(String postId) {
    return _posts.doc(postId).collection('comments').orderBy('timestamp', descending: false).snapshots().map(
      (snap) => snap.docs.map((doc) => Comment.fromFirestore(doc.id, doc.data())).toList()
    );
  }

  static Future<void> addComment(String postId, String text, String username) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Not logged in');

    await _posts.doc(postId).collection('comments').add({
      'userId': user.uid,
      'username': username,
      'commentText': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
