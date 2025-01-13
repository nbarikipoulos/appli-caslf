import 'package:caslf/services/service.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavBarPage extends StatefulWidget {
  const NavBarPage({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  State<NavBarPage> createState() => _NavBarPageState();
}

class _NavBarPageState extends State<NavBarPage> {
  Future<void>? _future;

  @override
  void initState() {
    super.initState();
    _future = ServicesHandler().init();
  }

  @override
  Widget build(BuildContext context) {
    var barItems = <({IconData icon, String label})>[
      (icon: Icons.calendar_month, label: tr(context)!.nav_bar_time_slot),
      (icon: Icons.message, label: tr(context)!.nav_bar_news),
      (icon: Icons.tune, label: tr(context)!.nav_bar_settings)
    ];

    return FutureBuilder(
      future: _future,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.connectionState != ConnectionState.done
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator()
            )
        )
        : Scaffold(
          resizeToAvoidBottomInset : false,
          bottomNavigationBar: BottomNavigationBar(
          items: barItems.map( (item) => BottomNavigationBarItem(
            icon: Icon(item.icon),
            label: item.label
          )).toList(),
          currentIndex: widget.navigationShell.currentIndex,
          onTap: (int index) => widget.navigationShell.goBranch(index)
          ),
          body: widget.navigationShell,
        );
      },
    );
  }
}
