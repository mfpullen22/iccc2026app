import "package:cloud_firestore/cloud_firestore.dart";
import "package:iccc2026/models/presentation.dart";
import "package:iccc2026/models/presenter.dart";
import "package:iccc2026/repositories/conference_repository.dart";

class FirebaseConferenceRepository implements ConferenceRepository {
  const FirebaseConferenceRepository();

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  @override
  Future<List<Presenter>> getPresenters() async {
    final snapshot = await _firestore.collection("presenters").get();

    final presenters = snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());

      // Your presenter JSON already has an id field, but this makes Firestore
      // resilient if a document is missing it.
      data["id"] ??= doc.id;

      return Presenter.fromJson(data);
    }).toList();

    presenters.sort(_sortPresentersByLastName);

    return presenters;
  }

  @override
  Future<List<Presentation>> getPresentations() async {
    final presentationsSnapshot = await _firestore
        .collection("presentations")
        .get();

    final presenters = await getPresenters();

    final presentersById = {
      for (final presenter in presenters) presenter.id.trim(): presenter,
    };

    final presentations = presentationsSnapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());

      final presenterId = data["presenterId"]?.toString().trim() ?? "";
      final matchedPresenter = presentersById[presenterId];

      // Same hydration behavior your local JSON repository currently performs.
      data["affiliation"] = matchedPresenter?.affiliations ?? [];

      return Presentation.fromJson(doc.id, data);
    }).toList();

    presentations.sort(_sortPresentations);

    return presentations;
  }

  @override
  Future<List<Presentation>> getPresentationsForPresenter(
    Presenter presenter,
  ) async {
    final presenterId = presenter.id.trim();

    final snapshot = await _firestore
        .collection("presentations")
        .where("presenterId", isEqualTo: presenterId)
        .get();

    final presentations = snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());

      data["affiliation"] = presenter.affiliations;

      return Presentation.fromJson(doc.id, data);
    }).toList();

    presentations.sort(_sortPresentations);

    return presentations;
  }

  static int _sortPresentersByLastName(Presenter a, Presenter b) {
    final lastNameCompare = a.lastName.toLowerCase().compareTo(
      b.lastName.toLowerCase(),
    );

    if (lastNameCompare != 0) return lastNameCompare;

    return a.firstName.toLowerCase().compareTo(b.firstName.toLowerCase());
  }

  static int _sortPresentations(Presentation a, Presentation b) {
    final dayCompare = a.day.compareTo(b.day);
    if (dayCompare != 0) return dayCompare;

    final startTimeCompare = a.startTime.compareTo(b.startTime);
    if (startTimeCompare != 0) return startTimeCompare;

    return a.displayTitle.toLowerCase().compareTo(b.displayTitle.toLowerCase());
  }
}
