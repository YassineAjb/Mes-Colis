// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mescolis/viewmodels/auth_viewmodel.dart';
import 'package:mescolis/viewmodels/dashboard_viewmodel.dart';
import 'package:mescolis/viewmodels/package_viewmodel.dart';
import 'package:mescolis/views/login_view.dart';
import 'package:mescolis/views/dashboard_view.dart';
import 'package:mescolis/services/auth_service.dart';
import 'package:mescolis/services/package_service.dart';

void main() {
  runApp(const MesColisApp());
}

class MesColisApp extends StatelessWidget {
  const MesColisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<PackageService>(
          create: (_) => PackageService(),
        ),
        ChangeNotifierProxyProvider<AuthService, AuthViewModel>(
          create: (context) => AuthViewModel(context.read<AuthService>()),
          update: (context, authService, previous) => 
              previous ?? AuthViewModel(authService),
        ),
        ChangeNotifierProxyProvider<AuthService, DashboardViewModel>(
          create: (context) => DashboardViewModel(context.read<AuthService>()),
          update: (context, authService, previous) => 
              previous ?? DashboardViewModel(authService),
        ),
        ChangeNotifierProxyProvider2<AuthService, PackageService, PackageViewModel>(
          create: (context) => PackageViewModel(
            context.read<AuthService>(),
            context.read<PackageService>(),
          ),
          update: (context, authService, packageService, previous) => 
              previous ?? PackageViewModel(authService, packageService),
        ),
      ],
      child: MaterialApp(
        title: 'MesColis',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Consumer<AuthViewModel>(
          builder: (context, authViewModel, _) {
            return authViewModel.isLoggedIn ? const DashboardView() : const LoginView();
          },
        ),
      ),
    );
  }
}


