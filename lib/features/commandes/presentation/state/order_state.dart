import '../../domain/entities/order_item.dart';

/// ============================================================================
/// ForeverCare AI
/// OrderState
/// ============================================================================
///
/// État de l'écran de création / modification d'une commande.
///
/// Cet objet est immuable.
///
/// Toute modification passe par copyWith().
///
class OrderState {
  const OrderState({
    this.clientId,
    this.clientName,
    this.clientPhone,
    this.items = const [],
    this.discount = 0,
    this.notes = '',
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.success = false,
  });

  /// Identifiant du client sélectionné.
  final String? clientId;

  /// Nom du client sélectionné.
  final String? clientName;

  /// Téléphone du client sélectionné.
  final String? clientPhone;

  /// Produits de la commande.
  final List<OrderItem> items;

  /// Remise globale.
  final double discount;

  /// Notes.
  final String notes;

  /// Chargement.
  final bool isLoading;

  /// Enregistrement.
  final bool isSaving;

  /// Dernière erreur.
  final String? errorMessage;

  /// Commande enregistrée.
  final bool success;

  //--------------------------------------------------------------------------
  // Calculs
  //--------------------------------------------------------------------------

  double get subtotal => items.fold<double>(
        0,
        (sum, item) => sum + item.total,
      );

  double get total => subtotal - discount;

  bool get hasClient =>
      clientId != null && clientId!.isNotEmpty;

  bool get hasItems => items.isNotEmpty;

  bool get canSave =>
      hasClient &&
      hasItems &&
      !isSaving;

  //--------------------------------------------------------------------------
  // Copy
  //--------------------------------------------------------------------------

  OrderState copyWith({
    String? clientId,
    String? clientName,
    String? clientPhone,
    List<OrderItem>? items,
    double? discount,
    String? notes,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool? success,
    bool clearClient = false,
    bool clearError = false,
  }) {
    return OrderState(
      clientId: clearClient
          ? null
          : (clientId ?? this.clientId),

      clientName: clearClient
          ? null
          : (clientName ?? this.clientName),

      clientPhone: clearClient
          ? null
          : (clientPhone ?? this.clientPhone),

      items: items ?? this.items,

      discount: discount ?? this.discount,

      notes: notes ?? this.notes,

      isLoading: isLoading ?? this.isLoading,

      isSaving: isSaving ?? this.isSaving,

      errorMessage: clearError
          ? null
          : (errorMessage ?? this.errorMessage),

      success: success ?? this.success,
    );
  }

  //--------------------------------------------------------------------------
  // État initial
  //--------------------------------------------------------------------------

  factory OrderState.initial() {
    return const OrderState();
  }
}