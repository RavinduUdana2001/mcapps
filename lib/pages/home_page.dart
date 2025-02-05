import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'mcalets.dart';
import 'moreapps.dart';
import 'news.dart';

class HomePage extends StatelessWidget {
  final Map<String, dynamic> userData; // Added userData parameter

  const HomePage({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String headerImage = 'assets/123.jpg';
    final String logoImage = 'assets/mcapps.png';

    final List<Map<String, String>> firstRowItems = [
      {
        'name': 'Group Intranet',
        'icon': 'fa-solid fa-users',
        'url': 'https://intranet.mclarens.lk',
      },
      {
        'name': 'Web Mail Login',
        'icon': 'fa-solid fa-envelope',
        'url': 'https://outlook.cloud.microsoft/mail/',
      },
      {
        'name': 'HRIS Portal',
        'icon': 'fa-solid fa-chalkboard-user',
        'url': 'https://mhl.peopleshr.com/hr/',
      },
    ];

    final List<Map<String, dynamic>> secondRowItems = [
      {
        'name': 'More Apps',
        'icon': 'fa-solid fa-ellipsis-h',
        'page': MoreApps(),
      },
      {
        'name': 'Mc Alerts',
        'icon': 'fa-solid fa-bell',
        'page':  McAlertsPage(),
      },
      {
        'name': 'News and Events',
        'icon': 'fa-solid fa-newspaper',
        'page':  News(),
      },
    ];

    double screenHeight = MediaQuery.of(context).size.height;
    double bodyHeight = screenHeight * 1;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Colors.blueAccent,
          ),
        ),
        elevation: 4,
        title: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                logoImage,
                height: 60,
                width: 60,
              ),
              const SizedBox(width: 8),
              const Text(
                'McLarens Group',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        height: bodyHeight,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: 210,
                margin: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(headerImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(firstRowItems.length, (index) {
                    final item = firstRowItems[index];
                    return _buildCard(context, item);
                  }),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(secondRowItems.length, (index) {
                  final item = secondRowItems[index];
                  return _buildCard(context, item);
                }),
              ),
              const SizedBox(height: 30),
              // Displaying user data

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        if (item['url'] != null) {
          _launchURL(item['url']!);
        } else if (item['page'] is Widget) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => item['page'] as Widget),
          );
        }
      },
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: SizedBox(
          height: 110,
          width: 100,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FaIcon(
                  _getIcon(item['icon']!),
                  size: 35,
                  color: const Color(0xFF003764),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    item['name']!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      overflow: TextOverflow.ellipsis,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'fa-solid fa-users':
        return FontAwesomeIcons.users;
      case 'fa-solid fa-envelope':
        return FontAwesomeIcons.envelope;
      case 'fa-solid fa-chalkboard-user':
        return FontAwesomeIcons.chalkboardUser;
      case 'fa-solid fa-ellipsis-h':
        return FontAwesomeIcons.ellipsisH;
      case 'fa-solid fa-bell':
        return FontAwesomeIcons.bell;
      case 'fa-solid fa-newspaper':
        return FontAwesomeIcons.newspaper;
      default:
        return FontAwesomeIcons.circle;
    }
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}
