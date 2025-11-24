// lib/main.dart
import 'package:feelings/screens/choose_emotions_screen.dart';
import 'package:feelings/screens/history_page_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:iconsax/iconsax.dart';

import 'emotions_data_hive_entry.dart';
import 'entry_repo.dart';
import 'cubbit/entry_cubbit.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(EmotionEntryAdapter());
  final box = await Hive.openBox('entriesBox');

  getIt.registerSingleton<EntryRepository>(EntryRepository(box));
  getIt.registerSingleton<EntryCubit>(EntryCubit(getIt<EntryRepository>())..load());

  runApp(const FeelingApp());
}

class FeelingApp extends StatelessWidget {
  const FeelingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feeling',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlocProvider.value(
        value: getIt<EntryCubit>(),
        child: const MainNavigationPage(),
      ),
    );
  }
}


class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int currentIndex = 0;

  final screens = const [
    EmotionSelectPage(),
    EmotionHistoryPage(),
  ];

 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: screens[currentIndex],
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (i) => setState(() => currentIndex = i),
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Iconsax.smileys),
          label: "Emocje",
        ),
        BottomNavigationBarItem(
          icon: Icon(Iconsax.timer4),
          label: "Historia",
        ),
      ],
    ),
  );
}
}
