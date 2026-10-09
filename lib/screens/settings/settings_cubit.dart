import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState extends Equatable {
  final String userName;
  final String currencySymbol;
  final ThemeMode themeMode;

  const SettingsState({
    required this.userName,
    required this.currencySymbol,
    required this.themeMode,
  });

  SettingsState copyWith({
    String? userName,
    String? currencySymbol,
    ThemeMode? themeMode,
  }) {
    return SettingsState(
      userName: userName ?? this.userName,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object> get props => [userName, currencySymbol, themeMode];
}

/// Holds the user's preferences and persists them on the device.
class SettingsCubit extends Cubit<SettingsState> {
  static const _kName = 'settings.userName';
  static const _kCurrency = 'settings.currency';
  static const _kTheme = 'settings.themeMode';

  static const currencies = <String, String>{
    '₹': 'Indian Rupee (₹)',
    '\$': 'US Dollar (\$)',
    '€': 'Euro (€)',
    '£': 'British Pound (£)',
    'C\$': 'Canadian Dollar (C\$)',
    'A\$': 'Australian Dollar (A\$)',
    '¥': 'Japanese Yen (¥)',
  };

  final SharedPreferences _prefs;

  SettingsCubit(this._prefs)
      : super(SettingsState(
          userName: _prefs.getString(_kName) ?? 'Kashish Patel',
          currencySymbol: _prefs.getString(_kCurrency) ?? '₹',
          themeMode: ThemeMode.values.firstWhere(
            (m) => m.name == _prefs.getString(_kTheme),
            orElse: () => ThemeMode.light,
          ),
        ));

  void setUserName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    _prefs.setString(_kName, trimmed);
    emit(state.copyWith(userName: trimmed));
  }

  void setCurrency(String symbol) {
    _prefs.setString(_kCurrency, symbol);
    emit(state.copyWith(currencySymbol: symbol));
  }

  void setThemeMode(ThemeMode mode) {
    _prefs.setString(_kTheme, mode.name);
    emit(state.copyWith(themeMode: mode));
  }
}
