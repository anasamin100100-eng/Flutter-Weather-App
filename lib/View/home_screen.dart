
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/Provider/theme_provider.dart';
import 'package:weather_app/Service/api_service.dart';
import 'package:weather_app/View/weekly_forecast.dart';
import 'package:geolocator/geolocator.dart';

class WeatherAppHomeScreen extends ConsumerStatefulWidget {
  const WeatherAppHomeScreen({super.key});

  @override
  ConsumerState<WeatherAppHomeScreen> createState() =>
      _WeatherAppHomeScreenState();
}

class _WeatherAppHomeScreenState
    extends ConsumerState<WeatherAppHomeScreen> {

  bool _hasSearchedCity = false;

  String initialLocation = "Karachi";

  String city = "Karachi";
  String country = "Pakistan";

  final _weatherService = WeatherApiService();

  final TextEditingController _searchController =
  TextEditingController();

  final ScrollController _hourlyScrollController =
  ScrollController();

  Map<String, dynamic> currentValue = {};

  List<dynamic> hourly = [];
  List<dynamic> pastWeek = [];
  List<dynamic> next7days = [];

  bool isLoading = false;

  // Selected city's local date and time.
  DateTime? _weatherLocalTime;

  @override
  void initState() {
    super.initState();
    _loadInitialWeather();
  }

  // GET INITIAL WEATHER USING GPS
  Future<void> _loadInitialWeather() async {
    try {
      bool serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        initialLocation = "Karachi";
        await _fetchWeather(location: initialLocation);
        return;
      }

      LocationPermission permission =
      await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        initialLocation = "Karachi";
        await _fetchWeather(location: initialLocation);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );

      String coordinates =
          "${position.latitude},${position.longitude}";

      // Save actual GPS coordinates.
      initialLocation = coordinates;

      await _fetchWeather(location: coordinates);

    } catch (e) {
      // Use Karachi if GPS fails.
      initialLocation = "Karachi";
      await _fetchWeather(location: initialLocation);
    }
  }

  // FETCH WEATHER DATA
  Future<void> _fetchWeather({
    String? location,
    bool isSearch = false,
  }) async {

    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final searchLocation = location ?? city;

      final forecast =
      await _weatherService.getHourlyForecast(searchLocation);

      final past =
      await _weatherService.getPastSevenDaysWeather(
        searchLocation,
      );

      if (!mounted) return;

      // Get the selected city's local time from WeatherAPI.
      final localTimeString =
      forecast['location']?['localtime'];

      setState(() {
        currentValue = forecast['current'] ?? {};

        hourly =
            forecast['forecast']?['forecastday']?[0]?['hour'] ?? [];

        next7days =
            forecast['forecast']?['forecastday'] ?? [];

        pastWeek = past;

        city = forecast['location']?['name'] ?? city;

        country = forecast['location']?['country'] ?? country;

        _weatherLocalTime = localTimeString != null
            ? DateTime.tryParse(localTimeString)
            : null;

        _hasSearchedCity = isSearch;

        isLoading = false;
      });

      // Scroll to the current hour after the UI is updated.
      _scrollToCurrentHour();

    } catch (e) {
      if (!mounted) return;

      setState(() {
        currentValue = {};
        hourly = [];
        pastWeek = [];
        next7days = [];
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Unable to fetch weather. Please check the city or your internet connection.",
          ),
        ),
      );
    }
  }

  // AUTOMATICALLY CENTER THE CURRENT HOUR
  void _scrollToCurrentHour() {

    WidgetsBinding.instance.addPostFrameCallback((_) {

      if (!mounted || !_hourlyScrollController.hasClients) {
        return;
      }

      if (hourly.isEmpty) return;

      final now = _weatherLocalTime ?? DateTime.now();

      final currentIndex = hourly.indexWhere((hour) {

        final hourTime = DateTime.parse(hour['time']);

        return hourTime.year == now.year &&
            hourTime.month == now.month &&
            hourTime.day == now.day &&
            hourTime.hour == now.hour;
      });

      if (currentIndex == -1) return;

      // Each hourly card occupies exactly 86 pixels.
      const double itemWidth = 86.0;

      final screenWidth = MediaQuery.of(context).size.width;

      // Calculate the offset needed to center the current card.
      double offset =
          (currentIndex * itemWidth) -
              ((screenWidth - itemWidth) / 2);

      offset = offset.clamp(
        0.0,
        _hourlyScrollController.position.maxScrollExtent,
      );

      _hourlyScrollController.jumpTo(offset);
    });
  }

  // FORMAT TIME
  String formatTime(String timeString) {
    DateTime time = DateTime.parse(timeString);
    return DateFormat.j().format(time);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _hourlyScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final themeMode = ref.watch(themeNotifierProvider);

    final notifier = ref.read(themeNotifierProvider.notifier);

    final isDark = themeMode == ThemeMode.dark;

    String iconPath =
        currentValue['condition']?['icon'] ?? '';

    String imageUrl =
    iconPath.isNotEmpty ? "https:$iconPath" : "";

    Widget imageWidgets = imageUrl.isNotEmpty
        ? Image.network(
      imageUrl,
      height: 200,
      width: 200,
      fit: BoxFit.cover,
    )
        : const SizedBox();

    return PopScope(
      canPop: !_hasSearchedCity,

      onPopInvokedWithResult: (didPop, result) {

        if (didPop) return;

        if (_hasSearchedCity) {

          // Clear the search field.
          _searchController.clear();

          // Restore original GPS location or Karachi.
          _fetchWeather(
            location: initialLocation,
            isSearch: false,
          );
        }
      },

      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,

        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,

          actions: [

            const SizedBox(width: 25),

            SizedBox(
              width: 320,
              height: 50,

              child: TextField(
                controller: _searchController,

                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),

                onSubmitted: (value) {

                  if (value.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter a city name"),
                      ),
                    );
                    return;
                  }

                  _fetchWeather(
                    location: value.trim(),
                    isSearch: true,
                  );
                },

                decoration: InputDecoration(
                  labelText: "Search City",

                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.surface,
                  ),

                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.surface,
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),

            GestureDetector(
              onTap: notifier.toggleTheme,

              child: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: isDark ? Colors.black : Colors.white,
                size: 30,
              ),
            ),

            const SizedBox(width: 25),
          ],
        ),

        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              const SizedBox(height: 20),

              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                )

              else ...[

                if (currentValue.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,

                    children: [

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                        ),

                        child: FittedBox(
                          fit: BoxFit.scaleDown,

                          child: Text(
                            "$city${country.isNotEmpty ? ', $country' : ''}",

                            textAlign: TextAlign.center,

                            style: TextStyle(
                              fontSize: 40,
                              color: Theme.of(context)
                                  .colorScheme.secondary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),

                      Text(
                        "${currentValue['temp_c']}°C",

                        style: TextStyle(
                          fontSize: 50,
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        "${currentValue['condition']['text']}",

                        style: TextStyle(
                          fontSize: 22,
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      imageWidgets,

                      // WEATHER DETAILS
                      Padding(
                        padding: const EdgeInsets.all(15),

                        child: Container(
                          height: 100,
                          width: double.maxFinite,

                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,

                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary,
                                offset: const Offset(1, 1),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],

                            borderRadius: BorderRadius.circular(30),
                          ),

                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceAround,

                            children: [

                              // HUMIDITY
                              Column(
                                mainAxisAlignment:
                                MainAxisAlignment.center,

                                children: [

                                  Image.network(
                                    "https://cdn-icons-png.flaticon.com/512/4148/4148460.png",
                                    width: 30,
                                    height: 30,
                                  ),

                                  Text(
                                    "${currentValue['humidity']}%",

                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme.secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  Text(
                                    "Humidity",

                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme.secondary,
                                    ),
                                  ),
                                ],
                              ),

                              // WIND
                              Column(
                                mainAxisAlignment:
                                MainAxisAlignment.center,

                                children: [

                                  Image.network(
                                    "https://cdn-icons-png.flaticon.com/512/5918/5918654.png",
                                    width: 30,
                                    height: 30,
                                  ),

                                  Text(
                                    "${currentValue['wind_kph']} kph",

                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme.secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  Text(
                                    "Wind",

                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme.secondary,
                                    ),
                                  ),
                                ],
                              ),

                              // MAX TEMPERATURE
                              Column(
                                mainAxisAlignment:
                                MainAxisAlignment.center,

                                children: [

                                  Image.network(
                                    "https://cdn-icons-png.flaticon.com/512/6281/6281340.png",
                                    width: 30,
                                    height: 30,
                                  ),

                                  Text(
                                    hourly.isNotEmpty
                                        ? "${hourly.map((h) => h['temp_c']).reduce((a, b) => a > b ? a : b)}"
                                        : "N/A",

                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme.secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  Text(
                                    "Max Temp",

                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // HOURLY FORECAST
                      Container(
                        height: 250,
                        width: double.maxFinite,

                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme.secondary,
                            ),
                          ),

                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(40),
                          ),
                        ),

                        child: Column(
                          children: [

                            const SizedBox(height: 10),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),

                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,

                                children: [

                                  Text(
                                    "Today Forecast",

                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme.secondary,
                                    ),
                                  ),

                                  GestureDetector(
                                    onTap: () {

                                      Navigator.push(
                                        context,

                                        MaterialPageRoute(
                                          builder: (context) =>
                                              WeeklyForecast(
                                                city: city,
                                                currentValue: currentValue,
                                                pastWeek: pastWeek,
                                                next7days: next7days,
                                              ),
                                        ),
                                      );
                                    },

                                    child: Text(
                                      "Weekly Forecast",

                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme.onPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Divider(
                              color: Theme.of(context)
                                  .colorScheme.secondary,
                            ),

                            const SizedBox(height: 10),

                            SizedBox(
                              height: 165,

                              child: ListView.builder(
                                controller: _hourlyScrollController,

                                scrollDirection: Axis.horizontal,

                                itemCount: hourly.length,

                                itemBuilder: (context, index) {

                                  final hour = hourly[index];

                                  final now =
                                      _weatherLocalTime ?? DateTime.now();

                                  final hourTime =
                                  DateTime.parse(hour['time']);

                                  final isCurrentHour =
                                      now.year == hourTime.year &&
                                          now.month == hourTime.month &&
                                          now.day == hourTime.day &&
                                          now.hour == hourTime.hour;

                                  return SizedBox(
                                    width: 86,

                                    child: Padding(
                                      padding: const EdgeInsets.all(5),

                                      child: Container(
                                        height: 150,
                                        padding: const EdgeInsets.all(8),

                                        decoration: BoxDecoration(
                                          color: isCurrentHour
                                              ? Colors.orangeAccent
                                              : Colors.black38,

                                          borderRadius:
                                          BorderRadius.circular(40),
                                        ),

                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,

                                          children: [

                                            Text(
                                              isCurrentHour
                                                  ? "Now"
                                                  : formatTime(hour['time']),

                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme.secondary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),

                                            const SizedBox(height: 10),

                                            Image.network(
                                              "https:${hour['condition']?['icon']}",
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                            ),

                                            const SizedBox(height: 10),

                                            Text(
                                              "${hour["temp_c"]}°C",

                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme.secondary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
