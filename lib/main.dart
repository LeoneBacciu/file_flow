import 'dart:async';
import 'dart:developer' as dev;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_flow/models/document.dart';
import 'package:file_flow/presentation/add/add_page.dart';
import 'package:file_flow/presentation/settings/settings_page.dart';
import 'package:file_flow/repositories/locator.dart';
import 'package:file_flow/state/sync/sync_cubit.dart';
import 'package:flutter/material.dart';
import 'package:file_flow/core/components/common.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'presentation/bank/bank_page.dart';
import 'presentation/bills/bills_page.dart';
import 'presentation/profile/profile_page.dart';
import 'presentation/cards/cards_page.dart';

void main() async {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();

    loadLocators();

    runApp(MultiBlocProvider(
      providers: [
        ...SyncCubitProvider.getProviders(),
      ],
      child: const MyApp(),
    ));
  }, (e, s) {
    dev.log('Error: $s');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FileFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: BlocListener<SyncCubit, SyncState>(
          listener: (BuildContext context, state) {
            if (state is SyncLoadedSyncing) {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Syncing'),
                  duration: Duration(days: 365),
                ),
              );
            } else if (state is SyncLoadedOffline) {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Offline'),
                  duration: Duration(days: 365),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).clearSnackBars();
            }
          },
          child: const HomeStack()),
    );
  }
}

class HomeStack extends StatefulWidget {
  const HomeStack({super.key});

  @override
  State<HomeStack> createState() => _HomeStackState();
}

class _HomeStackState extends State<HomeStack> {
  var currentRoute = NavigationRoute.profile;
  late StreamSubscription<ConnectivityResult> subscription;

  @override
  void initState() {
    super.initState();
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      BlocProvider.of<SyncCubit>(context).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: currentRoute.id,
      children: [
        CardsPage(
          onRouteChange: onRouteChange,
          onNewDocument: onNewDocument,
        ),
        BillsPage(
          onRouteChange: onRouteChange,
          onNewDocument: onNewDocument,
        ),
        ProfilePage(
          onRouteChange: onRouteChange,
          onNewDocument: onNewDocument,
        ),
        BankPage(
          onRouteChange: onRouteChange,
          onNewDocument: onNewDocument,
        ),
        SettingsPage(
          onRouteChange: onRouteChange,
        )
      ],
    );
  }

  void onRouteChange(NavigationRoute route) =>
      setState(() => currentRoute = route);

  void onNewDocument(DocumentCategory category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddPage(category: category),
      ),
    );
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }
}
