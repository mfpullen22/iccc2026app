import "package:flutter/material.dart";
import "package:forui/forui.dart";
import "package:url_launcher/url_launcher.dart";

class VenueScreen extends StatelessWidget {
  const VenueScreen({super.key});

  static const String _venueName = "The Forum";
  static const String _venueAddress =
      "University of Exeter, Stocker Road, Exeter EX4 4QD, UK";

  static final Uri _googleMapsUri = Uri.parse(
    "https://www.google.com/maps/search/?api=1&query=The%20Forum%2C%20University%20of%20Exeter%2C%20Stocker%20Road%2C%20Exeter%20EX4%204QD%2C%20UK",
  );

  Future<void> _openGoogleMaps() async {
    if (!await launchUrl(
      _googleMapsUri,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception("Could not open Google Maps");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader.nested(
        title: const Text("Venue"),
        prefixes: [
          FHeaderAction.back(onPress: () => Navigator.of(context).pop()),
        ],
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  "assets/images/forum.jpg",
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 18),

              FCard(
                title: const Text(
                  _venueName,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                subtitle: const Text(_venueAddress),
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: FButton(
                    onPress: _openGoogleMaps,
                    child: const Text("Open in Google Maps"),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              const _VenueInfoCard(
                title: "How to get to The Forum",
                body:
                    "We advise you to use public transport to reach the University of Exeter. Whether you choose planes, trains, automobiles or coaches, Exeter is only 150 miles southwest of London and can be reached by direct transport links from the capital, as well as from Bristol, which also has an airport.",
              ),

              const SizedBox(height: 14),

              const _VenueInfoCard(
                title: "By car",
                sections: [
                  _VenueInfoSection(
                    heading: "Road directions",
                    body:
                        "The M4/M5 links Exeter directly to London, the Midlands, South Wales and the North, including Scotland. The average journey time from either London or the Midlands is 3 hours.",
                  ),
                  _VenueInfoSection(
                    heading: "Parking",
                    body:
                        "We strongly encourage people to reach the campus via public transport, including the UNI bus service. The Streatham Campus Car Park C is £10 per day Monday to Friday. Parking is available on-site; please check University parking information for charges and details. Those staying in Holland Hall have a parking permit included in their booking.",
                  ),
                ],
              ),

              const SizedBox(height: 14),

              const _VenueInfoCard(
                title: "By bus",
                body:
                    "Buses run to the conference several times an hour. The UNI bus service serves the University of Exeter. The nearest stop is North Park Road, Stop ID: dvngjamt.",
              ),

              const SizedBox(height: 14),

              const _VenueInfoCard(
                title: "By train",
                body:
                    "Exeter is just over 2 hours by train from London, with GWR offering discounted rail fares for conference delegates.",
                sections: [
                  _VenueInfoSection(
                    heading: "Discounted train fares",
                    body:
                        "We encourage attendees to travel to Exeter by rail. Frequent trains depart from London Paddington, which is easily accessed from Heathrow Airport via the London Underground or Heathrow Express. Heathrow Express tickets are substantially less expensive if purchased 30 days in advance.",
                  ),
                  _VenueInfoSection(
                    heading: "ICCC2026 GWR conference rates",
                    body:
                        "A standard open return ticket from Paddington to Exeter costs £115. A reduced rate has been arranged for ICCC2026 attendees traveling from Paddington to Exeter. The ticket must be a return ticket on GWR-operated services and consists of a fixed outbound ticket and a flexible open return to be used within 28 days of outbound travel.\n\nConference Package Standard: £54.00\nConference Package 1st Class: £114.00",
                  ),
                  _VenueInfoSection(
                    heading: "How to book",
                    body:
                        "To access this rate, please call the GWR Business Direct team at +44 345 700 0125 and select Business Direct – Option 4, Option 4. The team is available Monday–Friday, 08:00–18:00 BST.\n\nFor card payments, you must have an account registered in the UK, and American Express is not accepted. International bank transfers are accepted but require at least 5 days notice. All other bookings need to be made at least 1 day in advance of travel.",
                  ),
                ],
              ),

              const SizedBox(height: 14),

              const _VenueInfoCard(
                title: "By plane",
                body:
                    "Exeter International Airport is located approximately six miles from the Streatham Campus. There are scheduled flights from around the world plus regular domestic flights from key UK cities including London City Airport, Manchester, Leeds, Belfast and Edinburgh.\n\nWhen flying to England, attendees have several airport options, particularly around London. London airports include Heathrow (LHR), Gatwick (LGW), Stansted (STN), Luton (LTN), and City Airport (LCY). From London, you can travel to Exeter by car, bus, or train.",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VenueInfoCard extends StatelessWidget {
  const _VenueInfoCard({
    required this.title,
    this.body,
    this.sections = const [],
  });

  final String title;
  final String? body;
  final List<_VenueInfoSection> sections;

  @override
  Widget build(BuildContext context) {
    return FCard(
      title: Text(
        title,
        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (body != null)
              Text(body!, style: const TextStyle(fontSize: 15, height: 1.45)),

            for (final section in sections) ...[
              if (body != null || section != sections.first)
                const SizedBox(height: 14),
              Text(
                section.heading,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                section.body,
                style: const TextStyle(fontSize: 15, height: 1.45),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VenueInfoSection {
  const _VenueInfoSection({required this.heading, required this.body});

  final String heading;
  final String body;
}
