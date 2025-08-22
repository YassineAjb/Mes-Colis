// lib/views/login_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mescolis/viewmodels/auth_viewmodel.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    //color: Colors.blue[600],
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60), // keep it circular
                    child: Image.asset(
                      'assets/logo.png',   
                      fit: BoxFit.cover,   // cover to fill the container
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Title
                Text(
                  'Mes Colis',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Application Livreur',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.teal[600],
                  ),
                ),
                const SizedBox(height: 48),
                
                // Login Form
                Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Card(
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Connexion',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal[800],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            
                            // Username Field
                            TextFormField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Nom d\'utilisateur',
                                prefixIcon: Icon(Icons.person),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez saisir votre nom d\'utilisateur';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // Password Field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Mot de passe',
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez saisir votre mot de passe';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            
                            // Error Message
                            Consumer<AuthViewModel>(
                              builder: (context, authViewModel, child) {
                                if (authViewModel.errorMessage != null) {
                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.only(bottom: 16),
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
                                            authViewModel.errorMessage!,
                                            style: TextStyle(color: Colors.red[600]),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                            
                            // Login Button
                            Consumer<AuthViewModel>(
                              builder: (context, authViewModel, child) {
                                return ElevatedButton(
                                  onPressed: authViewModel.isLoading
                                      ? null
                                      : () => _handleLogin(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal[600],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: authViewModel.isLoading
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
                                            Text('Connexion...'),
                                          ],
                                        )
                                      : const Text(
                                          'Se connecter',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final authViewModel = context.read<AuthViewModel>();
      authViewModel.clearError();
      
      authViewModel.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }
}