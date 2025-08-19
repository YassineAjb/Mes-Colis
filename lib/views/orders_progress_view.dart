// lib/views/orders_in_progress_view.dart
import 'package:flutter/material.dart';
import 'package:mescolis/viewmodels/runsheet_view_model.dart';
import 'package:provider/provider.dart';
import 'package:mescolis/viewmodels/order_viewmodel.dart';

class OrdersInProgressView extends StatefulWidget {
  const OrdersInProgressView({Key? key}) : super(key: key);

  @override
  State<OrdersInProgressView> createState() => _OrdersInProgressViewState();
}

class _OrdersInProgressViewState extends State<OrdersInProgressView> {
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
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    orderViewModel.errorMessage!,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
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
                  Icon(
                    Icons.inbox,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aucune commande en cours',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => orderViewModel.fetchProgressOrders(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orderViewModel.orders.length,
              itemBuilder: (context, index) {
                final order = orderViewModel.orders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.local_shipping,
                        color: Colors.orange[700],
                      ),
                    ),
                    title: Text(
                      'Commande #${order.orderId}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (order.recipientName != null)
                          Text('Client: ${order.recipientName}'),
                        if (order.address != null)
                          Text('Adresse: ${order.address}'),
                        if (order.recipientPhone != null)
                          Text('Téléphone: ${order.recipientPhone}'),
                        if (order.status != null)
                          Chip(
                            label: Text(order.status!),
                            backgroundColor: Colors.orange[100],
                          ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showOrderDetails(context, order);
                    },
                  ),
                );
              },
            ),
          );
        },
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
                if (order.recipientName != null) _buildDetailRow('Client', order.recipientName!),
                if (order.recipientPhone != null) _buildDetailRow('Téléphone', order.recipientPhone!),
                if (order.address != null) _buildDetailRow('Adresse', order.address!),
                if (order.status != null) _buildDetailRow('Statut', order.status!),
                if (order.amount != null) _buildDetailRow('Montant', '${order.amount} TND'),
                if (order.scheduledDate != null) _buildDetailRow('Date programmée', order.scheduledDate!),
                if (order.notes != null) _buildDetailRow('Notes', order.notes!),
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
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
