import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryColor,
        primary: AppColors.primaryColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.backgroundColor,
      cardColor: Colors.white,
      textTheme: GoogleFonts.notoSansSinhalaTextTheme(
        ThemeData.light().textTheme,
      ),
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryColor,
        primary: AppColors.primaryColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.darkBackgroundColor,
      cardColor: AppColors.darkCardColor,
      textTheme: GoogleFonts.notoSansSinhalaTextTheme(
        ThemeData.dark().textTheme,
      ),
    );

    return MaterialApp(
      title: 'Waruna Transport',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const SplashScreen(),
    );
  }
}
