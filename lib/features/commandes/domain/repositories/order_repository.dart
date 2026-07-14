import '../entities/order.dart';

/// Contrat officiel du repository des commandes.
///
/// La couche Domain ne connaît pas SQLite.
/// Elle ne dépend que de cette interface.
abstract class OrderRepository {
  /// Retourne toutes les commandes.
  Future<List<Order>> getAllOrders();

  /// Recherche une commande par son identifiant.
  Future<Order?> getOrderById(String id);

  /// Crée une nouvelle commande.
  Future<void> createOrder(Order order);

  /// Met à jour une commande existante.
  Future<void> updateOrder(Order order);

  /// Supprime une commande.
  Future<void> deleteOrder(String id);

  /// Recherche des commandes.
  Future<List<Order>> searchOrders(String query);
}