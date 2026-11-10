
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final userName =
        authService.userProfile?.displayName ?? 'Pengguna';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // HEADER
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CampusRide',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D4ED8),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Halo, $userName!',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const Text(
                          'Mau pergi atau titip sesuatu hari ini?',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const CircleAvatar(
                    radius: 27,
                    backgroundColor: Color(0xFFDBEAFE),
                    child: Icon(
                      Icons.person,
                      color: Color(0xFF2563EB),
                      size: 30,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // BANNER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2563EB),
                      Color(0xFF1D4ED8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Perjalanan jadi lebih mudah!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Gunakan layanan antar jemput dan '
                      'jasa titip bersama pengguna CampusRide.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 12),
                    Icon(
                      Icons.directions_car,
                      color: Colors.white,
                      size: 35,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Pilih Layanan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),

              const SizedBox(height: 14),

              // ANTAR JEMPUT
              _serviceCard(
                context: context,
                title: 'Antar Jemput',
                description:
                    'Cari tumpangan atau tawarkan perjalanan '
                    'kepada mahasiswa lain.',
                icon: Icons.directions_car,
                color: const Color(0xFF2563EB),
                background: const Color(0xFFEFF6FF),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ServiceOrderScreen(
                        serviceType: 'Antar Jemput',
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 14),

              // JASTIP
              _serviceCard(
                context: context,
                title: 'Jastip',
                description:
                    'Titip pembelian makanan, barang, '
                    'atau kebutuhan lainnya.',
                icon: Icons.shopping_bag,
                color: const Color(0xFF059669),
                background: const Color(0xFFECFDF5),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ServiceOrderScreen(
                        serviceType: 'Jastip',
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 25),

              const Text(
                'Cara Menggunakan CampusRide',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),

              const SizedBox(height: 14),

              _stepItem(
                Icons.touch_app,
                'Pilih layanan',
                'Pilih Antar Jemput atau Jastip.',
              ),
              _stepItem(
                Icons.edit_note,
                'Isi detail pesanan',
                'Masukkan informasi kebutuhanmu.',
              ),
              _stepItem(
                Icons.handshake,
                'Hubungi penyedia layanan',
                'Lanjutkan transaksi dengan pengguna lain.',
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _serviceCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required Color background,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFDBEAFE),
            child: Icon(icon, color: const Color(0xFF2563EB)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// HALAMAN FORM PEMESANAN
// ========================================

class ServiceOrderScreen extends StatefulWidget {
  final String serviceType;

  const ServiceOrderScreen({
    super.key,
    required this.serviceType,
  });

  @override
  State<ServiceOrderScreen> createState() =>
      _ServiceOrderScreenState();
}

class _ServiceOrderScreenState extends State<ServiceOrderScreen> {
  final _formKey = GlobalKey<FormState>();

  final _pickupController = TextEditingController();
  final _destinationController = TextEditingController();
  final _detailController = TextEditingController();
  final _contactController = TextEditingController();

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    _detailController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  bool get isRide => widget.serviceType == 'Antar Jemput';

  @override
  Widget build(BuildContext context) {
    final primaryColor = isRide
        ? const Color(0xFF2563EB)
        : const Color(0xFF059669);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.serviceType),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isRide
                    ? 'Form Permintaan Antar Jemput'
                    : 'Form Permintaan Jastip',
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isRide
                    ? 'Masukkan lokasi penjemputan dan tujuanmu.'
                    : 'Masukkan barang yang ingin kamu titip beli.',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 25),

              if (isRide) ...[
                _buildField(
                  'Lokasi penjemputan',
                  _pickupController,
                  Icons.location_on,
                ),
                _buildField(
                  'Lokasi tujuan',
                  _destinationController,
                  Icons.flag,
                ),
              ] else ...[
                _buildField(
                  'Lokasi toko pembelian',
                  _pickupController,
                  Icons.store,
                ),
                _buildField(
                  'Alamat pengantaran',
                  _destinationController,
                  Icons.location_on,
                ),
              ],

              _buildField(
                isRide ? 'Waktu perjalanan' : 'Nama barang / pesanan',
                _detailController,
                isRide ? Icons.access_time : Icons.shopping_bag,
              ),

              _buildField(
                'Nomor WhatsApp',
                _contactController,
                Icons.phone,
                isPhone: true,
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Kirim Permintaan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              const Text(
                'Catatan: Ini masih prototipe. Data formulir '
                'belum disimpan ke database.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isPhone = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: TextFormField(
        controller: controller,
        keyboardType:
            isPhone ? TextInputType.phone : TextInputType.text,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label wajib diisi';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Prototipe berhasil'),
        content: const Text(
          'Formulir berhasil divalidasi. '
          'Penyimpanan dan pengiriman pesanan ke database '
          'akan ditambahkan pada tahap berikutnya.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }
}
