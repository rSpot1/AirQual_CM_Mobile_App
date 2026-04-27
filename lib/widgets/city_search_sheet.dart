import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/air_quality.dart';
import '../models/app_settings.dart';
import '../services/air_quality_provider.dart';
import '../theme/app_theme.dart';

class CitySearchSheet extends StatefulWidget {
  const CitySearchSheet({super.key});

  @override
  State<CitySearchSheet> createState() => _CitySearchSheetState();
}

class _CitySearchSheetState extends State<CitySearchSheet> {
  final TextEditingController _controller = TextEditingController();
  List<CityProfile> _results = CameroonCities.allCities;

  void _search(String query) {
    setState(() {
      _results = query.isEmpty
          ? CameroonCities.allCities
          : CameroonCities.allCities
              .where((c) =>
                  c.name.toLowerCase().contains(query.toLowerCase()) ||
                  c.region.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final lang = context.read<AppSettings>().language;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: ext.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: ext.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              lang == 'fr' ? 'Choisir une ville' : 'Select a city',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ext.textColor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _controller,
              onChanged: _search,
              autofocus: true,
              style: TextStyle(color: ext.textColor),
              decoration: InputDecoration(
                hintText: lang == 'fr' ? 'Rechercher...' : 'Search...',
                hintStyle: TextStyle(color: ext.textMuted),
                prefixIcon: Icon(Icons.search_rounded, color: ext.textMuted),
                filled: true,
                fillColor: ext.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: ext.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: ext.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: _results.length,
              separatorBuilder: (_, __) => Divider(color: ext.borderColor, height: 1),
              itemBuilder: (context, i) {
                final city = _results[i];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  leading: Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.location_city_rounded,
                        color: AppColors.primary, size: 20),
                  ),
                  title: Text(
                    city.name,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: ext.textColor),
                  ),
                  subtitle: Text(
                    city.region,
                    style: TextStyle(fontSize: 12, color: ext.textMuted),
                  ),
                  // Pas de trailing PM2.5
                  trailing: Icon(Icons.chevron_right_rounded, color: ext.textMuted, size: 18),
                  onTap: () {
                    context.read<AirQualityProvider>().loadCity(city);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
