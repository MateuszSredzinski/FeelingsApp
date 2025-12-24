import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';

class SettingsCubit extends Cubit<bool> {
  SettingsCubit(this._box) : super(_box.get(_key, defaultValue: true) as bool);

  static const _key = 'intensity_enabled';
  final Box _box;

  bool get intensityEnabled => state;

  Future<void> setIntensityEnabled(bool value) async {
    await _box.put(_key, value);
    emit(value);
  }
}
