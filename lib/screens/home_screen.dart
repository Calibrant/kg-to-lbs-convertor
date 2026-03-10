import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kgtolbs_converter_offline/screens/progress_screen.dart';
import 'package:kgtolbs_converter_offline/screens/settings_screen.dart';
import 'package:kgtolbs_converter_offline/utils/local_storage.dart';
import 'package:kgtolbs_converter_offline/utils/weight_converter.dart';
import 'package:kgtolbs_converter_offline/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  final LocalStorage storage;
  final Function(Locale) onLanguageChanged;
  final Function(ThemeMode) onThemeChanged;

  const HomeScreen({
    super.key,
    required this.storage,
    required this.onLanguageChanged,
    required this.onThemeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _weightController = TextEditingController();
  final ScreenshotController _screenshotController = ScreenshotController();

  int _currentIndex = 0;
  bool _isKg = true;
  double _convertedValue = 0.0;
  double? _goalWeight;
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadState();
    _loadAd();
  }

  void _loadState() {
    setState(() {
      _isKg = widget.storage.getIsKg();
      double? savedWeight = widget.storage.getCurrentWeight();
      _goalWeight = widget.storage.getGoalWeight();

      if (savedWeight != null) {
        _weightController.text = savedWeight.toString();
        _calculateConversion(savedWeight.toString());
      }
    });
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-2717584945928240/2883547422',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  void _calculateConversion(String value) {
    if (value.isEmpty) {
      setState(() => _convertedValue = 0.0);
      return;
    }
    double? input = double.tryParse(value);
    if (input != null) {
      setState(() {
        _convertedValue = _isKg
            ? WeightConverter.kgToLbs(input)
            : WeightConverter.lbsToKg(input);
      });
      // Auto-save current weight
      widget.storage.saveCurrentWeight(input);
    }
  }

  void _toggleUnit() {
    setState(() {
      _isKg = !_isKg;
      widget.storage.saveIsKg(_isKg);
      // Recalculate based on current input
      _calculateConversion(_weightController.text);
    });
  }

  Future<void> _setGoal() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.setGoal),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: l10n.targetWeight,
            suffixText: _isKg ? 'kg' : 'lbs',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              double? val = double.tryParse(controller.text);
              double? current = double.tryParse(_weightController.text);
              if (val != null && current != null) {
                // Рассчитываем целевой вес: Текущий - Цель (сколько сбросить)
                double target = current - val;
                setState(() {
                  _goalWeight = target;
                });
                widget.storage.saveGoalWeight(target);
                Navigator.pop(context);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  Future<void> _shareProgress() async {
    final directory = await getTemporaryDirectory();
    final imagePath = await _screenshotController.captureAndSave(
      directory.path,
      fileName: 'progress_share.png',
    );

    if (imagePath != null) {
      await Share.shareXFiles([
        XFile(imagePath),
      ], text: 'Check out my weight loss progress!');
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Screenshot(
      controller: _screenshotController,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.appTitle),
          backgroundColor: const Color(0xFF344CB7),
          elevation: 4.0,
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _buildConverterView(l10n, theme),
            SettingsScreen(
              storage: widget.storage,
              onLanguageChanged: widget.onLanguageChanged,
              onThemeChanged: widget.onThemeChanged,
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.calculate),
              label: l10n.appTitle,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: l10n.settings,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConverterView(AppLocalizations l10n, ThemeData theme) {
    final isDarkMode = theme.brightness == Brightness.dark;

    final gradientColors = isDarkMode
        ? [const Color(0xFF000957), const Color(0xFF0F226E)]
        : [const Color(0xFFF0F4FF), const Color(0xFFE0E7FF)];

    Widget inputCard = isDarkMode
        ? ClipRRect(
            borderRadius: BorderRadius.circular(24.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF344CB7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(
                    width: 1,
                    color: const Color(0xFF344CB7).withOpacity(0.2),
                  ),
                ),
                child: _buildCardContent(l10n, theme),
              ),
            ),
          )
        : Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildCardContent(l10n, theme),
            ),
          );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Input Section
                  inputCard,

                  const SizedBox(height: 24),

                  // Goal Section
                  if (_goalWeight != null) ...[
                    _buildGoalProgress(l10n, theme),
                  ] else
                    ElevatedButton.icon(
                      onPressed: _setGoal,
                      icon: const Icon(Icons.flag),
                      label: Text(l10n.setGoalLose),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: const Color(0xFF344CB7),
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProgressScreen(
                                  storage: widget.storage,
                                  isKg: _isKg,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.show_chart),
                          label: Text(l10n.viewProgress),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF577BC1),
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _shareProgress,
                          icon: const Icon(Icons.share),
                          label: Text(l10n.shareProgress),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF577BC1),
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isAdLoaded)
            SizedBox(
              height: _bannerAd!.size.height.toDouble(),
              width: _bannerAd!.size.width.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }

  Widget _buildGoalProgress(AppLocalizations l10n, ThemeData theme) {
    double current = double.tryParse(_weightController.text) ?? 0;
    double goal = _goalWeight!;
    double diff = current - goal;

    // Simple progress logic: assuming weight loss.
    // If current > goal, we have work to do.
    // This is a simplified visual representation.

    return Column(
      children: [
        Text(
          '${l10n.remaining}: ${WeightConverter.format(diff)} ${_isKg ? 'kg' : 'lbs'}',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: current <= goal ? 1.0 : 0.5, // Simplified for demo
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ).animate().scaleX(duration: 1000.ms, curve: Curves.easeOut),
        const SizedBox(height: 8),
        Text(
              current <= goal ? l10n.congrats : l10n.motivationHalf,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF344CB7),
                fontWeight: FontWeight.bold,
              ),
            )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fade(duration: 1000.ms),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _setGoal,
          icon: const Icon(Icons.edit),
          label: Text(l10n.setGoalLose),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.onSurface,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildCardContent(AppLocalizations l10n, ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: theme.textTheme.headlineMedium,
                decoration: InputDecoration(
                  labelText: l10n.currentWeight,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _weightController.clear();
                      _calculateConversion('');
                    },
                  ),
                ),
                onChanged: _calculateConversion,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              children: [
                Text(
                  _isKg ? 'KG' : 'LBS',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: !_isKg,
                  onChanged: (val) => _toggleUnit(),
                  activeColor: theme.colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.swap_vert),
              const SizedBox(width: 8),
              Text(
                '${WeightConverter.format(_convertedValue)} ${_isKg ? 'lbs' : 'kg'}',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.brightness == Brightness.light
                      ? const Color(0xFFFFA500)
                      : const Color(0xFFFFEB00),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
