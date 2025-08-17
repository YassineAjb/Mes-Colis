
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:mescolis/services/api_service.dart.dart';
import 'package:mescolis/services/runsheet_service.dart.dart';
import 'package:mescolis/viewmodels/dashboard_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:mescolis/services/auth_service.dart';
import 'package:mescolis/services/order_service.dart';
import 'package:mescolis/services/car_service.dart';
import 'package:mescolis/viewmodels/auth_viewmodel.dart';
import 'package:mescolis/viewmodels/order_viewmodel.dart';
import 'package:mescolis/views/login_view.dart';
import 'package:mescolis/views/home_view.dart';

void main() {
  runApp(const MesColisApp());
}

class MesColisApp extends StatelessWidget {
  const MesColisApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider<AuthService>(
          create: (context) => AuthService(),
        ),
        ProxyProvider<AuthService, ApiService>(
          update: (context, authService, previous) => ApiService(authService),
        ),
        ProxyProvider2<ApiService, AuthService, OrderService>(
          update: (context, apiService, authService, previous) => OrderService(apiService, authService),
        ),
        ProxyProvider2<ApiService, AuthService, CarService>(
          update: (context, apiService, authService, previous) => CarService(apiService, authService),
        ),
        ProxyProvider2<ApiService, AuthService, RunsheetService>(
          update: (context, apiService, authService, previous) => RunsheetService(apiService, authService),
        ),

        // ViewModels
        ChangeNotifierProxyProvider<AuthService, AuthViewModel>(
          create: (context) => AuthViewModel(context.read<AuthService>()),
          update: (context, authService, previous) => AuthViewModel(authService),
        ),
        ChangeNotifierProxyProvider<OrderService, OrderViewModel>(
          create: (context) => OrderViewModel(context.read<OrderService>()),
          update: (context, orderService, previous) => OrderViewModel(orderService),
        ),
        ChangeNotifierProxyProvider2<RunsheetService, CarService, RunsheetViewModel>(
          create: (context) => RunsheetViewModel(
            context.read<RunsheetService>(),
            context.read<CarService>(),
          ),
          update: (context, runsheetService, carService, previous) => RunsheetViewModel(
            runsheetService,
            carService,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'MesColis',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        if (authViewModel.isLoggedIn) {
          return const HomeView();
        } else {
          return const LoginView();
        }
      },
    );
  }
}