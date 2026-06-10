import "package:flutter/material.dart";
import "package:iccc2026/models/presentation.dart";
import "package:iccc2026/repositories/conference_repository.dart";
import "package:iccc2026/repositories/local_json_conference_repository.dart";
import "package:iccc2026/screens/presentation_details_screen.dart";

class AbstractsScreen extends StatefulWidget {
  const AbstractsScreen({
    super.key,
    this.repository = const LocalJsonConferenceRepository(),
  });

  final ConferenceRepository repository;

  @override
  State<AbstractsScreen> createState() => _AbstractsScreenState();
}

class _AbstractsScreenState extends State<AbstractsScreen> {
  final TextEditingController _searchController = TextEditingController();

  late final Future<List<Presentation>> _presentationsFuture;

  String _searchText = "";

  @override
  void initState() {
    super.initState();

    _presentationsFuture = widget.repository.getPresentations();

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

  List<Presentation> _filterPresentations(List<Presentation> presentations) {
    if (_searchText.isEmpty) return [];

    final queryParts = _searchText
        .split(RegExp(r"\s+"))
        .where((part) => part.trim().isNotEmpty)
        .toList();

    return presentations.where((presentation) {
      final searchableText = [
        presentation.displayTitle,
        presentation.abstract,
        presentation.presenterFirstName,
        presentation.presenterLastNames,
        presentation.presenterName,
      ].join(" ").toLowerCase();

      return queryParts.every(searchableText.contains);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Abstracts")),
      body: SafeArea(
        child: FutureBuilder<List<Presentation>>(
          future: _presentationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    "Unable to load abstracts.\n\n${snapshot.error}",
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final presentations = _filterPresentations(snapshot.data ?? []);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search abstracts or authors",
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
                  child: _searchText.isEmpty
                      ? const Center(
                          child: Text("Search for a topic or author"),
                        )
                      : presentations.isEmpty
                      ? const Center(child: Text("No abstracts found."))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: presentations.length,
                          itemBuilder: (context, index) {
                            final presentation = presentations[index];

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
                                    vertical: 10,
                                  ),
                                  title: Text(
                                    "\"${presentation.displayTitle}\"",
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      presentation.presenterName.isEmpty
                                          ? "Author Pending"
                                          : presentation.presenterName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            PresentationDetailsScreen(
                                              presentation: presentation,
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
