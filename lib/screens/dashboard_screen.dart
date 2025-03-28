import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'weather_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<void> _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => showAboutDialog(
              context: context,
              applicationName: 'Farm Assist',
              applicationVersion: '1.0.0',
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 0.9, // Added to prevent overflow
          children: [
            _FeatureCard(
              title: 'Crop Doctor',
              icon: Icons.health_and_safety,
              onTap: () => _launchURL(
                'https://huggingface.co/spaces/kellozr/Plant_Disease_Detection',
              ),
            ),
            _FeatureCard(
              title: 'Weather Guide',
              icon: Icons.cloud,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WeatherScreen(),
                ),
              ),
            ),
            _FeatureCard(
              title: 'Farmers Forum',
              icon: Icons.forum,
              onTap: () => _launchURL('https://foremweb-de866.web.app/'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Prevents overflow
            children: [
              Icon(icon, size: 40, color: Colors.green),
              const SizedBox(height: 10),
              Flexible( // Wraps text to prevent overflow
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}