// lib/views/package_detail_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mescolis/models/package_model.dart';

class PackageDetailView extends StatelessWidget {
  final Package package;

  const PackageDetailView({
    super.key,
    required this.package,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Colis #${package.id}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(package.status),
                      size: 32,
                      color: _getStatusColor(package.status),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Statut',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            package.status.label,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(package.status),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Delivery Information
            _buildInfoSection(
              'Informations de livraison',
              [
                _InfoItem(
                  icon: Icons.location_on,
                  label: 'Adresse de livraison',
                  value: package.deliveryAddress,
                ),
                if (package.scheduledDate != null)
                  _InfoItem(
                    icon: Icons.schedule,
                    label: 'Date prévue',
                    value: DateFormat('EEEE dd MMMM yyyy à HH:mm', 'fr').format(package.scheduledDate!),
                  ),
                if (package.description != null && package.description!.isNotEmpty)
                  _InfoItem(
                    icon: Icons.description,
                    label: 'Description',
                    value: package.description!,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Contact Information
            if (package.clientContact != null && package.clientContact!.isNotEmpty)
              _buildInfoSection(
                'Contact client',
                [
                  _InfoItem(
                    icon: Icons.phone,
                    label: 'Téléphone',
                    value: package.clientContact!,
                    onTap: () => _showContactOptions(context, package.clientContact!),
                  ),
                ],
              ),

            const SizedBox(height: 16),

            // Failure Information
            if (package.status == PackageStatus.failed && package.failureReason != null) ...[
              _buildInfoSection(
                'Informations d\'échec',
                [
                  _InfoItem(
                    icon: Icons.error,
                    label: 'Raison',
                    value: package.failureReason!.label,
                  ),
                  if (package.postponedDate != null)
                    _InfoItem(
                      icon: Icons.event,
                      label: 'Nouvelle date',
                      value: DateFormat('EEEE dd MMMM yyyy', 'fr').format(package.postponedDate!),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Map placeholder (if coordinates available)
            if (package.latitude != null && package.longitude != null) ...[
              Card(
                child: Container(
                  height: 200,
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Carte de localisation',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lat: ${package.latitude!.toStringAsFixed(6)}, Long: ${package.longitude!.toStringAsFixed(6)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<_InfoItem> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...items.map((item) => _buildInfoRow(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(_InfoItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                item.icon,
                size: 20,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.value,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (item.onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                ),
            ],
          ),
        ),
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

  Color _getStatusColor(PackageStatus status) {
    switch (status) {
      case PackageStatus.pending:
        return Colors.orange;
      case PackageStatus.inTransit:
        return Colors.blue;
      case PackageStatus.delivered:
        return Colors.green;
      case PackageStatus.failed:
        return Colors.red;
    }
  }

  void _showContactOptions(BuildContext context, String phoneNumber) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Appeler'),
              onTap: () {
                Navigator.pop(context);
                // Implement phone call functionality
                // You might want to use url_launcher package
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Envoyer un SMS'),
              onTap: () {
                Navigator.pop(context);
                // Implement SMS functionality
                // You might want to use url_launcher package
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copier le numéro'),
              onTap: () {
                Navigator.pop(context);
                // Implement copy to clipboard functionality
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem {
  
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });
}