import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MoreApps extends StatefulWidget {
  const MoreApps({super.key});

  @override
  _MoreAppsState createState() => _MoreAppsState();
}

class _MoreAppsState extends State<MoreApps> {
  final List<Map<String, dynamic>> apps = [
    {
      'name': 'Work Hub',
      'icon': FontAwesomeIcons.briefcase,
      'link': 'https://app.workhub24.com',
    },
    {
      'name': 'LMS',
      'icon': FontAwesomeIcons.book,
      'link': 'https://lms.mclarens.lk',
    },
    {
      'name': 'GAC Genie',
      'icon': FontAwesomeIcons.magic,
      'link': 'https://gacuae.sharepoint.com/',
    },
    {
      'name': 'Stationary Request',
      'icon': FontAwesomeIcons.clipboard,
      'link': 'https://office.mclarens.lk/',
    },
    {
      'name': 'Telephone Directory',
      'icon': FontAwesomeIcons.phone,
      'link': 'https://intranet.mclarens.lk/telephone-directory/',
    },
    {
      'name': 'OPS Job Tracker',
      'icon': FontAwesomeIcons.tasks,
      'link': 'https://opsjobtracker.gac.lk/',
    },
    {
      'name': 'IT Help Desk',
      'icon': FontAwesomeIcons.headset,
      'link': 'https://helpdesk.mclarens.lk/',
    },
    {
      'name': 'GAC Petty Cash',
      'icon': FontAwesomeIcons.wallet,
      'link': 'https://pettycash.gac.lk',
    },
    {
      'name': 'GAC Trip Bonus',
      'icon': FontAwesomeIcons.car,
      'link': 'https://tripbonus.gac.lk',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
  title: const Text(
    'More Apps',
    style: TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
  flexibleSpace: Container(
    decoration: const BoxDecoration(
      color: Color(0xFF6378AE), // Updated background color
    ),
  ),
),

      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double cardWidth =
                constraints.maxWidth / 3 - 16; // Width for each card

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                childAspectRatio: cardWidth /
                    (cardWidth * 1.3), // Adjust height proportionally
              ),
              itemCount: apps.length,
              itemBuilder: (context, index) {
                final app = apps[index];
                return GestureDetector(
                  onTap: () {
                    _launchURL(app['link']);
                  },
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: cardWidth / 2.5,
                            height: cardWidth / 2.5,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFF003764), Color(0xFF3D7CC9)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: FaIcon(
                                app['icon'],
                                size: cardWidth /
                                    6, // Adjust icon size for responsiveness
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          Text(
                            app['name'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  12.0, // Slightly smaller font to fit long names
                              color: Color(0xFF003764),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Function to launch the URL directly in an external browser
  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);

    try {
      // Checking if the URL can be launched
      bool canLaunchURL = await canLaunchUrl(uri);

      if (canLaunchURL) {
        // Launching the URL in an external web browser
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // If the URL can't be launched, show a message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    } catch (e) {
      // Catching any errors and displaying an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
