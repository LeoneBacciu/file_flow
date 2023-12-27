import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';

import 'core/components/common.dart';
import 'models/document.dart';
import 'presentation/add/add_loader_page.dart';
import 'presentation/add/add_page.dart';
import 'presentation/bank/bank_page.dart';
import 'presentation/bills/bills_page.dart';
import 'presentation/cards/cards_page.dart';
import 'presentation/profile/profile_page.dart';
import 'presentation/settings/settings_page.dart';
import 'repositories/locator.dart';
import 'state/sync/sync_cubit.dart';
import 'state/user/user_cubit.dart';

void main() async {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();

    loadLocators();

    runApp(MultiBlocProvider(
      providers: [
        ...UserCubitProvider.getProviders(),
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
      home: const HomeStack(),
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
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  late StreamSubscription _intentDataStreamSubscription;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<UserCubit>(context).signIn();
    _intentDataStreamSubscription =
        FlutterSharingIntent.instance.getMediaStream().listen(
      (List<SharedFile> value) {
        if (value.isNotEmpty) openAdd(value);
      },
    );

    FlutterSharingIntent.instance.getInitialSharing().then(
      (List<SharedFile> value) {
        if (value.isNotEmpty) openAdd(value);
      },
    );
  }

  void openAdd(List<SharedFile> sharedFiles) {
    final files = sharedFiles.map((e) => File(e.value!)).toList();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddLoaderPage(files: files),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SyncCubit, SyncState>(
      listener: (BuildContext context, state) {
        if (state is SyncLoadedSyncing) {
          ScaffoldMessenger.of(context).clearSnackBars();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedTextKit(
                    animatedTexts: [WavyAnimatedText('Syncing...')],
                    isRepeatingAnimation: true,
                  ),
                ),
                duration: const Duration(days: 365),
              ),
            );
          });
        } else if (state is SyncLoadedOffline) {
          ScaffoldMessenger.of(context).clearSnackBars();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Offline'),
                duration: Duration(days: 365),
              ),
            );
          });
        } else {
          ScaffoldMessenger.of(context).clearSnackBars();
        }
      },
      child: BlocConsumer<UserCubit, UserState>(
        listener: (BuildContext context, UserState state) {
          if (state is UserSignedIn) {
            _connectivitySubscription = Connectivity()
                .onConnectivityChanged
                .listen((ConnectivityResult result) {
              BlocProvider.of<SyncCubit>(context).load();
            });
          } else {
            _connectivitySubscription?.cancel();
            BlocProvider.of<UserCubit>(context).signIn();
          }
        },
        builder: (context, state) {
          if (state is! UserSignedIn) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return IndexedStack(
            index: currentRoute.id,
            children: [
              Offstage(
                offstage: currentRoute.id != 0,
                child: CardsPage(
                  onRouteChange: onRouteChange,
                  onNewDocument: onNewDocument,
                ),
              ),
              Offstage(
                offstage: currentRoute.id != 1,
                child: BillsPage(
                  onRouteChange: onRouteChange,
                  onNewDocument: onNewDocument,
                ),
              ),
              Offstage(
                offstage: currentRoute.id != 2,
                child: ProfilePage(
                  onRouteChange: onRouteChange,
                  onNewDocument: onNewDocument,
                ),
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
        },
      ),
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
    _connectivitySubscription?.cancel();
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }
}
