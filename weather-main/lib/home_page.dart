import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool _isDialogVisible = false; // Variable to toggle the dialog box
  String _weatherDescription = "Loading weather...";
  String _temperature = "--";
  String _location = "Your Location";
  String _highTemp = "--";
  String _lowTemp = "--";

  final String _apiKey = 'ca7125e0df61234bbfddef29c1ababde';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _toggleTextBox() {
    // Function to toggle the dialog box on and off
    setState(() {
      _isDialogVisible = !_isDialogVisible;
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _weatherDescription = "Location services are disabled.";
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _weatherDescription = "Location permissions are denied.";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _weatherDescription = "Location permissions are permanently denied.";
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _fetchWeather(position.latitude, position.longitude);
  }

  Future<void> _fetchWeather(double latitude, double longitude) async {
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=metric&appid=$_apiKey'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        _location = data['name'];
        _temperature = data['main']['temp'].toString();
        _weatherDescription = data['weather'][0]['description'];
        _highTemp = data['main']['temp_max'].toString();
        _lowTemp = data['main']['temp_min'].toString();
      });
    } else {
      setState(() {
        _weatherDescription = "Failed to fetch weather data.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        // Gesture Detector to disable searchbar when tapped
        onTap: () {
          if (_isDialogVisible) {
            _toggleTextBox();
          }
        },
        child: Stack(
          // Stack to overlay the Searchbar on the main page
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  // Scrollable widget
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                              'images/Sunny/Trees.png'), // Background image
                          fit: BoxFit.fitWidth, // Image fit the width
                          alignment: Alignment.bottomCenter,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(
                            16.0), // Padding around the main content
                        child: Column(
                          children: [
                            const SizedBox(height: 20), // spacing
                            OutlinedButton.icon(
                              // Button to toggle the search bar
                              onPressed: _toggleTextBox,
                              icon: const Icon(
                                Icons.search,
                                color: Colors.black,
                              ),
                              style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  side: const BorderSide(
                                      width: 1, color: Colors.grey)),
                              label: const Text(
                                'My Location',
                                style: TextStyle(
                                    fontSize: 46,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black),
                              ),
                            ),
                            Center(
                              child: Text(
                                _location,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                              ),
                            ),
                            const SizedBox(height: 20), //spacing
                            Column(
                              mainAxisAlignment: MainAxisAlignment
                                  .center, // centering the content
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                    'images/Sunny/SUN.png'), // Image of the sun
                                const SizedBox(height: 10), //spacing
                                Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFB2E4FA)
                                            .withOpacity(0.3),
                                        offset: const Offset(0, 4),
                                        blurRadius: 4,
                                        spreadRadius: 0,
                                      ),
                                    ],
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  margin: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      Text('$_temperature°',
                                          style: const TextStyle(fontSize: 80)),
                                      Text(_weatherDescription),
                                      Text('H:$_highTemp    L:$_lowTemp'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              // widget design for the today's weather forecast
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFB2E4FA)
                                        .withOpacity(0.3), //shadow color
                                    offset: const Offset(0, 4), // offset
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                  ),
                                ],
                                color: Colors.white
                                    .withOpacity(0.3), // background color
                                borderRadius:
                                BorderRadius.circular(20), // border corners
                              ),
                              // hourly forecast widget
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.all(16),
                              child: SingleChildScrollView(
                                //horizontally scrollable widget
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  // row for every hour
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      // column to display time, weather conditions and temperature
                                      children: [
                                        const Center(
                                          child: Text('1pm'),
                                        ),
                                        Image.asset('images/Symbols/cloud.png'),
                                        const Center(
                                          child: Text(
                                            '17°',
                                            style: TextStyle(
                                              // temp style
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                        width: 28), //  horizontal spacing
                                    Column(
                                      children: [
                                        const Center(
                                          child: Text('2pm'),
                                        ),
                                        Image.asset(
                                            'images/Symbols/cloud-drizzle.png'),
                                        const Center(
                                          child: Text(
                                            '15°',
                                            style: TextStyle(
                                              // temp style
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                        width: 28), //  horizontal spacing
                                    Column(
                                      children: [
                                        const Center(
                                          child: Text('3pm'),
                                        ),
                                        Image.asset(
                                            'images/Symbols/cloud-lightning.png'),
                                        const Center(
                                          child: Text(
                                            '13°',
                                            style: TextStyle(
                                              // temp style
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                        width: 28), //  horizontal spacing
                                    Column(
                                      children: [
                                        const Center(
                                          child: Text('4pm'),
                                        ),
                                        Image.asset(
                                            'images/Symbols/cloud-snow.png'),
                                        const Center(
                                          child: Text(
                                            '12°',
                                            style: TextStyle(
                                              // temp style
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                        width: 28), //  horizontal spacing
                                    Column(
                                      children: [
                                        const Center(
                                          child: Text('5pm'),
                                        ),
                                        Image.asset(
                                            'images/Symbols/sun logo.png'),
                                        const Center(
                                          child: Text(
                                            '11°',
                                            style: TextStyle(
                                              // temp style
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                        width: 28), //  horizontal spacing
                                    Column(
                                      children: [
                                        const Center(
                                          child: Text('6pm'),
                                        ),
                                        Image.asset(
                                            'images/Symbols/cloud-lightning.png'),
                                        const Center(
                                          child: Text(
                                            '20°',
                                            style: TextStyle(
                                              // temp style
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              // trees asset display
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('images/Sunny/Trees.png'),
                                  fit: BoxFit.cover, // image fit
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            if (_isDialogVisible) // to display the search bar
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // blur effect
                child: Container(
                  color: Colors.black.withOpacity(0.5), // blur darkening effect
                  child: Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 40), // spacing
                          Container(
                            height: 50,
                            width: 300,
                            decoration: BoxDecoration(
                              // search bar design
                                color: Colors.white,
                                border: Border.all(color: Colors.black, width: 1.0),
                                borderRadius: BorderRadius.circular(10)),
                            child: TextField(
                              // search bar text field
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[a-zA-Z,\s]'))
                              ], // Restrict to alphabets and whitespaces

                              decoration: const InputDecoration(
                                // Text field design
                                hintText: 'Berlin, Germany',
                                prefixIcon: Icon(Icons.search),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 12.0),
                              ),
                            ),
                          )
                        ],
                      )),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
