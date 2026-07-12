class Client {
  const Client({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.email,
    this.gender,
    this.birthDate,
    required this.createdAt,
  });

  /// Identifiant unique
  final String id;

  /// Prénom
  final String firstName;

  /// Nom
  final String lastName;

  /// Téléphone
  final String phone;

  /// Email
  final String? email;

  /// Sexe
  final String? gender;

  /// Date de naissance
  final DateTime? birthDate;

  /// Date de création
  final DateTime createdAt;

  /// Nom complet
  String get fullName => '$firstName $lastName';

  Client copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? gender,
    DateTime? birthDate,
    DateTime? createdAt,
  }) {
    return Client(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
