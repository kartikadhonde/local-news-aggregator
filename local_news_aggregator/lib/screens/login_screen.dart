import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/common_widgets.dart';
import 'register_screen.dart';
import 'main_screen.dart';
import 'admin_main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = context.read<AuthService>();
    final success = await authService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      final isAdmin = authService.currentUser?.isAdmin == true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              isAdmin ? const AdminMainScreen() : const MainScreen(),
        ),
      );
    } else {
      showMessage(context, 'Invalid email or password', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.newspaper, size: 64),
                const SizedBox(height: 16),
                const Text('Welcome Back!', style: TextStyle(fontSize: 24)),
                const SizedBox(height: 24),
                buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email,
                  hint: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  validator: validateEmail,
                ),
                const SizedBox(height: 12),
                buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock,
                  hint: 'Enter your password',
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: validatePassword,
                ),
                const SizedBox(height: 16),
                buildLoadingButton(
                  onPressed: _handleLogin,
                  label: 'Login',
                  isLoading: authService.isLoading,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      ),
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
