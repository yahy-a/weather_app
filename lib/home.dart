
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/weather.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WeatherService _weatherService = WeatherService();
  final _formKey = GlobalKey<FormState>();
  String? cityName;
  bool _isLoading = false;

  final TextEditingController _citController = TextEditingController();

  Future<void> _getWeatherByLocation()async{
    setState(() {
      _isLoading = true; // set loading state to true
    });
    await Future.delayed(const Duration(seconds: 1));
    try{
      Position? position = await _getPosition();
      if(position != null){
        final data = await _weatherService.fetchDataByLocation(position.latitude, position.longitude);
        _showAlertDialouge(data);
      }
    }
    catch (e) {
      _showErrorDialouge(e.toString());
    }
    finally{
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Position?> _getPosition() async{
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled){
      return Future.error("Location services are disabled.");
    }

    permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.denied){
        return Future.error("Location permissions are denied");
      }
    }
    if(permission == LocationPermission.deniedForever){
      return Future.error("Location permissions are permanently denied, we cannot request permissions.");
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      String cityName = _citController.text;
      // _citController.clear();
      setState(() {
        _isLoading = true;
      });
      await Future.delayed(const Duration(seconds: 1));

      try {
        final data = await _weatherService.fetchData(cityName);
        _showAlertDialouge(data);
      } catch (e) {
        _showErrorDialouge(e.toString());
      }
      finally{
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAlertDialouge(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) {
        IconData weatherIcon = Icons.sunny;

        if (data['weather'][0]['main'] == 'Clear') {
          weatherIcon = Icons.sunny;
        } else if (data['weather'][0]['main'] == 'Clouds') {
          weatherIcon = Icons.cloud;
        } else if (data['weather'][0]['main'] == 'Rain') {
          weatherIcon = Icons.water_drop_outlined;
        } else if (data['weather'][0]['main'] == 'Snow') {
          weatherIcon = Icons.ac_unit;
        } else if (data['weather'][0]['main'] == 'Thunderstorm') {
          weatherIcon = Icons.thunderstorm;
        }

        return AlertDialog(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          backgroundColor: const Color.fromRGBO(23, 42, 58, 9.0),
          title: Stack(
            children: [
              const Align(
                alignment: Alignment.center,
                child: Text(
                  'Weather',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Blinker',
                    fontWeight: FontWeight.w500,
                    fontSize: 22,
                  ),
                ),
              ),
              Positioned(
                top: -15,
                right: -15,
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
          content: Container(
            width: double.infinity,
            child: Column(mainAxisSize: MainAxisSize.min,
             children: [
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on,color: Colors.white,),
                  Text(
                    data['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Icon(
                weatherIcon,
                size: 50,
                color: Colors.white,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                data['weather'][0]['main'],
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10,),
              Text(
                '${data['main']['temp']} C',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        tileColor: const Color.fromRGBO(80, 137, 145, 1),
                        leading: const Icon(Icons.thermostat_rounded,color: Colors.white,),
                        title: Column(
                          children: [
                            Text('${data['main']['feels_like']} C',style: const TextStyle(color: Colors.white,fontSize: 8),),
                            const Text('Feels like',style: TextStyle(color: Colors.white,fontSize: 10),),
                          ],
                        ),
                      ),
                    ),
                    Container(width: 1,color: Colors.grey,),
                    Expanded(
                      child: ListTile(
                        tileColor: const Color.fromRGBO(80, 137, 145, 1),
                        leading: const Icon(Icons.water_drop_rounded,color: Colors.white,),
                        title: Column(
                          children: [
                            Text('${data['main']['humidity']} %',style: const TextStyle(color: Colors.white,fontSize: 8),),
                            const Text('Humidity',style: TextStyle(color: Colors.white,fontSize: 10),),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ]),
          ),
        );
      },
    );
  }

  void _showErrorDialouge(String e) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(e),
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: _isLoading ? 
      const Center(child: CircularProgressIndicator())
      :Container(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(children: [
                const Text(
                  "Weather App",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(0, 67, 70, 1),
                  ),
                ),
                const SizedBox(
                  height: 75,
                ),
                Card(
                  elevation: 5,
                  child: TextFormField(
                    controller: _citController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromRGBO(234, 234, 234, 1),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(0)),
                      hintText: "Enter City Name",
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: Color.fromRGBO(80, 137, 145, 1),
                      ),
                      alignLabelWithHint: true,
                      suffixIcon: Container(
                          height: 56,
                          width: 55,
                          decoration: const BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Color.fromRGBO(0, 67, 70, 0.9),
                          ),
                          child: IconButton(
                              onPressed: () {
                                _submit();
                              },
                              icon: const Icon(
                                Icons.search,
                                color: Color.fromRGBO(234, 234, 234, 1),
                                size: 35,
                              ))),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter city name';
                      }
                      final cityRegExp = RegExp(r'^[a-zA-Z\s]+$');
                      if (!cityRegExp.hasMatch(value)) {
                        return 'City name can only contain letters and spaces';
                      }
                      return null;
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    "or",
                    style: TextStyle(
                      fontSize: 20,
                      color: Color.fromRGBO(0, 67, 70, 1),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _getWeatherByLocation();
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 5,
                    fixedSize: const Size(310, 50),
                    backgroundColor: const Color.fromRGBO(65, 134, 143, 1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0)),
                  ),
                  child: const Text(
                    "Use device location",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
