import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/app_settings.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final lang = settings.language;
    final isFr = lang == 'fr';

    return Scaffold(
      backgroundColor: ext.bgColor,
      appBar: AppBar(
        backgroundColor: ext.bgColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: ext.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isFr ? 'À propos' : 'About',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ext.textColor),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ── Hero ─────────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
              decoration: const BoxDecoration(gradient: AppColors.heroGradient),
              child: Column(
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight]),
                      boxShadow: [BoxShadow(
                          color: AppColors.primary.withOpacity(0.5),
                          blurRadius: 24, spreadRadius: 4)],
                    ),
                    child: const Icon(Icons.air_rounded, color: Colors.white, size: 44),
                  ).animate().scale(
                      begin: const Offset(0.5, 0.5), duration: 600.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 14),
                  const Text('AirQual CM',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700,
                          color: Colors.white, letterSpacing: 1))
                      .animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 6),
                  Text(
                    isFr
                        ? 'Surveillance & prédiction de la qualité de l\'air au Cameroun'
                        : 'Air quality monitoring & prediction in Cameroon',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.65)),
                  ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('AlphaInfera',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                            color: Colors.white, letterSpacing: 2)),
                  ).animate().fadeIn(delay: 500.ms),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ── Guide d'utilisation ───────────────────────────────────
                  _ExpandableSection(
                    icon: Icons.menu_book_rounded,
                    iconColor: AppColors.primary,
                    title: isFr ? 'Guide d\'utilisation' : 'User Guide',
                    ext: ext,
                    delay: 100,
                    children: [
                      _GuideItem(
                        icon: Icons.home_rounded,
                        iconColor: AppColors.primary,
                        title: isFr ? 'Onglet Accueil' : 'Home tab',
                        content: isFr
                            ? 'Affiche la qualité de l\'air en temps réel. La valeur PM2.5 est prédite par le modèle AlphaInfera. Les données météo (température, vent, humidité, radiation) viennent d\'Open-Météo. Tirez vers le bas pour actualiser. Appuyez sur 🔍 pour changer de ville.'
                            : 'Displays real-time air quality. The PM2.5 value is predicted by the AlphaInfera model. Weather data (temperature, wind, humidity, radiation) comes from Open-Meteo. Pull down to refresh. Tap 🔍 to change city.',
                        ext: ext,
                      ),
                      _GuideItem(
                        icon: Icons.map_rounded,
                        iconColor: AppColors.secondary,
                        title: isFr ? 'Onglet Carte' : 'Map tab',
                        content: isFr
                            ? 'Visualisez les PM2.5 prédits pour toutes les villes du Cameroun. Les cercles colorés reflètent les valeurs réelles du modèle. Cliquez sur un marqueur puis "Voir détails" pour charger la ville et revenir à l\'accueil.'
                            : 'View predicted PM2.5 for all Cameroonian cities. Colored circles reflect real model values. Tap a marker then "View details" to load the city and return to Home.',
                        ext: ext,
                      ),
                      _GuideItem(
                        icon: Icons.timeline_rounded,
                        iconColor: AppColors.accent,
                        title: isFr ? 'Onglet Prévisions' : 'Forecast tab',
                        content: isFr
                            ? 'Prévisions PM2.5 sur 7, 10 ou 14 jours. Saisissez une ville dans la barre de recherche (suggestions automatiques) ou utilisez le GPS 📍 pour votre localisation. Les courbes de température et de vent sont interactives.'
                            : 'PM2.5 forecasts for 7, 10 or 14 days. Enter a city in the search bar (auto-suggestions) or use GPS 📍 for your location. Temperature and wind curves are interactive.',
                        ext: ext,
                      ),
                      _GuideItem(
                        icon: Icons.settings_rounded,
                        iconColor: AppColors.purple,
                        title: isFr ? 'Onglet Paramètres' : 'Settings tab',
                        content: isFr
                            ? 'Personnalisez le thème, la langue, la ville et l\'heure de notification. Le PM2.5 du lendemain est stocké localement et affiché dans la notification même sans connexion.'
                            : 'Customize theme, language, notification city and time. Tomorrow\'s PM2.5 is cached locally and shown in the notification even offline.',
                        ext: ext,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ── Projet & Contexte ─────────────────────────────────────
                  _ExpandableSection(
                    icon: Icons.info_outline_rounded,
                    iconColor: AppColors.secondary,
                    title: isFr ? 'Le Projet' : 'The Project',
                    ext: ext,
                    delay: 150,
                    children: [
                      _ContentBlock(
                        content: isFr
                            ? 'AirQual CM est une application de surveillance et de prédiction de la qualité de l\'air au Cameroun, développée dans le cadre du hackathon IndabaX Cameroon 2026. Elle utilise un modèle Random Forest (AlphaInfera, R²=0,999) pour prédire les indices PM2.5 à partir des données météorologiques Open-Meteo.'
                            : 'AirQual CM is an air quality monitoring and prediction app for Cameroon, developed for the IndabaX Cameroon 2026 hackathon. It uses a Random Forest model (AlphaInfera, R²=0.999) to predict PM2.5 values from Open-Meteo weather data.',
                        ext: ext,
                      ),
                      _ContentBlock(
                        content: isFr
                            ? '🌍 Thème : L\'IA au service de la résilience climatique et sanitaire. Le Cameroun fait face à une dégradation croissante de la qualité de l\'air amplifiée par la variabilité climatique : pics de chaleur, stagnation des vents, tempêtes de poussière lors de l\'Harmattan.'
                            : '🌍 Theme: AI for Climate & Health Resilience. Cameroon faces growing air quality degradation amplified by climate variability: heat spikes, wind stagnation, and dust storms during the Harmattan season.',
                        ext: ext,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ── Pollution et santé ────────────────────────────────────
                  _ExpandableSection(
                    icon: Icons.health_and_safety_rounded,
                    iconColor: AppColors.danger,
                    title: isFr ? 'Pollution & santé humaine' : 'Pollution & human health',
                    ext: ext,
                    delay: 200,
                    children: [
                      _ContentBlock(
                        title: isFr ? 'Effets des PM2.5' : 'Effects of PM2.5',
                        content: isFr
                            ? 'Les particules fines (PM2.5, diamètre < 2,5 µm) pénètrent profondément dans les poumons et passent dans le sang, causant :\n\n• Maladies respiratoires (asthme, bronchite, BPCO)\n• Maladies cardiovasculaires (infarctus, AVC)\n• Cancer du poumon (groupe 1 CIRC/OMS)\n• Déclin cognitif et démence précoce\n• Retards de développement chez l\'enfant\n• Aggravation des infections (COVID-19, tuberculose)'
                            : 'Fine particles (PM2.5, diameter < 2.5 µm) penetrate deep into the lungs and enter the bloodstream, causing:\n\n• Respiratory diseases (asthma, bronchitis, COPD)\n• Cardiovascular diseases (heart attacks, strokes)\n• Lung cancer (IARC/WHO Group 1)\n• Cognitive decline and early dementia\n• Developmental delays in children\n• Worsening of infections (COVID-19, tuberculosis)',
                        ext: ext,
                      ),
                      _ContentBlock(
                        title: isFr ? 'Chiffres clés (OMS / IHME 2023)' : 'Key figures (WHO / IHME 2023)',
                        content: isFr
                            ? '• 7 millions de décès prématurés/an liés à la pollution de l\'air\n• 99% de la population mondiale respire un air hors normes OMS\n• ~780 000 décès/an en Afrique subsaharienne\n• PM2.5 moyen Cameroun nord : 22–30 µg/m³ (1,5–2× seuil OMS)\n• 40% des décès PM2.5 en Afrique : enfants < 5 ans\n• Harmattan : PM2.5 x2 à x3 dans l\'Extrême-Nord'
                            : '• 7 million premature deaths/year from air pollution\n• 99% of world population breathes air exceeding WHO standards\n• ~780,000 deaths/year in sub-Saharan Africa\n• Cameroon north PM2.5: 22–30 µg/m³ (1.5–2× WHO limit)\n• 40% of PM2.5 deaths in Africa: children < 5 years\n• Harmattan: PM2.5 ×2 to ×3 in Far North',
                        ext: ext,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ── Modèle IA ─────────────────────────────────────────────
                  _ExpandableSection(
                    icon: Icons.psychology_rounded,
                    iconColor: AppColors.purple,
                    title: isFr ? 'Modèle IA — AlphaInfera' : 'AI Model — AlphaInfera',
                    ext: ext,
                    delay: 250,
                    children: [
                      _ContentBlock(
                        content: isFr
                            ? 'Algorithme : Random Forest entraîné sur des données historiques de qualité de l\'air et de météorologie du Cameroun.\n\nVariables clés : température max/min, vitesse du vent, précipitations, rayonnement solaire, durée d\'ensoleillement, ETP, saison Harmattan.\n\nPrécision : R² = 0,999\n\nLes prédictions sont calculées en temps réel via l\'API Open-Meteo.'
                            : 'Algorithm: Random Forest trained on historical air quality and meteorological data from Cameroon.\n\nKey features: max/min temperature, wind speed, precipitation, solar radiation, sunshine duration, ETP, Harmattan season.\n\nAccuracy: R² = 0.999\n\nPredictions are computed in real time via the Open-Meteo API.',
                        ext: ext,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ── Sources ───────────────────────────────────────────────
                  _ExpandableSection(
                    icon: Icons.source_rounded,
                    iconColor: AppColors.primary,
                    title: isFr ? 'Sources de données' : 'Data Sources',
                    ext: ext,
                    delay: 300,
                    children: [
                      _ContentBlock(
                        content: isFr
                            ? '• Open-Meteo API — Données météorologiques temps réel\n• AlphaInfera Random Forest — Prédiction PM2.5\n• OMS / IARC — Seuils sanitaires recommandés\n• IHME Global Burden of Disease — Statistiques sanitaires'
                            : '• Open-Meteo API — Real-time weather data\n• AlphaInfera Random Forest — PM2.5 prediction\n• WHO / IARC — Recommended health thresholds\n• IHME Global Burden of Disease — Health statistics',
                        ext: ext,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ── Support technique ─────────────────────────────────────
                  _ExpandableSection(
                    icon: Icons.support_agent_rounded,
                    iconColor: AppColors.primary,
                    title: isFr ? 'Support technique' : 'Technical support',
                    ext: ext,
                    delay: 350,
                    initiallyExpanded: true,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: ext.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ext.borderColor),
                        ),
                        child: Column(
                          children: [
                            Row(children: [
                              Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.person_rounded,
                                    color: AppColors.primary, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('Barka Fidèle',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                                        color: ext.textColor)),
                                Text(isFr ? 'Support technique' : 'Technical support',
                                    style: TextStyle(fontSize: 12, color: ext.textMuted)),
                              ]),
                            ]),
                            const SizedBox(height: 10),
                            Row(children: [
                              const Icon(Icons.email_rounded, color: AppColors.primary, size: 18),
                              const SizedBox(width: 8),
                              const Text('barkafidele@yahoo.com',
                                  style: TextStyle(
                                    fontSize: 13, color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  )),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Directive OMS ─────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        AppColors.primary.withOpacity(0.1),
                        AppColors.secondary.withOpacity(0.05),
                      ]),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.health_and_safety_rounded,
                          color: AppColors.primary, size: 28),
                      const SizedBox(width: 12),
                      Expanded(child: Text(
                        isFr
                            ? 'L\'OMS recommande un maximum de 15 µg/m³ de PM2.5 en moyenne annuelle pour protéger la santé humaine.'
                            : 'WHO recommends a maximum of 15 µg/m³ PM2.5 annual average to protect human health.',
                        style: TextStyle(fontSize: 13, color: ext.textSecondary, height: 1.5),
                      )),
                    ]),
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 24),

                  // ── Footer avec version ───────────────────────────────────
                  Center(
                    child: Column(children: [
                      Text(
                        '© 2026 AlphaInfera · AirQual CM\nMade with ❤️ for Cameroon',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: ext.textMuted, height: 1.6),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: ext.cardColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: ext.borderColor),
                        ),
                        child: Text('v1.0.0 · IndabaX Cameroon 2026',
                            style: TextStyle(fontSize: 11, color: ext.textMuted,
                                fontWeight: FontWeight.w500)),
                      ),
                    ]),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Expandable Section ────────────────────────────────────────────────────────
class _ExpandableSection extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final AppThemeExtension ext;
  final List<Widget> children;
  final int delay;
  final bool initiallyExpanded;

  const _ExpandableSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.ext,
    required this.children,
    this.delay = 0,
    this.initiallyExpanded = false,
  });

  @override
  State<_ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<_ExpandableSection>
    with SingleTickerProviderStateMixin {
  late bool _expanded;
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this,
        value: _expanded ? 1.0 : 0.0);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.ext.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.ext.borderColor),
      ),
      child: Column(
        children: [
          // Header cliquable
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: widget.iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.icon, color: widget.iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(widget.title,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                          color: widget.ext.textColor)),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(Icons.keyboard_arrow_down_rounded,
                      color: widget.ext.textMuted, size: 22),
                ),
              ]),
            ),
          ),
          // Contenu animé
          SizeTransition(
            sizeFactor: _anim,
            child: Column(
              children: [
                Divider(color: widget.ext.borderColor, height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.children,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: widget.delay))
        .slideY(begin: 0.1, end: 0);
  }
}

// ── Guide Item ────────────────────────────────────────────────────────────────
class _GuideItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String content;
  final AppThemeExtension ext;

  const _GuideItem({
    required this.icon, required this.iconColor,
    required this.title, required this.content, required this.ext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 17),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                  color: ext.textColor)),
              const SizedBox(height: 4),
              Text(content, style: TextStyle(fontSize: 12, color: ext.textSecondary, height: 1.5)),
            ],
          )),
        ],
      ),
    );
  }
}

// ── Content Block ─────────────────────────────────────────────────────────────
class _ContentBlock extends StatelessWidget {
  final String? title;
  final String content;
  final AppThemeExtension ext;

  const _ContentBlock({this.title, required this.content, required this.ext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                color: ext.textColor)),
            const SizedBox(height: 6),
          ],
          Text(content, style: TextStyle(fontSize: 12, color: ext.textSecondary, height: 1.6)),
        ],
      ),
    );
  }
}
