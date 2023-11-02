import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs;
});

final nameProvider = FutureProvider<String?>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return prefs.getString('name');
});

final columnsProvider = FutureProvider<int?>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return prefs.getInt('columns');
});

final rowsProvider = FutureProvider<int?>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return prefs.getInt('rows');
});

final storedMaterialProvider = FutureProvider<List<String>?>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return prefs.getStringList('storedMaterial');
});
final xlPathProviderProvider = FutureProvider<String?>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return prefs.getString('xlPath');
});
