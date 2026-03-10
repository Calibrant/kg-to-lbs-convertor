import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kgtolbs_converter_offline/screens/home_screen.dart';
import 'package:kgtolbs_converter_offline/utils/local_storage.dart';
import 'package:kgtolbs_converter_offline/l10n/app_localizations.dart';

const _colorDarkBlue = Color(0xFF000957);
const _colorRoyalBlue = Color(0xFF344CB7);
const _colorLightBlue = Color(0xFF577BC1);
const _colorYellow = Color(0xFFFFEB00);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Ads
  await MobileAds.instance.initialize();
  
  // Initialize Storage
  final storage = await LocalStorage.init();

  runApp(MyApp(storage: storage));
}

class MyApp extends StatefulWidget {
  final LocalStorage storage;
  const MyApp({super.key, required this.storage});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    String? langCode = widget.storage.getLanguage();
    _locale = Locale(langCode?? 'en'); // if null >'en'
    
    // Load theme
    String themeName = widget.storage.getTheme();
    if (themeName == 'light') _themeMode = ThemeMode.light;
    else if (themeName == 'dark') _themeMode = ThemeMode.dark;
  }

  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void _changeTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
    String themeName = 'system';
    if (mode == ThemeMode.light) themeName = 'light';
    if (mode == ThemeMode.dark) themeName = 'dark';
    widget.storage.saveTheme(themeName);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kg/Lbs Converter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _colorRoyalBlue,
          brightness: Brightness.light,
          primary: _colorRoyalBlue,
          onPrimary: Colors.white,
          secondary: _colorYellow,
          onSecondary: _colorDarkBlue,
          surface: Colors.white,
          onSurface: _colorDarkBlue,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: _colorRoyalBlue,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _colorRoyalBlue,
          brightness: Brightness.dark,
          primary: _colorLightBlue,
          onPrimary: _colorDarkBlue,
          secondary: _colorYellow,
          onSecondary: _colorDarkBlue,
          surface: _colorDarkBlue,
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: _colorDarkBlue,
        appBarTheme: const AppBarTheme(
          backgroundColor: _colorRoyalBlue,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      themeMode: _themeMode,
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: HomeScreen(storage: widget.storage, onLanguageChanged: _changeLanguage, onThemeChanged: _changeTheme),
    );
  }
}
