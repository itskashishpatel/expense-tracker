import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'screens/home/views/home_screen.dart';
import 'screens/settings/settings_cubit.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select((SettingsCubit c) => c.state.themeMode);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Expense Tracker",
      themeMode: themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        cardColor: Colors.white,
        colorScheme: ColorScheme.light(
          surface: Colors.grey.shade100,
          onSurface: Colors.black,
          primary: const Color(0xFF00B2E7),
          secondary: const Color(0xFFE064F7),
          tertiary: const Color(0xFFFF8D6C),
          outline: Colors.grey,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        cardColor: const Color(0xFF1E1E22),
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF121214),
          onSurface: Colors.white,
          primary: Color(0xFF00B2E7),
          secondary: Color(0xFFE064F7),
          tertiary: Color(0xFFFF8D6C),
          outline: Colors.grey,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
