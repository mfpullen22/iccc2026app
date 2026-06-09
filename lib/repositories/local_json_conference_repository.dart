import "dart:convert";

import "package:flutter/services.dart";
import "package:iccc2026/models/presentation.dart";
import "package:iccc2026/models/presenter.dart";
import "package:iccc2026/repositories/conference_repository.dart";

class LocalJsonConferenceRepository implements ConferenceRepository {
  const LocalJsonConferenceRepository();

  static const String _presentersAssetPath = "data/presenters.json";
  static const String _presentationsAssetPath = "data/presentations.json";

  @override
  Future<List<Presenter>> getPresenters() async {
    final presenters = await _loadPresenters();
    presenters.sort(_sortPresentersByLastName);
    return presenters;
  }

  @override
  Future<List<Presentation>> getPresentations() async {
    final presentations = await _loadHydratedPresentations();
    presentations.sort(_sortPresentations);
    return presentations;
  }

  @override
  Future<List<Presentation>> getPresentationsForPresenter(
    Presenter presenter,
  ) async {
    final presentations = await _loadHydratedPresentations();

    final presenterId = presenter.id.trim();

    final matches = presentations.where((presentation) {
      return presentation.presenterId.trim() == presenterId;
    }).toList();

    matches.sort(_sortPresentations);

    return matches;
  }

  Future<List<Presenter>> _loadPresenters() async {
    final jsonString = await rootBundle.loadString(_presentersAssetPath);
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;

    return decoded.values.map((value) {
      return Presenter.fromJson(Map<String, dynamic>.from(value));
    }).toList();
  }

  Future<List<Presentation>> _loadHydratedPresentations() async {
    final presentationsString = await rootBundle.loadString(
      _presentationsAssetPath,
    );

    final presentationsJson =
        jsonDecode(presentationsString) as Map<String, dynamic>;

    final presenters = await _loadPresenters();

    final presentersById = {
      for (final presenter in presenters) presenter.id.trim(): presenter,
    };

    final presentations = presentationsJson.entries.map((entry) {
      final presentationMap = Map<String, dynamic>.from(entry.value);

      final presenterId =
          presentationMap["presenterId"]?.toString().trim() ?? "";

      final matchedPresenter = presentersById[presenterId];

      presentationMap["affiliation"] = matchedPresenter?.affiliations ?? [];

      return Presentation.fromJson(entry.key, presentationMap);
    }).toList();

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
