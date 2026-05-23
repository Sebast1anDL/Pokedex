import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'splash_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _startLoading();
  }

  void _initControllers() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _fadeController.forward();
  }

  Future<void> _startLoading() async {
    await Future.wait([
      Future.delayed(const Duration(seconds: 3)),
      _initializeApp(),
    ]);

    if (mounted) {
      _navigateNext();
    }
  }

  Future<void> _initializeApp() async {
    await SharedPreferences.getInstance();
  }

  Future<void> _navigateNext() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: SplashStyles.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // GIF de Pikachu
                Image.asset(
                  'assets/images/pikachu.gif',
                  height: SplashStyles.gifSize,
                  width: SplashStyles.gifSize,
                ),

                const SizedBox(height: SplashStyles.spacingLarge),

                // Título con fade
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    'POKÉDEX',
                    style: SplashStyles.titleStyle,
                  ),
                ),

                const SizedBox(height: SplashStyles.spacingSmall),

                // Subtítulo con fade
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    'Gotta catch \'em all',
                    style: SplashStyles.subtitleStyle,
                  ),
                ),

                const SizedBox(height: SplashStyles.spacingLarge),

                // Indicador de carga
                const SizedBox(
                  height: SplashStyles.loaderSize,
                  width: SplashStyles.loaderSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    color: SplashStyles.loaderColor,
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
