class UserEntity {
  final String id;
  final String email;
  final String name;
  final String role; // owner, trainer, member

  UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });
}
