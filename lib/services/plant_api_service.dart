// lib/services/plant_api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Service untuk mengambil data tanaman dari Perenual API
class PlantApiService {
  final String apiKey = "sk-pIqP675d5961a23537800";

  /// Fetch plant list berdasarkan suhu
  Future<List<dynamic>> fetchPlantsByTemperature(double temperature) async {
    try {
      String query;

      // Logika rekomendasi berdasarkan suhu
      if (temperature > 30) {
        query = "cactus"; // Tanaman tahan panas
      } else if (temperature > 20) {
        query = "rose"; // Tanaman iklim sedang
      } else {
        query = "fern"; // Tanaman iklim dingin
      }

      final url = "https://perenual.com/api/species-list?key=$apiKey&q=$query";

      if (kDebugMode) {
        debugPrint('🌿 Fetching plants for temperature: $temperature°C');
        debugPrint('🔍 Query: $query');
        debugPrint('📡 API URL: $url');
      }

      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('API Timeout');
        },
      );

      if (kDebugMode) {
        debugPrint('📊 Response Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final plants = data["data"] ?? [];

        if (kDebugMode) {
          debugPrint('✅ Received ${plants.length} plants from API');
        }

        // Jika API berhasil tapi data kosong, gunakan dummy data
        if (plants.isEmpty) {
          if (kDebugMode) {
            debugPrint('⚠️ API returned empty data, using fallback dummy data');
          }
          return _getDummyPlants(query, temperature);
        }

        return plants;
      } else {
        if (kDebugMode) {
          debugPrint('❌ Plant API error: ${response.statusCode}');
        }
        
        // Gunakan dummy data jika API gagal
        return _getDummyPlants(query, temperature);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Plant API service error: $e');
      }
      
      // Tentukan query berdasarkan temperature
      String query;
      if (temperature > 30) {
        query = "cactus";
      } else if (temperature > 20) {
        query = "rose";
      } else {
        query = "fern";
      }
      
      return _getDummyPlants(query, temperature);
    }
  }

  /// Dummy data untuk fallback (HANYA 1 kategori per suhu)
  List<dynamic> _getDummyPlants(String type, double temperature) {
    if (kDebugMode) {
      debugPrint('🌿 Using dummy plant data for type: $type (temp: $temperature°C)');
    }

    // === SUHU > 30°C: HANYA KAKTUS === //
    if (type == "cactus") {
      return [
        {
          "id": 1,
          "common_name": "Kaktus Pir Berduri",
          "scientific_name": ["Opuntia ficus-indica"],
          "default_image": {
            "thumbnail": "https://perenual.com/storage/species_image/1_opuntia_ficus_indica/thumbnail/51366611768_74894f4b17_b.jpg",
          },
          "watering": "Minimal - Siram setiap 2-3 minggu",
          "sunlight": ["Full sun (8+ jam/hari)"],
          "description": "Kaktus tahan panas dengan daun berbentuk pipih. Cocok untuk iklim kering dan panas.",
        },
        {
          "id": 2,
          "common_name": "Kaktus Barrel Emas",
          "scientific_name": ["Echinocactus grusonii"],
          "default_image": {
            "thumbnail": "https://perenual.com/storage/species_image/2_echinocactus_grusonii/thumbnail/49782425471_e3fbf49fc1_b.jpg",
          },
          "watering": "Minimal - Siram setiap 3-4 minggu",
          "sunlight": ["Full sun (8+ jam/hari)"],
          "description": "Kaktus berbentuk bulat dengan duri emas. Sangat tahan kekeringan dan panas ekstrem.",
        },
        {
          "id": 3,
          "common_name": "Lidah Buaya",
          "scientific_name": ["Aloe vera"],
          "default_image": {
            "thumbnail": "https://perenual.com/storage/species_image/3_aloe_vera/thumbnail/52619084582_6ebcfe6a74_b.jpg",
          },
          "watering": "Minimal - Siram setiap 2 minggu",
          "sunlight": ["Full sun hingga Part shade"],
          "description": "Tanaman sukulen dengan banyak manfaat kesehatan. Tahan panas dan mudah perawatan.",
        },
        {
          "id": 4,
          "common_name": "Kaktus San Pedro",
          "scientific_name": ["Echinopsis pachanoi"],
          "default_image": null,
          "watering": "Minimal - Siram setiap 3 minggu",
          "sunlight": ["Full sun"],
          "description": "Kaktus kolumnar tinggi yang tahan panas. Tumbuh lambat tapi sangat kuat.",
        },
      ];
    } 
    
    // === SUHU 20-30°C: HANYA MAWAR/BUNGA === //
    else if (type == "rose") {
      return [
        {
          "id": 5,
          "common_name": "Mawar Hybrid Tea",
          "scientific_name": ["Rosa × hybrida"],
          "default_image": null,
          "watering": "Sedang - Siram 2-3x seminggu",
          "sunlight": ["Full sun (6-8 jam/hari)", "Part shade"],
          "description": "Mawar klasik dengan bunga besar dan harum. Cocok untuk iklim tropis sedang.",
        },
        {
          "id": 6,
          "common_name": "Anggrek Bulan",
          "scientific_name": ["Phalaenopsis"],
          "default_image": null,
          "watering": "Sedang - Siram 1-2x seminggu",
          "sunlight": ["Part shade (4-6 jam cahaya tidak langsung)"],
          "description": "Anggrek populer dengan bunga indah berbentuk kupu-kupu. Cocok untuk dalam ruangan.",
        },
        {
          "id": 7,
          "common_name": "Melati",
          "scientific_name": ["Jasminum sambac"],
          "default_image": null,
          "watering": "Sedang - Siram setiap 2 hari",
          "sunlight": ["Full sun hingga Part shade"],
          "description": "Bunga putih harum khas Indonesia. Tumbuh baik di iklim tropis dengan suhu sedang.",
        },
        {
          "id": 8,
          "common_name": "Lavender",
          "scientific_name": ["Lavandula"],
          "default_image": null,
          "watering": "Rendah - Siram 1-2x seminggu",
          "sunlight": ["Full sun"],
          "description": "Tanaman aromatik dengan bunga ungu indah. Cocok untuk iklim hangat dan kering.",
        },
      ];
    } 
    
    // === SUHU < 20°C: HANYA PAKIS/TANAMAN DINGIN === //
    else { // fern
      return [
        {
          "id": 9,
          "common_name": "Pakis Boston",
          "scientific_name": ["Nephrolepis exaltata"],
          "default_image": null,
          "watering": "Sering - Siram setiap hari",
          "sunlight": ["Part shade", "Full shade"],
          "description": "Pakis dengan daun hijau lebat. Menyukai kelembaban tinggi dan suhu sejuk.",
        },
        {
          "id": 10,
          "common_name": "Pakis Sarang Burung",
          "scientific_name": ["Asplenium nidus"],
          "default_image": null,
          "watering": "Sering - Siram 4-5x seminggu",
          "sunlight": ["Part shade (cahaya tidak langsung)"],
          "description": "Pakis dengan daun lebar seperti sarang. Cocok untuk indoor dan iklim sejuk.",
        },
        {
          "id": 11,
          "common_name": "Sirih Gading",
          "scientific_name": ["Epipremnum aureum"],
          "default_image": null,
          "watering": "Sedang - Siram 2x seminggu",
          "sunlight": ["Part shade"],
          "description": "Tanaman merambat dengan daun hijau kekuningan. Mudah tumbuh di suhu dingin.",
        },
        {
          "id": 12,
          "common_name": "Calathea",
          "scientific_name": ["Calathea ornata"],
          "default_image": null,
          "watering": "Sedang - Siram 2-3x seminggu",
          "sunlight": ["Part shade hingga Full shade"],
          "description": "Tanaman hias dengan corak daun unik. Menyukai tempat teduh dan sejuk.",
        },
      ];
    }
  }

  /// Fetch plant details by ID
  Future<Map<String, dynamic>?> fetchPlantDetails(int plantId) async {
    try {
      final url = "https://perenual.com/api/species/details/$plantId?key=$apiKey";

      if (kDebugMode) {
        debugPrint('🌿 Fetching plant details for ID: $plantId');
      }

      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (kDebugMode) {
          debugPrint('✅ Plant details received');
        }

        return data;
      } else {
        throw Exception("Gagal memuat detail tanaman");
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Plant details error: $e');
      }
      return null;
    }
  }
}
