// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mescolis/viewmodels/auth_viewmodel.dart';
import 'package:mescolis/viewmodels/dashboard_viewmodel.dart';
import 'package:mescolis/viewmodels/package_viewmodel.dart';
import 'package:mescolis/views/login_view.dart';
import 'package:mescolis/views/dashboard_view.dart';
import 'package:intl/date_symbol_data_local.dart';

// Import mock services for testing
import 'package:mescolis/services/mock_auth_service.dart';
import 'package:mescolis/services/mock_package_service.dart';

// Import real services (commented out during testing)
// import 'package:mescolis/services/auth_service.dart';
// import 'package:mescolis/services/package_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the French locale
  await initializeDateFormatting('fr');

  runApp(const MesColisApp());
}

class MesColisApp extends StatelessWidget {
  const MesColisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Use mock services for testing
        Provider<MockAuthService>(
          create: (_) => MockAuthService(),
        ),
        Provider<MockPackageService>(
          create: (_) => MockPackageService(),
        ),
        
        // Real services (commented out during testing)
        // Provider<AuthService>(
        //   create: (_) => AuthService(),
        // ),
        // Provider<PackageService>(
        //   create: (_) => PackageService(),
        // ),
        
        ChangeNotifierProxyProvider<MockAuthService, AuthViewModel>(
          create: (context) => AuthViewModel(context.read<MockAuthService>()),
          update: (context, authService, previous) => 
              previous ?? AuthViewModel(authService),
        ),
        ChangeNotifierProxyProvider<MockAuthService, DashboardViewModel>(
          create: (context) => DashboardViewModel(context.read<MockAuthService>()),
          update: (context, authService, previous) => 
              previous ?? DashboardViewModel(authService),
        ),
        ChangeNotifierProxyProvider2<MockAuthService, MockPackageService, PackageViewModel>(
          create: (context) => PackageViewModel(
            context.read<MockAuthService>(),
            context.read<MockPackageService>(),
          ),
          update: (context, authService, packageService, previous) => 
              previous ?? PackageViewModel(authService, packageService),
        ),
      ],
      child: MaterialApp(
        title: 'MesColis',
        debugShowCheckedModeBanner: false,
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



// // lib/main.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:mescolis/viewmodels/auth_viewmodel.dart';
// import 'package:mescolis/viewmodels/dashboard_viewmodel.dart';
// import 'package:mescolis/viewmodels/package_viewmodel.dart';
// import 'package:mescolis/views/login_view.dart';
// import 'package:mescolis/views/dashboard_view.dart';
// import 'package:mescolis/services/auth_service.dart';
// import 'package:mescolis/services/package_service.dart';

// void main() {
//   runApp(const MesColisApp());
// }

// class MesColisApp extends StatelessWidget {
//   const MesColisApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         Provider<AuthService>(
//           create: (_) => AuthService(),
//         ),
//         Provider<PackageService>(
//           create: (_) => PackageService(),
//         ),
//         ChangeNotifierProxyProvider<AuthService, AuthViewModel>(
//           create: (context) => AuthViewModel(context.read<AuthService>()),
//           update: (context, authService, previous) => 
//               previous ?? AuthViewModel(authService),
//         ),
//         ChangeNotifierProxyProvider<AuthService, DashboardViewModel>(
//           create: (context) => DashboardViewModel(context.read<AuthService>()),
//           update: (context, authService, previous) => 
//               previous ?? DashboardViewModel(authService),
//         ),
//         ChangeNotifierProxyProvider2<AuthService, PackageService, PackageViewModel>(
//           create: (context) => PackageViewModel(
//             context.read<AuthService>(),
//             context.read<PackageService>(),
//           ),
//           update: (context, authService, packageService, previous) => 
//               previous ?? PackageViewModel(authService, packageService),
//         ),
//       ],
//       child: MaterialApp(
//         title: 'MesColis',
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//           visualDensity: VisualDensity.adaptivePlatformDensity,
//         ),
//         home: Consumer<AuthViewModel>(
//           builder: (context, authViewModel, _) {
//             return authViewModel.isLoggedIn ? const DashboardView() : const LoginView();
//           },
//         ),
//       ),
//     );
//   }
// }


