import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/role_selection_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FncPortalApp());
}

class FncPortalApp extends StatelessWidget {
  const FncPortalApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'FNC Portal',
    debugShowCheckedModeBanner: false,
    theme: FncTheme.light,
    home: const RoleSelectionScreen(),
  );
}
