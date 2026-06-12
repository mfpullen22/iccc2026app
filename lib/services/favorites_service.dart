import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";

class FavoritesService {
  const FavoritesService();

  DocumentReference<Map<String, dynamic>>? get _userDoc {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    return FirebaseFirestore.instance.collection("users").doc(user.uid);
  }

  Stream<Set<String>> favoriteIdsStream() {
    final userDoc = _userDoc;

    if (userDoc == null) {
      return Stream.value(<String>{});
    }

    return userDoc.snapshots().map((snapshot) {
      final data = snapshot.data();

      final rawFavorites = data?["favoritePresentationIds"];

      if (rawFavorites is! List) {
        return <String>{};
      }

      return rawFavorites.whereType<String>().toSet();
    });
  }

  Future<void> toggleFavorite({
    required String presentationId,
    required bool currentlyFavorite,
  }) async {
    final userDoc = _userDoc;

    if (userDoc == null) {
      throw StateError("No signed-in user.");
    }

    if (currentlyFavorite) {
      await userDoc.update({
        "favoritePresentationIds": FieldValue.arrayRemove([presentationId]),
      });
    } else {
      await userDoc.set({
        "favoritePresentationIds": FieldValue.arrayUnion([presentationId]),
      }, SetOptions(merge: true));
    }
  }
}
