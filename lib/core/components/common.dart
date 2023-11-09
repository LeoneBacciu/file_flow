import 'package:flutter/material.dart';

enum NavigationRoute {
  cards(0),
  bills(1),
  profile(2),
  bank(3),
  settings(4);

  final int id;

  const NavigationRoute(this.id);

  factory NavigationRoute.fromId(int id) =>
      values.firstWhere((e) => e.id == id);
}

NavigationBar commonNavigationBar(BuildContext context, NavigationRoute route,
        Function(NavigationRoute) onChange) =>
    NavigationBar(
      onDestinationSelected: (int i) {
        if (i != route.id) {
          onChange(NavigationRoute.fromId(i));
          // Navigator.pushReplacement(
          //   context,
          //   PageRouteBuilder(
          //     pageBuilder: (context, _, __) => navigationPages[i],
          //     transitionDuration: Duration.zero,
          //     reverseTransitionDuration: Duration.zero,
          //   ),
          // );
        }
      },
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      // height: 50,
      indicatorColor: Theme.of(context).colorScheme.onPrimary,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      selectedIndex: route.id,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.info), label: 'Carte'),
        NavigationDestination(icon: Icon(Icons.home), label: 'Bollette'),
        NavigationDestination(icon: Icon(Icons.person), label: 'Profilo'),
        NavigationDestination(icon: Icon(Icons.attach_money), label: 'Finanze'),
        NavigationDestination(
            icon: Icon(Icons.more_vert), label: 'Impostazioni'),
      ],
    );

FloatingActionButton commonFloatingActionButton(
        BuildContext context, Object heroTag, VoidCallback onPressed) =>
    FloatingActionButton(
      onPressed: onPressed,
      heroTag: heroTag,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: const Icon(Icons.add),
    );

AppBar commonAppBar(String title) => AppBar(
      centerTitle: true,
      title: Text(title),
    );
