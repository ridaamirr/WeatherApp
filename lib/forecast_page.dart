import 'package:flutter/material.dart';
import 'weather_service.dart';

class ForecastPage extends StatefulWidget {
  final String city;

  ForecastPage({required this.city});

  @override
  _ForecastPageState createState() => _ForecastPageState();
}

class _ForecastPageState extends State<ForecastPage> {
  final WeatherService _weatherService = WeatherService();
  late Future<List<dynamic>> _forecastData;

  @override
  void initState() {
    super.initState();
    _forecastData = _weatherService.getForecast(widget.city);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Forecast for ${widget.city}'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _forecastData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final forecastList = snapshot.data!;
            return ListView.builder(
              itemCount: forecastList.length,
              itemBuilder: (context, index) {
                final forecast = forecastList[index];
                print(forecast);
                final dateTime = DateTime.parse(forecast['dt_txt']);
                final temp = forecast['main']['temp'].toInt();
                final description = forecast['weather'][0]['description'];
                final iconCode = forecast['weather'][0]['icon'];

                return ListTile(
                  leading: Image.network('http://openweathermap.org/img/wn/$iconCode@2x.png'),
                  title: Text('${dateTime.toLocal()}'),
                  subtitle: Text('$temp°C, $description'),
                );
              },
            );
          }
        },
      ),
    );
  }
}

