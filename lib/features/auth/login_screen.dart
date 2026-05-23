import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // TODO: reemplazar con validación real contra SQLite
    // Por ahora simulamos un usuario de prueba
    await Future.delayed(const Duration(milliseconds: 800));

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // Usuario de prueba temporal hasta tener la DB lista
    if (username == 'ash' && password == '1234') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('username', username);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        _errorMessage = 'Usuario o contraseña incorrectos';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LoginStyles.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: LoginStyles.spacingLarge),

                // GIF de Pikachu
                Image.asset(
                  'assets/images/pikachu_2.gif',
                  height: LoginStyles.gifSize,
                  width: LoginStyles.gifSize,
                ),

                const SizedBox(height: LoginStyles.spacingSmall),

                // Título
                const Text('POKÉDEX', style: LoginStyles.titleStyle),

                const SizedBox(height: LoginStyles.spacingLarge * 1.5),

                // Formulario
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Iniciar sesión',
                          style: LoginStyles.formTitleStyle),

                      const SizedBox(height: LoginStyles.spacingMedium),

                      // Campo username
                      TextFormField(
                        controller: _usernameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: LoginStyles.inputDecoration(
                          'Usuario',
                          Icons.person_outline,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresá tu usuario';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: LoginStyles.spacingMedium),

                      // Campo contraseña
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        style: const TextStyle(color: Colors.white),
                        decoration: LoginStyles.inputDecoration(
                          'Contraseña',
                          Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresá tu contraseña';
                          }
                          if (value.length < 4) {
                            return 'Mínimo 4 caracteres';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: LoginStyles.spacingSmall),

                      // Mensaje de error
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 13,
                            ),
                          ),
                        ),

                      const SizedBox(height: LoginStyles.spacingLarge),

                      // Botón de login
                      ElevatedButton(
                        style: LoginStyles.primaryButtonStyle,
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Ingresar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),

                      const SizedBox(height: LoginStyles.spacingLarge),

                      // Link a registro
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '¿No tenés cuenta? ',
                              style: LoginStyles.linkStyle,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/register');
                              },
                              child: const Text(
                                'Registrate',
                                style: LoginStyles.linkBoldStyle,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: LoginStyles.spacingLarge),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
