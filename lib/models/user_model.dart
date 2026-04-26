class UserModel {
  final String id;
  final String email;
  final String mobile;
  final String fullName;
  final String role;
  final String tenantId;
  final String status;

  const UserModel({
    required this.id,
    required this.email,
    required this.mobile,
    required this.fullName,
    required this.role,
    required this.tenantId,
    this.status = 'active',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      mobile: json['mobile'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      role: json['role'] as String? ?? '',
      tenantId: json['tenantId'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'mobile': mobile,
      'fullName': fullName,
      'role': role,
      'tenantId': tenantId,
      'status': status,
    };
  }

  /// Normalized role for routing (lowercase, strips ROLE_ prefix)
  String get normalizedRole {
    final r = role.toLowerCase().replaceAll('role_', '');
    if (r == 'member' || r == 'client') return 'client';
    if (r == 'owner') return 'owner';
    if (r == 'trainer') return 'trainer';
    if (r == 'super_admin') return 'admin';
    return r;
  }

  /// Whether the user is active
  bool get isActive => status == 'active';

  /// Alias for phone (used in some places)
  String get phone => mobile;
}
