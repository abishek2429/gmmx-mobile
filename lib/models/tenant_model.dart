class TenantModel {
  final String id;
  final String name;
  final String slug;
  final String subdomain;
  final String location;
  final String contactEmail;
  final String status;

  const TenantModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.subdomain,
    required this.location,
    required this.contactEmail,
    required this.status,
  });

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      subdomain: json['subdomain'] as String? ?? '',
      location: json['location'] as String? ?? '',
      contactEmail: json['contactEmail'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'subdomain': subdomain,
      'location': location,
      'contactEmail': contactEmail,
      'status': status,
    };
  }
}
