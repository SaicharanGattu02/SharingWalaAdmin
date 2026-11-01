import 'package:flutter/material.dart';
import 'app_routes/admin_router.dart';
import 'core/theme/app_theme.dart';
import 'state_injector.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SharingwalaAdminApp());
}

class SharingwalaAdminApp extends StatelessWidget {
  const SharingwalaAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StateInjector(
      child: MaterialApp.router(
        title: 'SharingWala Admin Portal',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AdminRouter.router,
      ),
    );
  }
}
