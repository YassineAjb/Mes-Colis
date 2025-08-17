// lib/views/pickup_orders_view.dart
import 'package:flutter/material.dart';
import 'package:mescolis/viewmodels/dashboard_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:mescolis/viewmodels/order_viewmodel.dart';

class PickupOrdersView extends StatefulWidget {
  const PickupOrdersView({Key? key}) : super(key: key);

  @override
  State<PickupOrdersView> createState() => _PickupOrdersViewState();
}

class _PickupOrdersViewState extends State<PickupOrdersView> {
  final TextEditingController _barcodeController = TextEditingController();

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ramassage commandes'),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
      ),
      body: Consumer<OrderViewModel>(
        builder: (context, orderViewModel, child) {
          return Column(
            children: [
              // Scanner Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _barcodeController,
                      decoration: const InputDecoration(
                        labelText: 'Code-barres',
                        hintText: 'Scannez ou saisissez le code-barres',
                        prefixIcon: Icon(Icons.qr_code),
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (value) => _scanBarcode(context, orderViewModel),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _openBarcodeScanner(context),
                            icon: const Icon(Icons.qr_code_scanner),
                            label: const Text('Scanner'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple[600],
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _scanBarcode(context, orderViewModel),
                            icon: const Icon(Icons.add),
                            label: const Text('Ajouter'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Messages
              if (orderViewModel.errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    border: Border.all(color: Colors.red[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red[600]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          orderViewModel.errorMessage!,
                          style: TextStyle(color: Colors.red[600]),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => orderViewModel.clearMessages(),
                      ),
                    ],
                  ),
                ),

              if (orderViewModel.successMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    border: Border.all(color: Colors.green[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[600]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          orderViewModel.successMessage!,
                          style: TextStyle(color: Colors.green[600]),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => orderViewModel.clearMessages(),
                      ),
                    ],
                  ),
                ),

              // Scanned Orders List
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Commandes scannées (${orderViewModel.scannedOrders.length})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (orderViewModel.scannedOrders.isNotEmpty)
                            TextButton(
                              onPressed: () => orderViewModel.clearScannedOrders(),
                              child: const Text('Effacer tout'),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: orderViewModel.scannedOrders.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.qr_code,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Aucune commande scannée',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: orderViewModel.scannedOrders.length,
                              itemBuilder: (context, index) {
                                final order = orderViewModel.scannedOrders[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.purple[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.inventory,
                                        color: Colors.purple[700],
                                      ),
                                    ),
                                    title: Text(
                                      'Commande #${order.orderId}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (order.barcode != null)
                                          Text('Code-barres: ${order.barcode}'),
                                        if (order.recipientName != null)
                                          Text('Client: ${order.recipientName}'),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => orderViewModel.removeScannedOrder(order.orderId),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),

              // Submit Button
              if (orderViewModel.scannedOrders.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: orderViewModel.isLoading
                        ? null
                        : () => _submitScannedOrders(context, orderViewModel),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: orderViewModel.isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Soumission en cours...'),
                            ],
                          )
                        : Text('Soumettre ${orderViewModel.scannedOrders.length} commande(s)'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _openBarcodeScanner(BuildContext context) {
    // TODO: Implement barcode scanner using a package like flutter_barcode_scanner
    // For now, we'll show a dialog to simulate scanning
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Scanner de code-barres'),
          content: const Text('Fonctionnalité de scan à implémenter avec flutter_barcode_scanner'),
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

  void _scanBarcode(BuildContext context, OrderViewModel orderViewModel) {
    final barcode = _barcodeController.text.trim();
    if (barcode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir un code-barres'),
        ),
      );
      return;
    }

    orderViewModel.scanOrder(barcode).then((success) {
      if (success) {
        _barcodeController.clear();
      }
    });
  }

  void _submitScannedOrders(BuildContext context, OrderViewModel orderViewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: Text(
            'Êtes-vous sûr de vouloir soumettre ${orderViewModel.scannedOrders.length} commande(s) ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                orderViewModel.submitScannedOrders().then((success) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Commandes soumises avec succès'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                });
              },
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }
}
