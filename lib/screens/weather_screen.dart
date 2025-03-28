import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/api_key.dart';
import '../widgets/weather_card.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Map<String, dynamic>? _weatherData;
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _cityController = TextEditingController(text: 'Mumbai');
  List<Map<String, dynamic>> _filteredTips = [];

  // Weather-triggered tips with string identifiers instead of functions
  final List<Map<String, dynamic>> _allTips = [
    {
      'title': 'Heavy Rain Alert',
      'content': 'Delay sowing operations and ensure proper drainage in fields',
      'condition': 'rain',
      'icon': Icons.umbrella,
    },
    {
      'title': 'Heat Wave Protection',
      'content': 'Irrigate fields in early morning to reduce water evaporation',
      'condition': 'temp>35',
      'icon': Icons.whatshot,
    },
    {
      'title': 'High Humidity Warning',
      'content': 'Monitor crops for fungal infections in high humidity conditions',
      'condition': 'humidity>80',
      'icon': Icons.opacity,
    },
    {
      'title': 'Cold Weather Advisory',
      'content': 'Protect seedlings from cold stress with mulch or covers',
      'condition': 'temp<10',
      'icon': Icons.ac_unit,
    },
    {
      'title': 'Windy Conditions',
      'content': 'Secure trellises and check for lodging in tall crops',
      'condition': 'wind>15',
      'icon': Icons.air,
    },
    {
      'title': 'Optimal Growing Weather',
      'content': 'Ideal conditions for field activities and plant growth',
      'condition': 'optimal',
      'icon': Icons.wb_sunny,
    },
  ];

  Future<void> _fetchWeather(String city) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$city,in&appid=$apiKey&units=metric'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          _weatherData = jsonDecode(response.body) as Map<String, dynamic>;
          _filterTips();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'City not found. Try another location!';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch weather: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _filterTips() {
    final weather = _weatherData?['weather'][0]['main'] as String?;
    final temp = _weatherData?['main']['temp'] as double?;
    final humidity = _weatherData?['main']['humidity'] as int?;
    final wind = _weatherData?['wind']['speed'] as double?;

    setState(() {
      _filteredTips = _allTips.where((tip) {
        final condition = tip['condition'] as String;

        switch (condition) {
          case 'rain':
            return weather == 'Rain';
          case 'temp>35':
            return (temp ?? 0) > 35;
          case 'temp<10':
            return (temp ?? 0) < 10;
          case 'humidity>80':
            return (humidity ?? 0) > 80;
          case 'wind>15':
            return (wind ?? 0) > 15;
          case 'optimal':
            return (temp ?? 0) > 20 &&
                (temp ?? 0) < 30 &&
                (humidity ?? 0) > 40 &&
                (humidity ?? 0) < 70;
          default:
            return false;
        }
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather(_cityController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Weather Guide', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      hintText: 'Enter city name',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.search),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _fetchWeather(_cityController.text),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_errorMessage.isNotEmpty)
              _buildErrorBanner(),

            if (_isLoading)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text('Fetching weather data...'),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _fetchWeather(_cityController.text),
                  child: ListView(
                    children: [
                      // Weather Card
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text('Current Weather in ${_cityController.text}',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${(_weatherData?['main']['temp'] as double?)?.toStringAsFixed(1)}°C',
                                    style: const TextStyle(
                                        fontSize: 42,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(width: 20),
                                  Image.network(
                                    'https://openweathermap.org/img/wn/${_weatherData?['weather'][0]['icon']}@2x.png',
                                    width: 80,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Wrap(
                                spacing: 20,
                                runSpacing: 15,
                                children: [
                                  _buildWeatherDetail('Humidity', '${_weatherData?['main']['humidity']}%', Icons.water_drop),
                                  _buildWeatherDetail('Wind', '${(_weatherData?['wind']['speed'] as double?)?.toStringAsFixed(1)} m/s', Icons.air),
                                  _buildWeatherDetail('Conditions', '${_weatherData?['weather'][0]['main']}', Icons.cloud),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Weather Tips Section
                      if (_filteredTips.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Text('Weather Advisory',
                              style: TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)),
                        ),
                        ..._filteredTips.map((tip) => _buildTipCard(tip)),
                      ] else
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(30.0),
                            child: Text('No special weather advisories currently',
                                style: TextStyle(fontSize: 30)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(String label, String value, IconData icon) {
    return SizedBox(
      width: 120,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Icon(icon, size: 28, color: Colors.green),
              const SizedBox(height: 5),
              Text(label, style: const TextStyle(fontSize: 12)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipCard(Map<String, dynamic> tip) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(tip['icon'] as IconData, color: Colors.green),
        title: Text(tip['title'] as String,
            style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(tip['content'] as String),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(child: Text(_errorMessage)),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => setState(() => _errorMessage = ''),
          ),
        ],
      ),
    );
  }}