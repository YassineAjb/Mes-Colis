import 'package:flutter/material.dart';
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
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
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

          // 📊 Stats
          final total = orderViewModel.orders.length;
          final delivered = orderViewModel.orders.where((o) => o.status == "Livré").length; //Fix103  "Livré" to change
          final pending = orderViewModel.orders.where((o) => o.status == "in-progress").length;  
          final returned = orderViewModel.orders.where((o) => o.status == "Retourné").length; //Fix103  "Retourné" to change

          // 🔍 Apply filter
          final filteredOrders = selectedFilter == null || selectedFilter == "all"
              ? orderViewModel.orders
              : orderViewModel.orders.where((o) => o.status == selectedFilter).toList();

          return RefreshIndicator(
            onRefresh: () => orderViewModel.fetchProgressOrders(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 🔢 Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard("Total", total, Colors.blue),
                    _buildStatCard("Livrés", delivered, Colors.green),
                    _buildStatCard("En attente", pending, Colors.orange),
                    _buildStatCard("Retournés", returned, Colors.red),
                  ],
                ),
                const SizedBox(height: 16),

                // 🎯 Filter buttons
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip("all", "Tous"),
                      _buildFilterChip("Livré!!", "Livrés"), //Fix103  "Livré!!" to change
                      _buildFilterChip("in-progress", "En attente"),
                      _buildFilterChip("Retourné!!", "Retournés"), //Fix103  "Retournés!!" to change
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
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.local_shipping, color: Colors.orange[700]),
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
                            if (order.status != null)
                              Chip(
                                label: Text(order.status!),
                                backgroundColor: Colors.orange[100],
                              ),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
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

  // 📊 Small stat cards
  Widget _buildStatCard(String label, int value, Color color) {
    return Card(
      color: color.withOpacity(0.1),
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
            selectedFilter = value;
          });
        },
        selectedColor: Colors.orange[200],
      ),
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
                if (order.status != null) _buildDetailRow('Statut', order.status!),
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
