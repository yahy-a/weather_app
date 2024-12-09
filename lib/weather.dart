import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = '9bee82a9a56c15ed9977ba1ab5845a1c';

  Future<Map<String,dynamic>> fetchData(String city) async {
    final String url = 'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if(response.statusCode == 200){
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<Map<String,dynamic>> fetchDataByLocation(double latitude,double longitude) async{
    final String url = 'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if(response.statusCode == 200){
      return jsonDecode(response.body);
    }else{
      throw Exception('failed to load data');
    }
  }
  
}
