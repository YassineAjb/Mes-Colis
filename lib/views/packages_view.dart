// lib/views/packages_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:mescolis/viewmodels/package_viewmodel.dart';
import 'package:mescolis/models/package_model.dart';
import 'package:mescolis/views/package_detail_view.dart';

class PackagesView extends StatefulWidget {
  const PackagesView({super.key});

  @override
  State<PackagesView> createState() => _PackagesViewState();
}

class _PackagesViewState extends State<PackagesView> {
  PackageStatus? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Colis'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<PackageStatus?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
              context.read<PackageViewModel>().filterByStatus(filter);
            },
            itemBuilder: (context) => [
              const PopupMenuItem<PackageStatus?>(
                value: null,
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('Tous'),
                  ],
                ),
              ),
              ...PackageStatus.values.map((status) => PopupMenuItem<PackageStatus>(
                value: status,
                child: Row(
                  children: [
                    Icon(_getStatusIcon(status)),
                    const SizedBox(width: 8),
                    Text(status.label),
                  ],
                ),
              )),
            ],
          ),
        ],
      ),
      body: Consumer<PackageViewModel>(
        builder: (context, packageViewModel, child) {
          if (packageViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (packageViewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(packageViewModel.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: packageViewModel.refreshPackages,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final packages = packageViewModel.packages;
          
          if (packages.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    _selectedFilter == null 
                        ? 'Aucun colis disponible'
                        : 'Aucun colis avec ce filtre',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (_selectedFilter != null) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedFilter = null;
                        });
                        context.read<PackageViewModel>().filterByStatus(null);
                      },
                      child: const Text('Supprimer le filtre'),
                    ),
                  ],
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: packageViewModel.refreshPackages,
            child: Column(
              children: [
                // Filter Indicator
                if (_selectedFilter != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: Colors.blue.shade50,
                    child: Row(
                      children: [
                        Icon(_getStatusIcon(_selectedFilter!), size: 16),
                        const SizedBox(width: 8),
                        Text('Filtre: ${_selectedFilter!.label}'),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedFilter = null;
                            });
                            context.read<PackageViewModel>().filterByStatus(null);
                          },
                          child: const Text('Supprimer'),
                        ),
                      ],
                    ),
                  ),

                // Packages List
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: packages.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final package = packages[index];
                      return _buildPackageCard(context, package);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPackageCard(BuildContext context, Package package) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToPackageDetail(context, package),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Colis #${package.id}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(package.status),
                ],
              ),
              const SizedBox(height: 12),

              // Address
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      package.deliveryAddress,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Scheduled Date
              if (package.scheduledDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(package.scheduledDate!),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],

              // Failure Reason
              if (package.status == PackageStatus.failed && package.failureReason != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    package.failureReason!.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
              ],

              // Action Buttons
              if (package.status != PackageStatus.delivered) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showStatusUpdateDialog(context, package),
                        icon: const Icon(Icons.edit),
                        label: const Text('Qualifier'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _markAsDelivered(context, package),
                      icon: const Icon(Icons.check),
                      label: const Text('Livré'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(PackageStatus status) {
    Color color;
    switch (status) {
      case PackageStatus.pending:
        color = Colors.orange;
        break;
      case PackageStatus.inTransit:
        color = Colors.blue;
        break;
      case PackageStatus.delivered:
        color = Colors.green;
        break;
      case PackageStatus.failed:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(status), size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(PackageStatus status) {
    switch (status) {
      case PackageStatus.pending:
        return Icons.schedule;
      case PackageStatus.inTransit:
        return Icons.local_shipping;
      case PackageStatus.delivered:
        return Icons.check_circle;
      case PackageStatus.failed:
        return Icons.error;
    }
  }

  void _navigateToPackageDetail(BuildContext context, Package package) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PackageDetailView(package: package),
      ),
    );
  }

  void _markAsDelivered(BuildContext context, Package package) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la livraison'),
        content: Text('Marquer le colis #${package.id} comme livré ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _updatePackageStatus(context, package.id, PackageStatus.delivered);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _showStatusUpdateDialog(BuildContext context, Package package) {
    FailureReason? selectedReason;
    DateTime? postponedDate;
    final dateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Qualifier le colis #${package.id}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sélectionnez une raison :'),
                const SizedBox(height: 12),
                ...FailureReason.values.map((reason) => RadioListTile<FailureReason>(
                  title: Text(reason.label),
                  value: reason,
                  groupValue: selectedReason,
                  onChanged: (value) {
                    setDialogState(() {
                      selectedReason = value;
                    });
                  },
                )),

                // Date field for "Reporté daté"
                if (selectedReason == FailureReason.postponedWithDate) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      labelText: 'Date de report (JJ/MM/AAAA)',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setDialogState(() {
                          postponedDate = date;
                          dateController.text = DateFormat('dd/MM/yyyy').format(date);
                        });
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: selectedReason == null ? null : () {
                if (selectedReason == FailureReason.postponedWithDate && postponedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez sélectionner une date')),
                  );
                  return;
                }
                
                Navigator.of(context).pop();
                _updatePackageStatus(
                  context, 
                  package.id, 
                  PackageStatus.failed,
                  failureReason: selectedReason,
                  postponedDate: selectedReason == FailureReason.postponedTomorrow 
                      ? DateTime.now().add(const Duration(days: 1))
                      : postponedDate,
                );
              },
              child: const Text('Confirmer'),
            ),
          ],
        ),
      ),
    );
  }

  void _updatePackageStatus(
    BuildContext context,
    String packageId,
    PackageStatus status, {
    FailureReason? failureReason,
    DateTime? postponedDate,
  }) async {
    final packageViewModel = context.read<PackageViewModel>();
    
    final success = await packageViewModel.updatePackageStatus(
      packageId,
      status,
      failureReason: failureReason,
      postponedDate: postponedDate,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Statut mis à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la mise à jour'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
