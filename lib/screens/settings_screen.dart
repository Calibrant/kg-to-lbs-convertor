import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kgtolbs_converter_offline/utils/local_storage.dart';
import 'package:kgtolbs_converter_offline/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  final LocalStorage storage;
  final Function(Locale) onLanguageChanged;
  final Function(ThemeMode) onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.storage,
    required this.onLanguageChanged,
    required this.onThemeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '';
  String _packageName = '';
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _loadAd();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = info.version;
      _packageName = info.packageName;
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

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLang = widget.storage.getLanguage() ?? 'en';
    final currentTheme = widget.storage.getTheme();
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final gradientColors = isDarkMode
        ? [const Color(0xFF000957), const Color(0xFF0F226E)]
        : [const Color(0xFFF0F4FF), const Color(0xFFE0E7FF)];

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
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSettingsCard(
                  icon: Icons.language,
                  title: l10n.language,
                  trailing: DropdownButton<String>(
                    value: currentLang,
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'ru', child: Text('Русский')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        widget.onLanguageChanged(Locale(val));
                        widget.storage.saveLanguage(val);
                      }
                    },
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xFFFFEB00),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildSettingsCard(
                  icon: Icons.brightness_6,
                  title: l10n.theme,
                  trailing: DropdownButton<String>(
                    value: currentTheme,
                    items: [
                      DropdownMenuItem(
                        value: 'system',
                        child: Text(l10n.themeSystem),
                      ),
                      DropdownMenuItem(
                        value: 'light',
                        child: Text(l10n.themeLight),
                      ),
                      DropdownMenuItem(
                        value: 'dark',
                        child: Text(l10n.themeDark),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        ThemeMode mode = val == 'light'
                            ? ThemeMode.light
                            : (val == 'dark'
                                  ? ThemeMode.dark
                                  : ThemeMode.system);
                        widget.onThemeChanged(mode);
                      }
                    },
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xFFFFEB00),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSettingsCard(
                  icon: Icons.privacy_tip_outlined,
                  title: l10n.privacyPolicy,
                  onTap: () async {
                    final Uri url = Uri.parse(
                      'https://fantazeyapp.github.io/privacy.html',
                    ); // Замените на вашу ссылку
                    if (!await launchUrl(url)) {
                      // Handle error
                    }
                  },
                ),
                const SizedBox(height: 12),
                _buildSettingsCard(
                  icon: Icons.star_rate_outlined,
                  title: l10n.rateApp,
                  onTap: () async {
                    final Uri url = Uri.parse(
                      'https://play.google.com/store/apps/details?id=$_packageName',
                    );
                    if (!await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    )) {
                      // Fallback or error handling if needed
                    }
                  },
                ),
                const SizedBox(height: 12),
                _buildSettingsCard(
                  icon: Icons.share,
                  title: l10n.shareApp,
                  onTap: () {
                    Share.share(
                      'Check out this Kg/Lbs Converter app! https://play.google.com/store/apps/details?id=$_packageName',
                    );
                  },
                ),
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    '${l10n.version} $_version',
                    style: TextStyle(
                      color: isDarkMode
                          ? const Color(0xFFB0C4FF)
                          : const Color(0xFF5A7BDB),
                    ),
                  ),
                ),
              ],
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

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDarkMode ? const Color(0xFF1a234f) : Colors.white,
      child: ListTile(
        leading: Icon(
          icon,
          color: isDarkMode ? const Color(0xFFFFEB00) : const Color(0xFF344CB7),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : const Color(0xFF000957),
          ),
        ),
        trailing:
            trailing ??
            (onTap != null
                ? const Icon(Icons.chevron_right, color: Color(0xFF577BC1))
                : null),
        onTap: onTap,
      ),
    );
  }
}
