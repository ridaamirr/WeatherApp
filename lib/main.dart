import 'package:flutter/material.dart';
import 'weather_service.dart';
import 'forecast_page.dart';
import 'notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WeatherService _weatherService = WeatherService();
  TextEditingController _cityController = TextEditingController();
  String _temperature = '';
  String _cityName = '';
  String _errorMessage = '';

  void _fetchWeather() async {
    setState(() {
      _errorMessage = '';
      _temperature = '';
      _cityName = '';
    });
    try {
      final weather = await _weatherService.getWeather(_cityController.text);
      setState(() {
        _temperature = '${weather['main']['temp'].toInt()}';
        _cityName = _cityController.text;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching weather data';
      });
    }
    await NotificationService.showDailyNotification(
      id: 0,
      title: 'Weather Update',
      body: 'Current temperature in $_cityName: $_temperature°C',
      scheduledTime: TimeOfDay(hour: 21, minute: 13),
    );

  }


  void _navigateToForecast() {
    if (_cityName.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ForecastPage(city: _cityName),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: 'Enter city name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _fetchWeather,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Search',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            if (_errorMessage.isEmpty && _temperature.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _temperature,
                    style: TextStyle(fontSize: 64), // Increased the font size
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 24, color: Colors.blue),
                      SizedBox(width: 4),
                      Text(
                        _cityName,
                        style: TextStyle(fontSize: 24, color: Colors.black54),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _navigateToForecast,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'View Forecast',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(fontSize: 20, color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
