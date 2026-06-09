import "package:iccc2026/models/presentation.dart";
import "package:iccc2026/models/presenter.dart";

abstract class ConferenceRepository {
  Future<List<Presenter>> getPresenters();

  Future<List<Presentation>> getPresentations();

  Future<List<Presentation>> getPresentationsForPresenter(Presenter presenter);
}
