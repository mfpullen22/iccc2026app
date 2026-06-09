class Presenter {
  const Presenter({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.affiliations,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final List<String> affiliations;

  String get fullName {
    final name = "$firstName $lastName".trim();
    return name.isEmpty ? "Name Pending" : name;
  }

  String get searchableName => fullName.toLowerCase();

  factory Presenter.fromJson(Map<String, dynamic> json) {
    final rawAffiliation = json["affiliation"];

    final affiliations = rawAffiliation is List
        ? rawAffiliation.map((item) => item.toString()).toList()
        : rawAffiliation == null || rawAffiliation.toString().trim().isEmpty
        ? <String>[]
        : <String>[rawAffiliation.toString()];

    return Presenter(
      id: json["id"]?.toString() ?? "",
      firstName: json["firstName"]?.toString().trim() ?? "",
      lastName: json["lastName"]?.toString().trim() ?? "",
      email: json["email"]?.toString().trim() ?? "",
      affiliations: affiliations,
    );
  }
}
