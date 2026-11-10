import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? _currentUser;
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;
  bool _needsProfileCompletion = false;

  User? get currentUser => _currentUser;
  UserProfile? get userProfile => _userProfile;
  String? get userRole => _userProfile?.role;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get needsProfileCompletion => _needsProfileCompletion;

  AuthService() {
    _initialize();
  }

  void _initialize() {
    _currentUser = _supabase.auth.currentUser;

    if (_currentUser != null) {
      _loadUserProfile();
    }

    _supabase.auth.onAuthStateChange.listen((data) {
      _currentUser = data.session?.user;

      if (_currentUser != null) {
        _loadUserProfile();
      } else {
        _userProfile = null;
        _needsProfileCompletion = false;
      }

      notifyListeners();
    });
  }

  // Memuat profil pengguna.
  // Jika belum ada, profil otomatis dibuat tanpa kampus.
  Future<void> _loadUserProfile() async {
    final user = _currentUser;
    if (user == null) return;

    try {
      final response = await _supabase
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        _userProfile = UserProfile.fromJson(response);
        _needsProfileCompletion = false;
        notifyListeners();
        return;
      }

      // Profil belum ada. Buat otomatis setelah email terverifikasi.
      if (user.emailConfirmedAt != null) {
        final metadata = user.userMetadata ?? {};

        String displayName = '';

        if (metadata['pending_profile'] != null) {
          final pending = metadata['pending_profile'];
          if (pending is Map) {
            displayName =
                pending['display_name']?.toString() ?? '';
          }
        }

        if (displayName.isEmpty) {
          displayName =
              metadata['display_name']?.toString() ?? '';
        }

        // Cadangan jika nama tidak ditemukan.
        if (displayName.isEmpty) {
          displayName = user.email?.split('@').first ?? 'Pengguna';
        }

        await createProfile(displayName, null);
      } else {
        _needsProfileCompletion = false;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user profile: $e');
      }

      _needsProfileCompletion = true;
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    _successMessage = null;
    notifyListeners();
  }

  void _setSuccessMessage(String message) {
    _successMessage = message;
    _error = null;
    notifyListeners();
  }

  // PENDAFTARAN TANPA PILIHAN KAMPUS.
  Future<void> registerWithEmail(
    String email,
    String password,
    String name,
  ) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'display_name': name,
          'role': 'passenger',
        },
      );

      if (response.user != null) {
        _currentUser = response.user;

        // Jika konfirmasi email tidak diwajibkan,
        // langsung buat profil tanpa college_id.
        if (response.session != null) {
          await createProfile(name, null);
          _setSuccessMessage('Account created successfully');
        } else {
          // Nama tersimpan di metadata untuk dibuat
          // menjadi profil setelah email diverifikasi.
          _setSuccessMessage(
            'Please confirm your email and login',
          );
        }
      }
    } on AuthException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Registration failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Tetap dipertahankan untuk kompatibilitas kode lama.
  // Parameter collegeId sekarang opsional.
  Future<void> registerWithEmailAndCollege(
    String email,
    String password,
    String name,
    String collegeId,
  ) async {
    await registerWithEmail(email, password, name);
  }

  // Membuat profil tanpa membutuhkan kampus.
  Future<void> createProfile(
    String displayName, [
    String? collegeId,
  ], {
    String? phone,
    String? photoUrl,
  }) async {
    final user = _currentUser;
    if (user == null) {
      throw Exception('User belum login');
    }

    try {
      final now = DateTime.now().toIso8601String();

      final profileData = {
        'id': user.id,
        'email': user.email ?? '',
        'role': 'passenger',
        'display_name': displayName,
        'phone_number': phone,
        'avatar_url': photoUrl,
        'college_id': collegeId,
        'created_at': now,
        'updated_at': now,
      };

      final result = await _supabase
          .from('user_profiles')
          .upsert(profileData, onConflict: 'id')
          .select()
          .single();

      _userProfile = UserProfile.fromJson(result);
      _needsProfileCompletion = false;

      notifyListeners();

      // Bersihkan metadata pendaftaran lama jika ada.
      try {
        await _supabase.auth.updateUser(
          UserAttributes(
            data: {'pending_profile': null},
          ),
        );
      } catch (e) {
        if (kDebugMode) {
          print('Metadata cleanup skipped: $e');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Profile creation error: $e');
      }

      throw Exception('Failed to create profile: $e');
    }
  }

  // LOGIN.
  Future<void> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _currentUser = response.user;

        await _loadUserProfile();

        if (_userProfile != null) {
          _setSuccessMessage('Successfully signed in');
        } else {
          _setError(
            'Profil belum berhasil dibuat. Silakan coba lagi.',
          );
        }
      }
    } on AuthException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Login failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Mempertahankan fungsi penyelesaian profil lama.
  Future<void> completeProfile(
    String displayName,
    String collegeId,
  ) async {
    await createProfile(displayName, collegeId);
  }

  // Mempertahankan fungsi pemilihan kampus lama.
  // Tidak wajib digunakan lagi.
  Future<void> selectCollege(String collegeId) async {
    if (_currentUser == null) return;

    try {
      await _supabase
          .from('user_profiles')
          .update({
            'college_id': collegeId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', _currentUser!.id);

      await _loadUserProfile();
    } catch (e) {
      throw Exception('Failed to update college: $e');
    }
  }

  Future<void> updateUserRole(String role) async {
    if (_currentUser == null) return;

    try {
      await _supabase
          .from('user_profiles')
          .update({
            'role': role,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', _currentUser!.id);

      await _loadUserProfile();
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      _setError('Failed to send reset email');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();

      _currentUser = null;
      _userProfile = null;
      _needsProfileCompletion = false;
      _error = null;
      _successMessage = null;

      notifyListeners();
    } catch (e) {
      _setError('Failed to sign out');
    }
  }

  // ==============================
  // DRIVER FUNCTIONS
  // ==============================

  Future<void> submitDriverRequest(
    Map<String, dynamic> requestData,
  ) async {
    if (_currentUser == null) return;

    try {
      final data = {
        ...requestData,
        'user_id': _currentUser!.id,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('driver_requests').insert(data);

      _setSuccessMessage(
        'Driver request submitted successfully',
      );
    } catch (e) {
      _setError('Failed to submit driver request: $e');
    }
  }

  Future<bool> hasPendingDriverRequest() async {
    if (_currentUser == null) return false;

    try {
      final response = await _supabase
          .from('driver_requests')
          .select('id')
          .eq('user_id', _currentUser!.id)
          .eq('status', 'pending')
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getDriverRequestStatus() async {
    if (_currentUser == null) return null;

    try {
      final response = await _supabase
          .from('driver_requests')
          .select('status')
          .eq('user_id', _currentUser!.id)
          .order('created_at', ascending: false)
          .maybeSingle();

      return response?['status'] as String?;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllDriverRequests() async {
    try {
      final response = await _supabase
          .from('driver_requests')
          .select('*, user_profiles!inner(display_name, phone_number)')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<void> handleDriverRequest(
    String requestId,
    String action,
  ) async {
    try {
      await _supabase
          .from('driver_requests')
          .update({
            'status': action,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', requestId);

      if (action == 'approved') {
        final request = await _supabase
            .from('driver_requests')
            .select('user_id')
            .eq('id', requestId)
            .single();

        await _supabase
            .from('user_profiles')
            .update({
              'role': 'driver',
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', request['user_id']);
      }

      _setSuccessMessage(
        'Driver request $action successfully',
      );
    } catch (e) {
      _setError('Failed to handle driver request: $e');
    }
  }

  Future<void> testDatabaseAccess() async {
    try {
      await _supabase
          .from('user_profiles')
          .select('id')
          .limit(1);

      _setSuccessMessage('Database connection successful');
    } catch (e) {
      _setError('Database connection failed: $e');
    }
  }

  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }
}
