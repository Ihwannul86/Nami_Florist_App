// lib/views/home/landing_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

// Controllers
import '../../controllers/plant_controller.dart';
import '../../controllers/weather_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/payment_controller.dart';
import '../../controllers/landing_controller.dart';

// Models & Services
import '../../models/product.dart';
import '../../services/storage/shared_prefs_service.dart';
import '../../services/storage/supabase_service.dart';
import '../../models/user_model.dart';

// Views & Widgets
import '../product/product_card.dart';
import '../../widgets/cart_fab.dart';
import '../../widgets/card_plant_api.dart';
import '../auth/login_page.dart';
import '../../app/routes/app_routes.dart';

class LandingPage extends StatefulWidget {
  LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final cart = Get.find<CartController>();
  final payment = Get.find<PaymentController>();
  final plant = Get.find<PlantController>();
  final weather = Get.find<WeatherController>();
  final landing = Get.find<LandingController>();

  UserModel? _currentUser;

  final products = [
    Product(name: 'Bouquet Coklat', price: 50000, image: 'assets/images/product1.png'),
    Product(name: 'Bouquet Mawar Putih', price: 65000, image: 'assets/images/product2.png'),
    Product(name: 'Bouquet Mawar Merah', price: 48000, image: 'assets/images/product3.png'),
    Product(name: 'Bouquet Mix Bloom', price: 70000, image: 'assets/images/product4.png'),
    Product(name: 'Bouquet Mix Bloom', price: 55000, image: 'assets/images/product5.png'),
    Product(name: 'Bouquet Mawar Pink', price: 60000, image: 'assets/images/product6.png'),
    Product(name: 'Bouquet Mix Bloom', price: 75000, image: 'assets/images/product7.png'),
    Product(name: 'Bouquet Mix Bloom', price: 80000, image: 'assets/images/product8.png'),
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final email = await SharedPrefsService.getUserEmail();
    if (email == null) return;

    final user = await SupabaseService.getUserByEmail(email);
    if (!mounted) return;
    setState(() {
      _currentUser = user;
    });
  }

  Future<void> _logout() async {
    await SharedPrefsService.clearUserData();
    await SupabaseService.signOut();

    Get.snackbar(
      'Logout Berhasil',
      'Anda telah keluar dari akun',
      backgroundColor: Colors.green[100],
      colorText: Colors.green[900],
      icon: const Icon(Icons.check_circle, color: Colors.green),
    );

    Get.offAll(() => const LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nami Florist'),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () async {
              final isLoggedIn = await SharedPrefsService.isLoggedIn();

              if (isLoggedIn) {
                final email = await SharedPrefsService.getUserEmail() ?? '';
                _showProfileMenu(context, email);
              } else {
                Get.to(() => const LoginPage());
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: FutureBuilder<bool>(
                future: SharedPrefsService.isLoggedIn(),
                builder: (context, snapshot) {
                  final isLoggedIn = snapshot.data ?? false;

                  if (isLoggedIn) {
                    return FutureBuilder<String?>(
                      future: SharedPrefsService.getUserEmail(),
                      builder: (context, emailSnapshot) {
                        final email = emailSnapshot.data ?? '';
                        final initial =
                            email.isNotEmpty ? email[0].toUpperCase() : '?';

                        return CircleAvatar(
                          backgroundColor: Colors.purple[400],
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      child: Icon(
                        Icons.person_outline,
                        color: Colors.grey[700],
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          plant.loadPlantsBasedOnWeather();
          weather.getWeather();
          landing.getCurrentLocation();
          _loadCurrentUser();
        },
        child: CustomScrollView(
          slivers: [
            // === BAGIAN PRODUK === //
            SliverToBoxAdapter(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount;

                  if (constraints.maxWidth < 600) {
                    crossAxisCount = 2;
                  } else if (constraints.maxWidth < 900) {
                    crossAxisCount = 3;
                  } else {
                    crossAxisCount = 4;
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.68,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: products[index]);
                    },
                  );
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // === BAGIAN REKOMENDASI TANAMAN === //
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    const Text(
                      "Rekomendasi Tanaman",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Location info
                    Obx(() {
                      if (landing.isLoading.value) {
                        return const CircularProgressIndicator();
                      }

                      if (landing.locationError.value.isNotEmpty) {
                        return Text(
                          "Error lokasi: ${landing.locationError.value}",
                          style: const TextStyle(color: Colors.red),
                        );
                      }

                      if (landing.position.value != null) {
                        final pos = landing.position.value!;
                        return Text(
                          "Lokasi saat ini: Lat ${pos.latitude.toStringAsFixed(5)}, Lon ${pos.longitude.toStringAsFixed(5)}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        );
                      }

                      return const SizedBox();
                    }),

                    // Suhu
                    Obx(() {
                      final temp = weather.temperature.value;
                      return Text(
                        "Berdasarkan suhu saat ini: ${temp.toStringAsFixed(1)}°C",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.orange,
                        ),
                      );
                    }),

                    const SizedBox(height: 12),

                    // Peta
                    const SizedBox(height: 20),
                    Obx(() {
                      if (landing.isLoading.value) {
                        return const CircularProgressIndicator();
                      }

                      if (landing.position.value == null) {
                        return const Text("Lokasi belum tersedia");
                      }

                      final pos = landing.position.value!;
                      return SizedBox(
                        height: 300,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter:
                                LatLng(pos.latitude, pos.longitude),
                            initialZoom: 15.0,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.all,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                              subdomains: const ['a', 'b', 'c'],
                              userAgentPackageName: 'com.example.tugas_modul3',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  width: 80,
                                  height: 80,
                                  point: LatLng(pos.latitude, pos.longitude),
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 20),

                    // === LIST TANAMAN === //
                    Obx(() {
                      if (plant.isLoading.value) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 12),
                                Text("Memuat rekomendasi tanaman..."),
                              ],
                            ),
                          ),
                        );
                      }

                      if (plant.plants.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.cloud_off,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "Tidak ada data tanaman",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Pastikan koneksi internet aktif",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    plant.refresh();
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text("Coba Lagi"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple[400],
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: plant.plants.length,
                        itemBuilder: (context, index) {
                          final plantData = plant.plants[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: CardPlantApi(
                              name: plantData["common_name"] ?? "Unknown Plant",
                              image: plantData["default_image"]?["thumbnail"],
                              plantData: plantData,
                            ),
                          );
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: const CartFAB(),
    );
  }

  void _showProfileMenu(BuildContext context, String email) async {
    final userData = await SupabaseService.getUserByEmail(email);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.purple[400],
                    child: Text(
                      email.isNotEmpty ? email[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData?.nama ?? 'User',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.verified_user,
                              size: 16,
                              color: Colors.purple[400],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              userData?.role ?? 'customer',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.purple[400],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Profil lengkap
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Profil Saya'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Get.back();
                  _showProfileDetail(userData);
                },
              ),

              // Riwayat pesanan
              ListTile(
                leading: const Icon(Icons.shopping_bag_outlined),
                title: const Text('Riwayat Pesanan'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Get.back();
                  // TODO: arahkan ke halaman history orders
                  Get.snackbar(
                    'Info',
                    'Fitur riwayat pesanan akan segera hadir',
                    backgroundColor: Colors.blue[100],
                  );
                },
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Logout
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.back();
                    _logout();
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Keluar',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showProfileDetail(UserModel? user) {
    if (user == null) {
      Get.snackbar(
        'Error',
        'Data profil tidak ditemukan.',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }

    showDialog(
      context: Get.context!,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Profil Saya'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _profileRow('Nama', user.nama),
              _profileRow('Email', user.email),
              _profileRow('No. HP', user.noHp ?? '-'),
              _profileRow('Alamat', user.alamatLengkap ?? '-'),
              _profileRow('Role', user.role),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Widget _profileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
