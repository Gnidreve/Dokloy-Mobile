class User {
  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.image,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    return User(
      id: user['id'] as String? ?? '',
      email: user['email'] as String? ?? '',
      firstName: user['firstName'] as String? ?? '',
      lastName: user['lastName'] as String? ?? '',
      image: user['image'] as String?,
    );
  }

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? image;

  String get displayName => '$firstName $lastName'.trim();

  String get initials {
    final parts = displayName.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    if (parts.isNotEmpty) return parts.first[0].toUpperCase();
    return '?';
  }
}
