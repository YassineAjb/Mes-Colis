import 'package:flutter/material.dart';
import 'package:mescolis/views/order_status_update_widget.dart';
import 'package:provider/provider.dart';
import 'package:mescolis/viewmodels/order_viewmodel.dart';

class OrdersInProgressView extends StatefulWidget {
  const OrdersInProgressView({Key? key}) : super(key: key);

  @override
  State<OrdersInProgressView> createState() => _OrdersInProgressViewState();
}

class _OrdersInProgressViewState extends State<OrdersInProgressView> {
  String? selectedFilter; // "all", "delivered", "pending", "returned"

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderViewModel>().fetchProgressOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commandes en cours'),
        backgroundColor: Color(0xFF3b6c7b), // Teal color
        foregroundColor: Colors.white, // Mint green color
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<OrderViewModel>().fetchProgressOrders(),
          ),
        ],
      ),
      body: Consumer<OrderViewModel>(
        builder: (context, orderViewModel, child) {
          if (orderViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orderViewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(orderViewModel.errorMessage!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => orderViewModel.fetchProgressOrders(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (orderViewModel.orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aucune commande en cours'),
                ],
              ),
            );
          }

          // 📊 Stats - Using qualificationName
          final total = orderViewModel.orders.length;
          final delivered = orderViewModel.orders.where((o) => o.qualificationName == "delivered").length;
          final pending = orderViewModel.orders.where((o) => o.qualificationName == null || o.qualificationName!.isEmpty).length;
          final returned = orderViewModel.orders.where((o) => _isReturnedStatus(o.qualificationName)).length;

          // 🔍 Apply filter based on qualificationName categories
          final filteredOrders = _getFilteredOrders(orderViewModel.orders, selectedFilter);

          return RefreshIndicator(
            onRefresh: () => orderViewModel.fetchProgressOrders(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 🔢 Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard("Total", total, Colors.teal),
                    _buildStatCard("Livrés", delivered, Colors.green),
                    _buildStatCard("En attente", pending, Colors.orange),
                    _buildStatCard("Retournés", returned, Colors.red),
                  ],
                ),
                const SizedBox(height: 16),

                // 🎯 Filter buttons - Based on qualification categories
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip("all", "Tous"),
                      _buildFilterChip("delivered", "Livrés"),
                      _buildFilterChip("pending", "En attente"),
                      _buildFilterChip("returned", "Retournés"),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 📋 Orders list
                ...filteredOrders.map((order) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFF61cdab),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.local_shipping, color: Color(0xFF3b6c7b)),
                         
                        ),
                        title: Text(
                          'Commande #${order.orderId}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (order.clientName != null) Text('Client: ${order.clientName}'),
                            if (order.address != null) Text('Adresse: ${order.address}'),
                            if (order.tel1 != null) Text('Téléphone: ${order.tel1}'),
                            Chip(
                              label: Text(_getQualificationDisplayName(order.qualificationName)),
                              backgroundColor: _getQualificationColor(order.qualificationName),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          icon: const Icon(Icons.more_vert),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'details',
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline),
                                  SizedBox(width: 8),
                                  Text('Voir détails'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'update_status',
                              child: Row(
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                  Text('Changer statut'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'mark_delivered',
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text('Marquer comme livré'),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) async {
                            if (value == 'details') {
                              _showOrderDetails(context, order);
                            } else if (value == 'update_status') {
                              _showUpdateStatusDialog(context, order);
                            } else if (value == 'mark_delivered') {
                              final success = await context.read<OrderViewModel>().markOrderAsDelivered(order.orderEventId);
                              if (success && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(Icons.check_circle, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text('Commande marquée comme livrée'),
                                      ],
                                    ),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                                // Refresh the orders list to show updated status
                                context.read<OrderViewModel>().fetchProgressOrders();
                              } else if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.error, color: Colors.white),
                                        const SizedBox(width: 8),
                                        Text(context.read<OrderViewModel>().errorMessage ?? 'Erreur lors de la mise à jour'),
                                      ],
                                    ),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                        onTap: () => _showOrderDetails(context, order),
                      ),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper function to check if qualificationName indicates returned status
  bool _isReturnedStatus(String? qualificationName) {
    if (qualificationName == null) return false;
    
    final returnedStatuses = [
      'to-be-checked-with-sender',
      '3-attempts-done',
      'unreachable',
      'cancelled-by-sender',
      'rescheduled-dated',
      'rescheduled-tomorrow',
      'no-answer',
      'wrong-address',
      'invalid-number',
      'duplicate-package',
      'wrong-amount',
      'order-not-conformed',
      'client-not-serious',
      'number-in-blacklist',
      'cancled-by-sender-client',
      'closed',
    ];
    
    return returnedStatuses.contains(qualificationName.toLowerCase());
  }

  // Helper function to filter orders based on qualification categories
  List<dynamic> _getFilteredOrders(List<dynamic> orders, String? filter) {
    if (filter == null || filter == "all") {
      return orders;
    }

    switch (filter) {
      case "delivered":
        return orders.where((o) => o.qualificationName == "delivered").toList();
      case "pending":
        return orders.where((o) => o.qualificationName == null || o.qualificationName!.isEmpty).toList();
      case "returned":
        return orders.where((o) => _isReturnedStatus(o.qualificationName)).toList();
      default:
        return orders;
    }
  }

  // 📊 Small stat cards
  Widget _buildStatCard(String label, int value, Color color) {
    return Card(
      color: Colors.teal[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text("$value", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 14, color: color)),
          ],
        ),
      ),
    );
  }

  // 🎯 Filter chip
  Widget _buildFilterChip(String value, String label) {
    final isSelected = selectedFilter == value || (selectedFilter == null && value == "all");
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            selectedFilter = value == "all" ? null : value;
          });
        },
        selectedColor: Colors.teal[200],
      ),
    );
  }

  // Helper function to get display names for qualificationName values
  String _getQualificationDisplayName(String? qualificationName) {
    if (qualificationName == null || qualificationName.isEmpty) {
      return 'En attente';
    }

    switch (qualificationName.toLowerCase()) {
      case 'delivered':
        return 'Livrée';
      case 'closed':
        return 'Fermée';
      case 'to-be-checked-with-sender':
        return 'À vérifier avec expéditeur';
      case '3-attempts-done':
        return '3 tentatives effectuées';
      case 'unreachable':
        return 'Injoignable';
      case 'cancelled-by-sender':
        return 'Annulé par expéditeur';
      case 'rescheduled-dated':
        return 'Reprogrammé (daté)';
      case 'rescheduled-tomorrow':
        return 'Reprogrammé demain';
      case 'no-answer':
        return 'Pas de réponse';
      case 'wrong-address':
        return 'Mauvaise adresse';
      case 'invalid-number':
        return 'Numéro invalide';
      case 'duplicate-package':
        return 'Colis dupliqué';
      case 'wrong-amount':
        return 'Montant incorrect';
      case 'order-not-conformed':
        return 'Commande non conforme';
      case 'client-not-serious':
        return 'Client non sérieux';
      case 'number-in-blacklist':
        return 'Numéro en liste noire';
      case 'cancled-by-sender-client':
        return 'Annulé par expéditeur/client';
      default:
        return qualificationName;
    }
  }

// Helper function to get colors for different qualificationName values
Color _getQualificationColor(String? qualificationName) {
  if (qualificationName == null || qualificationName.isEmpty) {
    return Colors.orange[100]!; // Pending
  }

  // Delivered orders - Green
  if (qualificationName.toLowerCase() == 'delivered') {
    return Colors.green[100]!;
  }
  
  // Returned orders - Red
  if (_isReturnedStatus(qualificationName)) {
    return Colors.red[100]!;
  }
  
  // Any other status - Orange (pending/unknown)
  return Colors.orange[100]!;
}

  void _showUpdateStatusDialog(BuildContext context, order) {
    showDialog(
      context: context,
      builder: (BuildContext context) => OrderStatusUpdateDialog(order: order),
    );
  }

  void _showOrderDetails(BuildContext context, order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Commande #${order.orderId}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (order.barcode != null) _buildDetailRow('Code-barres', order.barcode!),
                if (order.clientName != null) _buildDetailRow('Client', order.clientName!),
                if (order.tel1 != null) _buildDetailRow('Téléphone', order.tel1!),
                if (order.address != null) _buildDetailRow('Adresse', order.address!),
                _buildDetailRow('Statut', _getQualificationDisplayName(order.qualificationName)),
                if (order.price != null) _buildDetailRow('Montant', '${order.price} TND'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}