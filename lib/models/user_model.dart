class UserModel {
  final String id;
  final String email;
  final String phone;
  final String password;
  final String fullName;
  final String role;
  final String tenantId;
  final String status;
  final String otp;

  const UserModel({
    required this.id,
    required this.email,
    required this.phone,
    required this.password,
    required this.fullName,
    required this.role,
    required this.tenantId,
    required this.status,
    required this.otp,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      password: json['password'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      role: json['role'] as String? ?? '',
      tenantId: json['tenantId'] as String? ?? '',
      status: json['status'] as String? ?? '',
      otp: json['otp'] as String? ?? '123456',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'password': password,
      'fullName': fullName,
      'role': role,
      'tenantId': tenantId,
      'status': status,
      'otp': otp,
    };
  }

  /// Normalized role for routing (lowercase)
  String get normalizedRole => role.toLowerCase();

  /// Whether the user is active
  bool get isActive => status == 'active';
}
