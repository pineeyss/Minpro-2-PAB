import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/menu_provider.dart';
import 'models/theme_provider.dart';
import 'pages/login_page.dart';
import 'pages/menu_list_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gwpfivgqlqgvlkecjqzm.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd3cGZpdmdxbHFndmxrZWNqcXptIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMyMTM1MTcsImV4cCI6MjA4ODc4OTUxN30.5AmoivgzEnp_0E0SgL2Fj8L77YCehXO-eQOgoC0Wpkw',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode:
                themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.red,
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: const Color(0xFFFDF7FB),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFFFDF7FB),
                foregroundColor: Colors.black,
                elevation: 0,
                centerTitle: true,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
              inputDecorationTheme: const InputDecorationTheme(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 2),
                ),
                labelStyle: TextStyle(color: Colors.black87),
              ),
              switchTheme: SwitchThemeData(
                thumbColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.red;
                  }
                  return Colors.grey;
                }),
                trackColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.red.withOpacity(0.4);
                  }
                  return Colors.grey.withOpacity(0.4);
                }),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.red,
                brightness: Brightness.dark,
              ),
              appBarTheme: const AppBarTheme(
                elevation: 0,
                centerTitle: true,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                ),
              ),
              inputDecorationTheme: const InputDecorationTheme(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 2),
                ),
              ),
            ),
            home: session == null ? const LoginPage() : const MenuListPage(),
          );
        },
      ),
    );
  }
}
