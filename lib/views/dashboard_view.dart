// lib/views/dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mescolis/viewmodels/auth_viewmodel.dart';
import 'package:mescolis/viewmodels/dashboard_viewmodel.dart';
import 'package:mescolis/views/packages_view.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Déconnexion'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<DashboardViewModel>(
        builder: (context, dashboardViewModel, child) {
          if (dashboardViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (dashboardViewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(dashboardViewModel.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: dashboardViewModel.refreshStats,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final stats = dashboardViewModel.stats;
          if (stats == null) {
            return const Center(child: Text('Aucune donnée disponible'));
          }

          return RefreshIndicator(
            onRefresh: dashboardViewModel.refreshStats,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Message
                  Consumer<AuthViewModel>(
                    builder: (context, authViewModel, child) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Text(
                                  authViewModel.currentUser?.username.substring(0, 1).toUpperCase() ?? 'U',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bonjour, ${authViewModel.currentUser?.name ?? authViewModel.currentUser?.username ?? 'Livreur'}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Bon travail aujourd\'hui !',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Statistics Cards
                  Text(
                    'Vos Statistiques',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildStatCard(
                        'Total Colis',
                        stats.totalPackages.toString(),
                        Icons.inventory,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        'Livrés',
                        stats.deliveredPackages.toString(),
                        Icons.check_circle,
                        Colors.green,
                      ),
                      _buildStatCard(
                        'En Cours',
                        stats.pendingPackages.toString(),
                        Icons.local_shipping,
                        Colors.orange,
                      ),
                      _buildStatCard(
                        'Échecs',
                        stats.failedPackages.toString(),
                        Icons.error,
                        Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Delivery Rate
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.trending_up, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                'Taux de Livraison',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          LinearProgressIndicator(
                            value: stats.deliveryRate / 100,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              stats.deliveryRate >= 80 ? Colors.green : 
                              stats.deliveryRate >= 60 ? Colors.orange : Colors.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${stats.deliveryRate.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: stats.deliveryRate >= 80 ? Colors.green : 
                                     stats.deliveryRate >= 60 ? Colors.orange : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => _navigateToPackages(context),
                      icon: const Icon(Icons.list_alt),
                      label: const Text(
                        'Voir mes Colis',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPackages(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PackagesView()),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Déconnexion'),
          content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthViewModel>().logout();
              },
              child: const Text('Déconnexion'),
            ),
          ],
        );
      },
    );
  }
}
