// lib/widgets/order_status_update_dialog.dart
import 'package:flutter/material.dart';
import 'package:mescolis/models/orderstatus_model.dart';
import 'package:provider/provider.dart';
import 'package:mescolis/viewmodels/order_viewmodel.dart';
import 'package:mescolis/models/order_model.dart';

class OrderStatusUpdateDialog extends StatefulWidget {
  final Order order;

  const OrderStatusUpdateDialog({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<OrderStatusUpdateDialog> createState() => _OrderStatusUpdateDialogState();
}

class _OrderStatusUpdateDialogState extends State<OrderStatusUpdateDialog> {
  OrderStatus? selectedStatus;
  
  @override
  void initState() {
    super.initState();
    // Load statuses if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderViewModel = context.read<OrderViewModel>();
      if (orderViewModel.orderStatuses.isEmpty) {
        orderViewModel.fetchOrderStatuses();
      }
    });
  }

  // Helper method to get color based on status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'cancelled-by-sender':
      case 'unreachable':
      case '3-attempts-done':
        return Colors.red;
      case 'rescheduled-dated':
      case 'rescheduled-tomorrow':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  // Helper method to get icon based on status
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled-by-sender':
        return Icons.cancel;
      case 'unreachable':
        return Icons.phone_disabled;
      case '3-attempts-done':
        return Icons.repeat;
      case 'rescheduled-dated':
      case 'rescheduled-tomorrow':
        return Icons.schedule;
      default:
        return Icons.radio_button_unchecked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderViewModel>(
      builder: (context, orderViewModel, child) {
        return AlertDialog(
          title: const Text(
            'Mettre à jour le statut',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order info
                Card(
                  color: Colors.grey[50],
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.local_shipping, color: Colors.teal),
                            const SizedBox(width: 8),
                            Text(
                              'Commande #${widget.order.orderId}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        if (widget.order.clientName != null) ...[
                          Row(
                            children: [
                              Icon(Icons.person, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text('Client: ${widget.order.clientName}'),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                        if (widget.order.qualificationName != null) ...[
                          Row(
                            children: [
                              Icon(Icons.flag, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text('Statut actuel: '),
                              Chip(
                                label: Text(
                                  _getQualificationDisplayName(widget.order.qualificationName!),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: _getQualificationColor(widget.order.qualificationName!),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Status selection
                const Text(
                  'Sélectionner le nouveau statut:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                
                if (orderViewModel.isLoadingStatuses)
                  const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('Chargement des statuts...'),
                      ],
                    ),
                  )
                else if (orderViewModel.orderStatuses.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange[600]),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text('Aucun statut disponible. Veuillez réessayer.'),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: orderViewModel.orderStatuses.map((status) {
                          final isSelected = selectedStatus?.orderStatusId == status.orderStatusId;
                          final statusColor = _getStatusColor(status.status);
                          
                          return Container(
                            decoration: BoxDecoration(
                              color: isSelected ? statusColor.withOpacity(0.1) : null,
                              border: isSelected 
                                  ? Border.all(color: statusColor, width: 2)
                                  : const Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
                            ),
                            child: ListTile(
                              leading: Icon(
                                _getStatusIcon(status.status),
                                color: statusColor,
                              ),
                              title: Text(
                                status.displayName,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? statusColor : null,
                                ),
                              ),
                              subtitle: Text(
                                status.status,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              trailing: isSelected 
                                  ? Icon(Icons.check_circle, color: statusColor)
                                  : null,
                              onTap: () {
                                setState(() {
                                  selectedStatus = status;
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                
                if (orderViewModel.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              orderViewModel.errorMessage!,
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Show selected status info
                if (selectedStatus != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Statut sélectionné: ${selectedStatus!.displayName} (ID: ${selectedStatus!.orderStatusId})',
                              style: TextStyle(color: Colors.blue[700]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: orderViewModel.isUpdatingStatus ? null : () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: selectedStatus == null || orderViewModel.isUpdatingStatus
                  ? null
                  : () async {
                      print('Updating order ${widget.order.orderEventId} to status ${selectedStatus!.orderStatusId}');
                      
                      final success = await orderViewModel.updateOrderStatus(
                        orderEventId: widget.order.orderEventId,
                        statusId: selectedStatus!.orderStatusId,
                      );
                      
                      if (success && mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.white),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    orderViewModel.successMessage ?? 'Statut mis à jour avec succès',
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      } else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.error, color: Colors.white),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    orderViewModel.errorMessage ?? 'Erreur lors de la mise à jour',
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedStatus != null ? _getStatusColor(selectedStatus!.status) : null,
              ),
              child: orderViewModel.isUpdatingStatus
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Mettre à jour'),
            ),
          ],
        );
      },
    );
  }

  // Helper methods from the main view
  String _getQualificationDisplayName(String qualificationName) {
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

  Color _getQualificationColor(String qualificationName) {
    if (qualificationName.toLowerCase() == 'delivered') {
      return Colors.green[100]!;
    }
    
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
    
    if (returnedStatuses.contains(qualificationName.toLowerCase())) {
      return Colors.red[100]!;
    }
    
    return Colors.orange[100]!;
  }
}


// // lib/widgets/order_status_update_dialog.dart
// import 'package:flutter/material.dart';
// import 'package:mescolis/models/orderstatus_model.dart';
// import 'package:provider/provider.dart';
// import 'package:mescolis/viewmodels/order_viewmodel.dart';
// import 'package:mescolis/models/order_model.dart';

// class OrderStatusUpdateDialog extends StatefulWidget {
//   final Order order;

//   const OrderStatusUpdateDialog({
//     Key? key,
//     required this.order,
//   }) : super(key: key);

//   @override
//   State<OrderStatusUpdateDialog> createState() => _OrderStatusUpdateDialogState();
// }

// class _OrderStatusUpdateDialogState extends State<OrderStatusUpdateDialog> {
//   OrderStatus? selectedStatus;
  
//   @override
//   void initState() {
//     super.initState();
//     // Load statuses if not already loaded
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final orderViewModel = context.read<OrderViewModel>();
//       if (orderViewModel.orderStatuses.isEmpty) {
//         orderViewModel.fetchOrderStatuses();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<OrderViewModel>(
//       builder: (context, orderViewModel, child) {
//         return AlertDialog(
//           title: Text('Mettre à jour le statut'),
//           content: SizedBox(
//             width: double.maxFinite,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Order info
//                 Card(
//                   color: Colors.grey[100],
//                   child: Padding(
//                     padding: const EdgeInsets.all(12.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Commande #${widget.order.orderId}',
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         if (widget.order.clientName != null)
//                           Text('Client: ${widget.order.clientName}'),
//                         if (widget.order.status != null)
//                           Text('Statut actuel: ${orderViewModel.getStatusDisplayName(widget.order.status!)}'),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
                
//                 // Status selection
//                 const Text(
//                   'Nouveau statut:',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),
                
//                 if (orderViewModel.isLoadingStatuses)
//                   const Center(child: CircularProgressIndicator())
//                 else if (orderViewModel.orderStatuses.isEmpty)
//                   const Text('Aucun statut disponible')
//                 else
//                   Container(
//                     height: 300,
//                     child: SingleChildScrollView(
//                       child: Column(
//                         children: orderViewModel.orderStatuses.map((status) {
//                           return RadioListTile<OrderStatus>(
//                             title: Text(status.displayName),
//                             subtitle: Text(status.status, style: TextStyle(color: Colors.grey[600])),
//                             value: status,
//                             groupValue: selectedStatus,
//                             onChanged: (OrderStatus? value) {
//                               setState(() {
//                                 selectedStatus = value;
//                               });
//                             },
//                           );
//                         }).toList(),
//                       ),
//                     ),
//                   ),
                
//                 if (orderViewModel.errorMessage != null)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8.0),
//                     child: Text(
//                       orderViewModel.errorMessage!,
//                       style: const TextStyle(color: Colors.red),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Annuler'),
//             ),
//             ElevatedButton(
//               onPressed: selectedStatus == null || orderViewModel.isUpdatingStatus
//                   ? null
//                   : () async {
//                       final success = await orderViewModel.updateOrderStatus(
//                         orderEventId: widget.order.orderEventId, // Assuming orderId is the event ID
//                         statusId: selectedStatus!.orderStatusId,
//                       );
                      
//                       if (success) {
//                         Navigator.of(context).pop();
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text(orderViewModel.successMessage ?? 'Statut mis à jour'),
//                             backgroundColor: Colors.green,
//                           ),
//                         );
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text(orderViewModel.errorMessage ?? 'Erreur lors de la mise à jour'),
//                             backgroundColor: Colors.red,
//                           ),
//                         );
//                       }
//                     },
//               child: orderViewModel.isUpdatingStatus
//                   ? const SizedBox(
//                       width: 16,
//                       height: 16,
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     )
//                   : const Text('Mettre à jour'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }