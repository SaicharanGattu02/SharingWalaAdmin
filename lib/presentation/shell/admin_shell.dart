import 'package:flutter/material.dart';
import '../../widgets/responsive_layout.dart';
import 'admin_header.dart';
import 'admin_sidebar.dart';

class AdminShell extends StatefulWidget {
  final Widget child;
  final String currentRoute;
  final String title;

  const AdminShell({
    super.key,
    required this.child,
    required this.currentRoute,
    required this.title,
  });

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      key: _scaffoldKey,
      drawer: isDesktop
          ? null
          : Drawer(
              child: AdminSidebar(
                currentRoute: widget.currentRoute,
              ),
            ),
      body: Row(
        children: [
          // Sidebar on Desktop
          if (isDesktop)
            AdminSidebar(
              currentRoute: widget.currentRoute,
            ),

          // Main Screen Area with Sticky Header
          Expanded(
            child: Column(
              children: [
                AdminHeader(
                  title: widget.title,
                  onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                Expanded(
                  child: widget.child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

