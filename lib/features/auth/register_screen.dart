import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/database/database_helper.dart';
import 'login_styles.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // Verificar si el username ya existe
    final exists = await DatabaseHelper().usernameExists(username);

    if (exists) {
      setState(() {
        _errorMessage = 'Ese usuario ya está en uso';
        _isLoading = false;
      });
      return;
    }

    // Crear el usuario en SQLite
    final userId = await DatabaseHelper().createUser(
      username: username,
      password: password,
    );

    // Guardar sesión en SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setInt('user_id', userId);
    await prefs.setString('username', username);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo degradado
          Container(
            decoration: const BoxDecoration(
              gradient: LoginStyles.backgroundGradient,
            ),
          ),
          // Contenido
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: LoginStyles.spacingLarge),

                  // GIF
                  Image.asset(
                    'assets/images/masterball.gif',
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
                        const Text(
                          'Crear cuenta',
                          style: LoginStyles.formTitleStyle,
                        ),

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
                              return 'Ingresá un usuario';
                            }
                            if (value.trim().length < 3) {
                              return 'Mínimo 3 caracteres';
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
                              return 'Ingresá una contraseña';
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

                        // Botón de registro
                        ElevatedButton(
                          style: LoginStyles.primaryButtonStyle,
                          onPressed: _isLoading ? null : _register,
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
                                  'Crear cuenta',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),

                        const SizedBox(height: LoginStyles.spacingLarge),

                        // Link a login
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                '¿Ya tenés cuenta? ',
                                style: LoginStyles.linkStyle,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Iniciá sesión',
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
        ],
      ),
    );
  }
}
