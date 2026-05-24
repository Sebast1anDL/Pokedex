import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/database/database_helper.dart';
import '../../core/services/shared_preferences_helper.dart';
import '../../main.dart';
import 'settings_styles.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = true;
  int _favoritesCount = 0;
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('is_dark_mode') ?? true;
    final username = prefs.getString('username') ?? 'Entrenador';
    final userId = prefs.getInt('user_id') ?? 0;

    final favorites = await DatabaseHelper().getFavoritesByUser(userId);

    setState(() {
      _isDarkMode = isDark;
      _username = username;
      _favoritesCount = favorites.length;
    });
  }

  Future<void> _toggleTheme(bool isDark) async {
    await SharedPreferencesHelper.saveTheme(isDark);
    themeModeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
    setState(() => _isDarkMode = isDark);
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro que querés cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Cerrar sesión',
              style: TextStyle(color: Color(0xFFCC0000)),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await SharedPreferencesHelper.clearSession();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ajustes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2,
        onDestinationSelected: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/favorites');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.catching_pokemon),
            label: 'Pokédex',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SettingsStyles.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── APARIENCIA ──────────────────────────────
            Text(
              'APARIENCIA',
              style: SettingsStyles.sectionTitleStyle.copyWith(
                color: const Color(0xFFCC0000),
              ),
            ),

            const SizedBox(height: SettingsStyles.spacingSmall),

            Card(
              child: ListTile(
                leading: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: const Color(0xFFCC0000),
                ),
                title: const Text(
                  'Modo oscuro',
                  style: SettingsStyles.itemTitleStyle,
                ),
                subtitle: Text(
                  isDark ? 'Activado' : 'Desactivado',
                  style: SettingsStyles.itemSubtitleStyle,
                ),
                trailing: Switch(
                  value: _isDarkMode,
                  activeColor: const Color(0xFFCC0000),
                  onChanged: _toggleTheme,
                ),
              ),
            ),

            const SizedBox(height: SettingsStyles.spacingLarge),

            // ── ESTADÍSTICAS ─────────────────────────────
            Text(
              'ESTADÍSTICAS',
              style: SettingsStyles.sectionTitleStyle.copyWith(
                color: const Color(0xFFCC0000),
              ),
            ),

            const SizedBox(height: SettingsStyles.spacingSmall),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.person_outline,
                  color: Color(0xFFCC0000),
                ),
                title: const Text(
                  'Usuario',
                  style: SettingsStyles.itemTitleStyle,
                ),
                subtitle: Text(
                  _username,
                  style: SettingsStyles.itemSubtitleStyle,
                ),
              ),
            ),

            const SizedBox(height: SettingsStyles.spacingSmall),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.favorite,
                  color: Color(0xFFCC0000),
                ),
                title: const Text(
                  'Pokémon favoritos',
                  style: SettingsStyles.itemTitleStyle,
                ),
                subtitle: Text(
                  '$_favoritesCount guardados',
                  style: SettingsStyles.itemSubtitleStyle,
                ),
              ),
            ),

            const SizedBox(height: SettingsStyles.spacingLarge),

            // ── SESIÓN ───────────────────────────────────
            Text(
              'SESIÓN',
              style: SettingsStyles.sectionTitleStyle.copyWith(
                color: const Color(0xFFCC0000),
              ),
            ),

            const SizedBox(height: SettingsStyles.spacingSmall),

            ElevatedButton.icon(
              style: SettingsStyles.logoutButtonStyle,
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text(
                'Cerrar sesión',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: SettingsStyles.spacingLarge * 2),

            // ── HECHO POR ────────────────────────────────
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.catching_pokemon,
                    color: Color(0xFFCC0000),
                    size: 32,
                  ),
                  const SizedBox(height: SettingsStyles.spacingSmall),
                  Text(
                    'Pokédex',
                    style: SettingsStyles.madeByStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '099 267 113',
                    style: SettingsStyles.madeByStyle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '© 2026',
                    style: SettingsStyles.madeByStyle.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: SettingsStyles.spacingLarge),
          ],
        ),
      ),
    );
  }
}
