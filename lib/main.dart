import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'controllers/game_controller.dart';
import 'screens/game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI to immersive/transparent
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  final gameController = GameController();
  await gameController.initialize();

  runApp(CrossmathApp(controller: gameController));
}

class CrossmathApp extends StatelessWidget {
  final GameController controller;

  const CrossmathApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final theme = controller.theme;

        return MaterialApp(
          title: 'Crossmath Puzzle',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            brightness: theme.isDark ? Brightness.dark : Brightness.light,
            scaffoldBackgroundColor: theme.backgroundColor,
            colorScheme: ColorScheme.fromSeed(
              seedColor: theme.accentColor,
              brightness: theme.isDark ? Brightness.dark : Brightness.light,
            ),
          ),
          home: GameScreen(controller: controller),
        );
      },
    );
  }
}
