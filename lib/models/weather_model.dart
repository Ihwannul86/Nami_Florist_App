import 'dart:convert';

WeatherApi weatherApiFromJson(String str) =>
    WeatherApi.fromJson(json.decode(str));

// ROOT ============================
class WeatherApi {
  String cod;
  int message;
  int cnt;
  List<ListElement> list;
  City city;

  WeatherApi({
    required this.cod,
    required this.message,
    required this.cnt,
    required this.list,
    required this.city,
  });

  factory WeatherApi.fromJson(Map<String, dynamic> json) => WeatherApi(
        cod: json["cod"] ?? "",
        message: json["message"] ?? 0,
        cnt: json["cnt"] ?? 0,
        list: (json["list"] as List<dynamic>? ?? [])
            .map((x) => ListElement.fromJson(x))
            .toList(),
        city: City.fromJson(json["city"] ?? {}),
      );
}

// CITY ============================
class City {
  int id;
  String name;
  Coord coord;
  String country;
  int population;
  int timezone;
  int sunrise;
  int sunset;

  City({
    required this.id,
    required this.name,
    required this.coord,
    required this.country,
    required this.population,
    required this.timezone,
    required this.sunrise,
    required this.sunset,
  });

  factory City.fromJson(Map<String, dynamic> json) => City(
        id: json["id"] ?? 0,
        name: json["name"] ?? "",
        coord: Coord.fromJson(json["coord"] ?? {}),
        country: json["country"] ?? "",
        population: json["population"] ?? 0,
        timezone: json["timezone"] ?? 0,
        sunrise: json["sunrise"] ?? 0,
        sunset: json["sunset"] ?? 0,
      );
}

// COORD ============================
class Coord {
  double lat;
  double lon;

  Coord({
    required this.lat,
    required this.lon,
  });

  factory Coord.fromJson(Map<String, dynamic> json) => Coord(
        lat: (json["lat"] ?? 0).toDouble(),
        lon: (json["lon"] ?? 0).toDouble(),
      );
}

// LIST ELEMENT (5 DAYS FORECAST) ============================
class ListElement {
  int dt;
  MainClass main;
  List<Weather> weather;
  Clouds clouds;
  Wind wind;
  int visibility;
  double pop;
  Rain? rain;
  Sys sys;
  DateTime dtTxt;

  ListElement({
    required this.dt,
    required this.main,
    required this.weather,
    required this.clouds,
    required this.wind,
    required this.visibility,
    required this.pop,
    this.rain,
    required this.sys,
    required this.dtTxt,
  });

  factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
        dt: json["dt"] ?? 0,
        main: MainClass.fromJson(json["main"] ?? {}),
        weather: (json["weather"] as List<dynamic>? ?? [])
            .map((x) => Weather.fromJson(x))
            .toList(),
        clouds: Clouds.fromJson(json["clouds"] ?? {}),
        wind: Wind.fromJson(json["wind"] ?? {}),
        visibility: json["visibility"] ?? 0,
        pop: (json["pop"] ?? 0).toDouble(),
        rain: json["rain"] != null ? Rain.fromJson(json["rain"]) : null,
        sys: Sys.fromJson(json["sys"] ?? {}),
        dtTxt: DateTime.tryParse(json["dt_txt"] ?? "") ?? DateTime.now(),
      );
}

// CLOUDS ============================
class Clouds {
  int all;

  Clouds({
    required this.all,
  });

  factory Clouds.fromJson(Map<String, dynamic> json) => Clouds(
        all: json["all"] ?? 0,
      );
}

// MAIN ============================
class MainClass {
  double temp;
  double feelsLike;
  double tempMin;
  double tempMax;
  int pressure;
  int humidity;

  MainClass({
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
    required this.humidity,
  });

  factory MainClass.fromJson(Map<String, dynamic> json) => MainClass(
        temp: (json["temp"] ?? 0).toDouble(),
        feelsLike: (json["feels_like"] ?? 0).toDouble(),
        tempMin: (json["temp_min"] ?? 0).toDouble(),
        tempMax: (json["temp_max"] ?? 0).toDouble(),
        pressure: json["pressure"] ?? 0,
        humidity: json["humidity"] ?? 0,
      );
}

// RAIN ============================
class Rain {
  double d3h;

  Rain({
    required this.d3h,
  });

  factory Rain.fromJson(Map<String, dynamic> json) => Rain(
        d3h: (json["3h"] ?? 0).toDouble(),
      );
}

// WIND ============================
class Wind {
  double speed;
  int deg;

  Wind({
    required this.speed,
    required this.deg,
  });

  factory Wind.fromJson(Map<String, dynamic> json) => Wind(
        speed: (json["speed"] ?? 0).toDouble(),
        deg: json["deg"] ?? 0,
      );
}

// SYS ============================
class Sys {
  String pod;

  Sys({
    required this.pod,
  });

  factory Sys.fromJson(Map<String, dynamic> json) => Sys(
        pod: json["pod"] ?? "",
      );
}

// WEATHER ITEM ============================
class Weather {
  int id;
  String main;
  String description;
  String icon;

  Weather({
    required this.id,
    required this.main,
    required this.description,
    required this.icon,
  });

  factory Weather.fromJson(Map<String, dynamic> json) => Weather(
        id: json["id"] ?? 0,
        main: json["main"] ?? "",
        description: json["description"] ?? "",
        icon: json["icon"] ?? "",
      );
}
