import '../../../../core/database/constants/client_constants.dart';
import '../../domain/entities/client.dart';

class ClientModel extends Client {
  const ClientModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.phone,
    super.email,
    super.gender,
    super.birthDate,
    required super.createdAt,
  });

  factory ClientModel.fromEntity(Client client) {
    return ClientModel(
      id: client.id,
      firstName: client.firstName,
      lastName: client.lastName,
      phone: client.phone,
      email: client.email,
      gender: client.gender,
      birthDate: client.birthDate,
      createdAt: client.createdAt,
    );
  }

  factory ClientModel.fromMap(Map<String, dynamic> map) {
    return ClientModel(
      id: map[ClientConstants.id] as String,
      firstName: map[ClientConstants.firstName] as String,
      lastName: map[ClientConstants.lastName] as String,
      phone: map[ClientConstants.phone] as String,
      email: map[ClientConstants.email] as String?,
      gender: map[ClientConstants.gender] as String?,
      birthDate: map[ClientConstants.birthDate] != null
          ? DateTime.parse(
              map[ClientConstants.birthDate] as String,
            )
          : null,
      createdAt: DateTime.parse(
        map[ClientConstants.createdAt] as String,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      ClientConstants.id: id,
      ClientConstants.firstName: firstName,
      ClientConstants.lastName: lastName,
      ClientConstants.phone: phone,
      ClientConstants.email: email,
      ClientConstants.gender: gender,
      ClientConstants.birthDate: birthDate?.toIso8601String(),
      ClientConstants.createdAt: createdAt.toIso8601String(),
    };
  }

  Client toEntity() {
    return Client(
      id: id,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
      gender: gender,
      birthDate: birthDate,
      createdAt: createdAt,
    );
  }
}