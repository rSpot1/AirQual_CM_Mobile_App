import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/air_quality.dart';
import '../models/app_settings.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final lang = settings.language;

    return Scaffold(
      backgroundColor: ext.bgColor,
      appBar: AppBar(
        backgroundColor: ext.bgColor,
        title: Text(
          lang == 'fr' ? 'Paramètres' : 'Settings',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: ext.textColor),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // -- Apparence --------------------------------
          _SectionHeader(title: lang == 'fr' ? 'Apparence' : 'Appearance', ext: ext),
          _SettingsCard(
            ext: ext,
            children: [
              _SwitchTile(
                icon: Icons.dark_mode_rounded,
                iconColor: const Color(0xFFBF5AF2),
                title: lang == 'fr' ? 'Mode sombre' : 'Dark mode',
                subtitle: lang == 'fr'
                    ? 'Thème foncé pour les yeux'
                    : 'Eye-friendly dark theme',
                value: settings.isDark,
                ext: ext,
                onChanged: (v) =>
                    settings.setTheme(v ? ThemeMode.dark : ThemeMode.light),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // -- Langue -----------------------------------
          _SectionHeader(title: lang == 'fr' ? 'Langue' : 'Language', ext: ext),
          _SettingsCard(
            ext: ext,
            children: [
              _RadioTile(
                icon: Icons.language_rounded,
                iconColor: AppColors.primary,
                title: 'Français',
                subtitle: 'Interface en français',
                value: 'fr',
                groupValue: settings.language,
                ext: ext,
                onChanged: (v) => settings.setLanguage(v!),
              ),
              Divider(color: ext.borderColor, height: 1),
              _RadioTile(
                icon: Icons.language_rounded,
                iconColor: AppColors.secondary,
                title: 'English',
                subtitle: 'Interface in English',
                value: 'en',
                groupValue: settings.language,
                ext: ext,
                onChanged: (v) => settings.setLanguage(v!),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // -- Notifications -----------------------------
          _SectionHeader(
              title: lang == 'fr' ? 'Notifications' : 'Notifications',
              ext: ext),
          _SettingsCard(
            ext: ext,
            children: [
              _SwitchTile(
                icon: Icons.notifications_rounded,
                iconColor: AppColors.accent,
                title: lang == 'fr' ? 'Alertes quotidiennes' : 'Daily alerts',
                subtitle: lang == 'fr'
                    ? 'Rapport PM2.5 chaque jour à l\'heure choisie'
                    : 'Daily PM2.5 report at your chosen time',
                value: settings.notificationsEnabled,
                ext: ext,
                onChanged: (v) async {
                  await settings.setNotificationsEnabled(v);
                  final notifSvc = NotificationService();
                  if (v) {
                    final permitted = await notifSvc.requestPermission();
                    if (permitted) {
                      final city = settings.notificationCity.isNotEmpty
                          ? settings.notificationCity
                          : 'Maroua';
                      await notifSvc.scheduleDailyNotification(
                        city: city,
                        lang: settings.language,
                        hour: settings.notifHour,
                        minute: settings.notifMinute,
                        tomorrowPm25: settings.tomorrowPm25 > 0
                            ? settings.tomorrowPm25
                            : null,
                        tomorrowLevel: settings.tomorrowLevel.isNotEmpty
                            ? settings.tomorrowLevel
                            : null,
                      );
                    }
                  } else {
                    await notifSvc.cancelAll();
                  }
                },
              ),
              Divider(color: ext.borderColor, height: 1),
              _NotifCityTile(settings: settings, ext: ext, lang: lang),
              Divider(color: ext.borderColor, height: 1),
              // NOUVEAU : sélecteur d'heure de notification
              _NotifTimeTile(settings: settings, ext: ext, lang: lang),
            ],
          ),

          const SizedBox(height: 8),

          // -- Prévisions --------------------------------
          _SectionHeader(
              title: lang == 'fr' ? 'Prévisions' : 'Forecast', ext: ext),
          _SettingsCard(
            ext: ext,
            children: [
              _DropdownTile(
                icon: Icons.calendar_month_rounded,
                iconColor: AppColors.secondary,
                title: lang == 'fr' ? 'Jours de prévision' : 'Forecast days',
                ext: ext,
                value: settings.forecastDays,
                items: [7, 10, 14],
                labelBuilder: (v) => '$v ${lang == 'fr' ? 'jours' : 'days'}',
                onChanged: (v) => settings.setForecastDays(v!),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // -- Application ---------------------------------
          _SectionHeader(
              title: lang == 'fr' ? 'Application' : 'Application', ext: ext),
          _SettingsCard(
            ext: ext,
            children: [
              _NavTile(
                icon: Icons.info_outline_rounded,
                iconColor: AppColors.primary,
                title: lang == 'fr' ? 'À propos' : 'About',
                subtitle: lang == 'fr'
                    ? 'Informations sur l\'application'
                    : 'App information',
                ext: ext,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Notification Time Picker ──────────────────────────────────────────────────
class _NotifTimeTile extends StatelessWidget {
  final AppSettings settings;
  final AppThemeExtension ext;
  final String lang;

  const _NotifTimeTile({required this.settings, required this.ext, required this.lang});

  @override
  Widget build(BuildContext context) {
    final timeStr =
        '${settings.notifHour.toString().padLeft(2, '0')}:${settings.notifMinute.toString().padLeft(2, '0')}';

    return ListTile(
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.schedule_rounded, color: AppColors.primary, size: 20),
      ),
      title: Text(
        lang == 'fr' ? 'Heure de notification' : 'Notification time',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ext.textColor),
      ),
      subtitle: Text(
        timeStr,
        style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w700),
      ),
      trailing: Icon(Icons.edit_rounded, size: 18, color: ext.textMuted),
      onTap: () => _pickTime(context),
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: settings.notifHour, minute: settings.notifMinute),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) {
      await settings.setNotifTime(picked.hour, picked.minute);
      // Replanifier la notification avec la nouvelle heure
      if (settings.notificationsEnabled) {
        final notifSvc = NotificationService();
        final city = settings.notificationCity.isNotEmpty
            ? settings.notificationCity
            : 'Maroua';
        await notifSvc.scheduleDailyNotification(
          city: city,
          lang: settings.language,
          hour: picked.hour,
          minute: picked.minute,
          tomorrowPm25: settings.tomorrowPm25 > 0 ? settings.tomorrowPm25 : null,
          tomorrowLevel: settings.tomorrowLevel.isNotEmpty ? settings.tomorrowLevel : null,
        );
      }
    }
  }
}

// ── Shared Settings Widgets ───────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final AppThemeExtension ext;

  const _SectionHeader({required this.title, required this.ext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 0, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: ext.textMuted,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final AppThemeExtension ext;

  const _SettingsCard({required this.children, required this.ext});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ext.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ext.borderColor),
      ),
      child: Column(children: children),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final AppThemeExtension ext;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.ext,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ext.textColor)),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 12, color: ext.textMuted)),
      value: value,
      activeColor: AppColors.primary,
      onChanged: onChanged,
    );
  }
}

class _RadioTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String value;
  final String groupValue;
  final AppThemeExtension ext;
  final ValueChanged<String?> onChanged;

  const _RadioTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.ext,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      secondary: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ext.textColor)),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 12, color: ext.textMuted)),
      value: value,
      groupValue: groupValue,
      activeColor: AppColors.primary,
      onChanged: onChanged,
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final AppThemeExtension ext;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.ext,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ext.textColor)),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 12, color: ext.textMuted)),
      trailing: Icon(Icons.chevron_right_rounded, color: ext.textMuted),
      onTap: onTap,
    );
  }
}

class _DropdownTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final AppThemeExtension ext;
  final int value;
  final List<int> items;
  final String Function(int) labelBuilder;
  final ValueChanged<int?> onChanged;

  const _DropdownTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.ext,
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ext.textColor)),
      trailing: DropdownButton<int>(
        value: value,
        underline: const SizedBox(),
        dropdownColor: ext.surfaceColor,
        style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
        items: items
            .map((v) => DropdownMenuItem(value: v, child: Text(labelBuilder(v))))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _NotifCityTile extends StatelessWidget {
  final AppSettings settings;
  final AppThemeExtension ext;
  final String lang;

  const _NotifCityTile({required this.settings, required this.ext, required this.lang});

  @override
  Widget build(BuildContext context) {
    final city = settings.notificationCity.isEmpty
        ? (lang == 'fr' ? 'Ville actuelle' : 'Current city')
        : settings.notificationCity;

    return ListTile(
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: AppColors.danger.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.location_on_rounded, color: AppColors.danger, size: 20),
      ),
      title: Text(
        lang == 'fr' ? 'Ville de notification' : 'Notification city',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ext.textColor),
      ),
      subtitle: Text(city, style: TextStyle(fontSize: 12, color: AppColors.primary)),
      trailing: Icon(Icons.edit_rounded, size: 18, color: ext.textMuted),
      onTap: () => _showCityPicker(context),
    );
  }

  void _showCityPicker(BuildContext context) {
    final cities = CameroonCities.allCities;
    showModalBottomSheet(
      context: context,
      backgroundColor: ext.surfaceColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: cities.length + 1,
        itemBuilder: (_, i) {
          if (i == 0) {
            return ListTile(
              leading: const Icon(Icons.my_location_rounded, color: AppColors.primary),
              title: Text(
                lang == 'fr' ? 'Ville actuelle (GPS)' : 'Current city (GPS)',
                style: TextStyle(fontWeight: FontWeight.w600, color: ext.textColor),
              ),
              onTap: () {
                settings.setNotificationCity('');
                Navigator.pop(context);
              },
            );
          }
          final c = cities[i - 1];
          return ListTile(
            leading: Icon(Icons.location_city_rounded, color: ext.textMuted),
            title: Text(c.name, style: TextStyle(color: ext.textColor)),
            subtitle: Text(c.region, style: TextStyle(fontSize: 12, color: ext.textMuted)),
            onTap: () {
              settings.setNotificationCity(c.name);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
