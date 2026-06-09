import 'package:flutter/material.dart';

class Presentation {
  const Presentation({
    required this.id,
    required this.title,
    required this.type,
    required this.track,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.presenterFirstName,
    required this.presenterLastNames,
    required this.abstract,
    required this.presenterEmail,
    required this.affiliation,
    required this.presenterId,
  });

  final String id;
  final String title;
  final String type;
  final String track;
  final int day;
  final String startTime;
  final String endTime;
  final String presenterFirstName;
  final String presenterLastNames;
  final String abstract;
  final String presenterEmail;
  final List<String> affiliation;
  final String presenterId;

  factory Presentation.fromJson(String id, Map<String, dynamic> json) {
    return Presentation(
      id: id,
      title: json["title"]?.toString() ?? "",
      type: json["type"]?.toString().trim().toLowerCase() ?? "",
      track: json["track"]?.toString().trim().toLowerCase() ?? "",
      day: int.tryParse(json["day"]?.toString() ?? "") ?? 0,
      startTime: json["startTime"]?.toString() ?? "",
      endTime: json["endTime"]?.toString() ?? "",
      presenterFirstName: json["presenterFirstName"]?.toString() ?? "",
      presenterLastNames: json["presenterLastNames"]?.toString() ?? "",
      abstract: json["abstract"]?.toString() ?? "",
      presenterEmail: json["presenterEmail"]?.toString() ?? "",
      affiliation:
          (json["affiliation"] as List<dynamic>?)
              ?.map((item) => item.toString())
              .where((item) => item.trim().isNotEmpty)
              .toList() ??
          [],
      presenterId: json["presenterId"]?.toString().trim() ?? "",
    );
  }

  String get displayTitle {
    if (title.trim().isEmpty) return "Title Pending";
    return title.trim();
  }

  String get presenterName {
    final name = "$presenterFirstName $presenterLastNames".trim();
    return name.isEmpty ? "" : name;
  }

  bool get isMealOrSpecial {
    return type == "meal" || track == "special";
  }

  String get shortTitle {
    final trimmed = displayTitle.trim();

    if (trimmed.isEmpty) return "";

    final words = trimmed.split(RegExp(r'\s+'));

    if (words.length <= 5) {
      return trimmed;
    }

    return "${words.take(5).join(' ')}...";
  }

  String get typeLabel {
    switch (type.toLowerCase()) {
      case "talk":
        return "Talk";
      case "poster":
        return "Poster";
      default:
        return "";
    }
  }

  String get dateTimeLabel {
    if (type.toLowerCase() != "talk") {
      return "";
    }

    return "$dayLabel • $startTime - $endTime";
  }

  String get dayLabel {
    switch (day) {
      case 0:
        return "Sunday, June 28";
      case 1:
        return "Monday, June 29";
      case 2:
        return "Tuesday, June 30";
      case 3:
        return "Wednesday, July 1";
      case 4:
        return "Thursday, July 2";
      case 5:
        return "Friday, July 3";
      default:
        return "";
    }
  }

  Color get trackColor {
    switch (track) {
      case "clinicaladv":
        return Colors.grey.shade700;
      case "drugs":
        return Colors.amber;
      case "genomics":
        return Colors.deepOrange;
      case "hostpathogen":
        return Colors.deepPurple;
      case "immunology":
        return Colors.pink;
      case "cellbio":
        return Colors.lightBlue;
      default:
        return Colors.green;
    }
  }

  String get trackLabel {
    switch (track) {
      case "clinicaladv":
        return "Clinical Advances";
      case "drugs":
        return "Drugs";
      case "genomics":
        return "Genomics";
      case "hostpathogen":
        return "Host-Pathogen";
      case "immunology":
        return "Immunology";
      case "cellbio":
        return "Cell Biology";
      case "special":
        return "Special Event";
      default:
        return type == "meal" ? "Meal" : "Other";
    }
  }
}
