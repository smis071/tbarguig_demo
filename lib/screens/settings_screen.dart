import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  String currentLanguage = 'fr'; // اللغة الافتراضية الفرنسية

  @override
  void initState() {
    super.initState();
    isDarkMode = Theme.of(context).brightness == Brightness.dark;
  }

  void _toggleTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });

    final brightness = value ? Brightness.dark : Brightness.light;
    final theme = ThemeData(brightness: brightness);
    WidgetsBinding.instance.renderViewElement?.markNeedsBuild();
    ThemeMode.system == ThemeMode.system;
  }

  void _changeLanguage(String langCode) {
    context.setLocale(Locale(langCode));
    setState(() {
      currentLanguage = langCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor =
        theme.brightness == Brightness.dark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Paramètres",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 10),
          _sectionTitle("Apparence"),

          // الوضع الليلي
          SwitchListTile(
            title: const Text("Mode sombre"),
            subtitle: const Text("Active ou désactive le mode sombre"),
            value: isDarkMode,
            onChanged: (value) {
              setState(() => isDarkMode = value);
            },
            secondary: const Icon(Icons.dark_mode_outlined),
          ),

          const SizedBox(height: 20),
          _sectionTitle("Langue"),

          // اختيار اللغة
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("Langue de l'application"),
            subtitle: Text(
              currentLanguage == 'fr'
                  ? "Français"
                  : currentLanguage == 'ar'
                      ? "العربية"
                      : "English",
            ),
            trailing: DropdownButton<String>(
              value: currentLanguage,
              onChanged: (value) {
                if (value != null) _changeLanguage(value);
              },
              items: const [
                DropdownMenuItem(value: 'fr', child: Text("Français")),
                DropdownMenuItem(value: 'ar', child: Text("العربية")),
                DropdownMenuItem(value: 'en', child: Text("English")),
              ],
            ),
          ),

          const SizedBox(height: 20),
          _sectionTitle("Compte"),

          // تعديل الملف الشخصي
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text("Modifier le profil"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            onTap: () {},
          ),

          // الإشعارات
          ListTile(
            leading: const Icon(Icons.notifications_none),
            title: const Text("Notifications"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            onTap: () {},
          ),

          // الخصوصية
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text("Confidentialité"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            onTap: () {},
          ),

          const SizedBox(height: 20),
          _sectionTitle("Support"),

          // المساعدة
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text("Aide et support"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            onTap: () {},
          ),

          // حول التطبيق
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("À propos de l'application"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            onTap: () {},
          ),

          const SizedBox(height: 20),

          // تسجيل الخروج
          Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: () {},
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                "Se déconnecter",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 30),
          Center(
            child: Text(
              "Version 1.0.0",
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Colors.grey,
        ),
      ),
    );
  }
}
