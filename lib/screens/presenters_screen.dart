import "package:flutter/material.dart";
import "package:iccc2026/models/presenter.dart";
import "package:iccc2026/repositories/conference_repository.dart";
import "package:iccc2026/repositories/local_json_conference_repository.dart";
import "package:iccc2026/screens/presenter_details_screen.dart";

class PresentersScreen extends StatefulWidget {
  const PresentersScreen({
    super.key,
    this.repository = const LocalJsonConferenceRepository(),
  });

  final ConferenceRepository repository;

  @override
  State<PresentersScreen> createState() => _PresentersScreenState();
}

class _PresentersScreenState extends State<PresentersScreen> {
  final TextEditingController _searchController = TextEditingController();

  late final Future<List<Presenter>> _presentersFuture;

  String _searchText = "";

  @override
  void initState() {
    super.initState();

    _presentersFuture = widget.repository.getPresenters();

    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Presenter> _filterPresenters(List<Presenter> presenters) {
    if (_searchText.isEmpty) return presenters;

    return presenters.where((presenter) {
      return presenter.searchableName.contains(_searchText);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Presenters")),
      body: SafeArea(
        child: FutureBuilder<List<Presenter>>(
          future: _presentersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    "Unable to load presenters.\n\n${snapshot.error}",
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final presenters = _filterPresenters(snapshot.data ?? []);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search presenters",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchText.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _searchController.clear,
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: presenters.isEmpty
                      ? const Center(child: Text("No presenters found."))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: presenters.length,
                          itemBuilder: (context, index) {
                            final presenter = presenters[index];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Card(
                                clipBehavior: Clip.antiAlias,
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 8,
                                  ),
                                  title: Text(
                                    presenter.fullName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => PresenterDetailsScreen(
                                          presenter: presenter,
                                          repository: widget.repository,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
