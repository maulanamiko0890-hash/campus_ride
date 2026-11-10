
Future<void> createProfile(
  String displayName, {
  String? collegeId,
  String? phone,
  String? photoUrl,
}) async {
  final supabase = Supabase.instance.client;
  final currentUser = supabase.auth.currentUser;

  if (currentUser == null) {
    throw Exception('Pengguna belum login');
  }

  final now = DateTime.now().toIso8601String();

  final existingProfile = await supabase
      .from('user_profiles')
      .select('role')
      .eq('id', currentUser.id)
      .maybeSingle();

  final existingRole = existingProfile?['role'] as String?;
  final role = existingRole ?? 'passenger';

  await supabase.from('user_profiles').upsert({
    'id': currentUser.id,
    'email': currentUser.email ?? '',
    'role': role,
    'display_name': displayName,
    'phone_number': phone,
    'avatar_url': photoUrl,
    'college_id': collegeId,
    'created_at': now,
    'updated_at': now,
  });

  await _loadUserProfile();
}
