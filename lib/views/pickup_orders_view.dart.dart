// lib/views/pickup_orders_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mescolis/viewmodels/runsheet_view_model.dart';
import 'package:mescolis/views/barcodescanner_page.dart';
import 'package:provider/provider.dart';
import 'package:mescolis/viewmodels/order_viewmodel.dart';

class PickupOrdersView extends StatefulWidget {
  const PickupOrdersView({Key? key}) : super(key: key);

  @override
  State<PickupOrdersView> createState() => _PickupOrdersViewState();
}

class _PickupOrdersViewState extends State<PickupOrdersView> {
  final TextEditingController _barcodeController = TextEditingController();
  final FocusNode _barcodeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto focus on barcode input when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _barcodeFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _barcodeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Ramassage commandes', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Consumer<OrderViewModel>(
          builder: (context, orderViewModel, child) {
            return Column(
              children: [
                // Scanner Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.purple[600]!,
                        Colors.purple[400]!,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _barcodeController,
                          focusNode: _barcodeFocusNode,
                          autofocus: true,
                          decoration: InputDecoration(
                            labelText: 'Code-barres',
                            hintText: 'Scannez ou saisissez le code-barres',
                            prefixIcon: Icon(Icons.qr_code, color: Colors.purple[600]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (value) => _processBarcode(context, orderViewModel, value),
                          onChanged: (value) {
                            // Auto-submit if barcode looks complete (common barcode lengths)
                            if (value.length >= 8 && (value.length == 8 || value.length == 12 || value.length == 13)) {
                              Future.delayed(const Duration(milliseconds: 300), () {
                                if (_barcodeController.text == value && value.isNotEmpty) {
                                  _processBarcode(context, orderViewModel, value);
                                }
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _openBarcodeScanner(context, orderViewModel),
                              icon: const Icon(Icons.qr_code_scanner, size: 20),
                              label: const Text('Scanner'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.purple[600],
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _processBarcode(context, orderViewModel, _barcodeController.text),
                              icon: const Icon(Icons.add, size: 20),
                              label: const Text('Ajouter'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[600],
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Conseil: Utilisez un lecteur de codes-barres pour une saisie plus rapide',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Messages
                if (orderViewModel.errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      border: Border.all(color: Colors.red[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[600]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            orderViewModel.errorMessage!,
                            style: TextStyle(color: Colors.red[600], fontWeight: FontWeight.w500),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red[600]),
                          onPressed: () => orderViewModel.clearMessages(),
                        ),
                      ],
                    ),
                  ),

                if (orderViewModel.successMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      border: Border.all(color: Colors.green[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.green[600]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            orderViewModel.successMessage!,
                            style: TextStyle(color: Colors.green[600], fontWeight: FontWeight.w500),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.green[600]),
                          onPressed: () => orderViewModel.clearMessages(),
                        ),
                      ],
                    ),
                  ),

                // Scanned Orders List
                Expanded(
                  child: Column(
                    children: [
                      Container(
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
                              TextButton.icon(
                                onPressed: () => _showClearAllDialog(context, orderViewModel),
                                icon: const Icon(Icons.clear_all, size: 18),
                                label: const Text('Effacer tout'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: orderViewModel.scannedOrders.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.qr_code_2,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      'Aucune commande scannée',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Commencez par scanner ou saisir un code-barres',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                      ),
                                      textAlign: TextAlign.center,
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
                                    margin: const EdgeInsets.only(bottom: 12),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(16),
                                      leading: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [Colors.purple[100]!, Colors.purple[200]!],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.inventory_2,
                                          color: Colors.purple[700],
                                          size: 24,
                                        ),
                                      ),
                                      title: Text(
                                        'Commande #${order.orderId}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          if (order.barcode != null)
                                            _buildDetailChip('Code-barres', order.barcode!),
                                          const SizedBox(height: 4),
                                          if (order.clientName != null)
                                            _buildDetailChip('Client', order.clientName!),
                                          if (order.address != null)
                                            _buildDetailChip('Adresse', order.address!),
                                        ],
                                      ),
                                      trailing: IconButton(
                                        icon: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.red[50],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(Icons.delete_outline, color: Colors.red[600], size: 20),
                                        ),
                                        onPressed: () => _showRemoveOrderDialog(context, orderViewModel, order),
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
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: orderViewModel.isLoading
                          ? null
                          : () => _submitScannedOrders(context, orderViewModel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
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
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.send, size: 20),
                                const SizedBox(width: 8),
                                Text('Soumettre ${orderViewModel.scannedOrders.length} commande(s)'),
                              ],
                            ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailChip(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openBarcodeScanner(BuildContext context, OrderViewModel orderViewModel) async {
    try {
      // Navigate to scanner page
      final result = await Navigator.of(context).push<String>(
        MaterialPageRoute(
          builder: (context) => const BarcodeScannerPage(),
        ),
      );

      // Process result
      if (result != null && result.isNotEmpty && mounted) {
        _barcodeController.text = result;
        await _processBarcode(context, orderViewModel, result);
      }
    } catch (e) {
      if (mounted) {
        print('Erreur du scanner: $e');
        _showErrorDialog(
          context,
          'Erreur du scanner',
          'Le scanner n\'est pas disponible sur cet appareil. Veuillez utiliser la saisie manuelle.',
        );
      }
    }
  }

  Future<void> _processBarcode(BuildContext context, OrderViewModel orderViewModel, String barcode) async {
    final trimmedBarcode = barcode.trim();
    if (trimmedBarcode.isEmpty) {
      // ... existing code
      return;
    }

    print('Processing barcode: $trimmedBarcode'); // DEBUG
    HapticFeedback.lightImpact();

    final success = await orderViewModel.scanOrder(trimmedBarcode);
    print('Scan result: $success'); // DEBUG
    print('Scanned orders count: ${orderViewModel.scannedOrders.length}'); // DEBUG
    
    if (success && mounted) {
      _barcodeController.clear();
      _barcodeFocusNode.requestFocus();
    }
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red[600]),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showClearAllDialog(BuildContext context, OrderViewModel orderViewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange),
              SizedBox(width: 8),
              Text('Confirmation'),
            ],
          ),
          content: Text(
            'Êtes-vous sûr de vouloir effacer toutes les ${orderViewModel.scannedOrders.length} commandes scannées ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                orderViewModel.clearScannedOrders();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Toutes les commandes ont été effacées'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Effacer tout'),
            ),
          ],
        );
      },
    );
  }

  void _showRemoveOrderDialog(BuildContext context, OrderViewModel orderViewModel, dynamic order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Supprimer la commande'),
          content: Text('Voulez-vous supprimer la commande #${order.orderId} de la liste ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                orderViewModel.removeScannedOrder(order.orderId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Commande #${order.orderId} supprimée'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  void _submitScannedOrders(BuildContext context, OrderViewModel orderViewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Row(
            children: [
              Icon(Icons.send, color: Colors.blue),
              SizedBox(width: 8),
              Text('Confirmation'),
            ],
          ),
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
                  if (success && mounted) {
                    HapticFeedback.heavyImpact();
                    // Refocus for next scanning session
                    _barcodeFocusNode.requestFocus();
                  }
                  // Success/error messages are now handled by OrderViewModel
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[600]),
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }
}

