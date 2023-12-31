import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

import '../../../core/colors.dart';
import '../../../core/convert.dart';
import '../../../state/sync/sync_cubit.dart';
import '../../../state/user/user_cubit.dart';

class ProfileOverview extends StatelessWidget {
  ProfileOverview({super.key});

  final random = Random();

  late final colors = List.generate(8, (i) => lighten(seedColor, (8 - i) / 15));

  final heightPercentages = List.generate(8, (i) => (i).toDouble() / 10);

  late final durations =
      List.generate(8, (i) => 30000 + i * 1000 + random.nextInt(1000));

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 350,
      flexibleSpace: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: WaveWidget(
              backgroundColor: Theme.of(context).colorScheme.primary,
              waveAmplitude: 10,
              size: const Size(double.infinity, 400),
              config: CustomConfig(
                colors: colors,
                durations: durations,
                heightPercentages: heightPercentages,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: BlocBuilder<UserCubit, UserState>(
                builder: (context, state) {
                  return ListView(
                    reverse: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.onPrimary,
                                width: 5,
                              )),
                          child: Text(
                            (state is UserSignedIn)
                                ? state.account.displayName ??
                                    state.account.email
                                : '',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onLongPress: () async {
                          if (state is UserSignedIn) {
                            final image = await FilesConverter.convertUrlToFile(
                                state.account.photoUrl!);
                            Share.shareXFiles([XFile(image.path)]);
                          }
                        },
                        child: CircleAvatar(
                          radius: 70,
                          backgroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          child: (state is UserSignedIn &&
                                  state.account.photoUrl != null)
                              ? CircleAvatar(
                                  radius: 60,
                                  backgroundImage:
                                      NetworkImage(state.account.photoUrl!),
                                )
                              : const Icon(Icons.person, size: 100),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 8,
            child: SafeArea(
              child: Material(
                color: Colors.transparent,
                child: Ink(
                  decoration: ShapeDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    shape: const CircleBorder(),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.logout),
                    color: Theme.of(context).colorScheme.onSurface,
                    onPressed: () {
                      BlocProvider.of<SyncCubit>(context).clearCache();
                      BlocProvider.of<UserCubit>(context).signOut();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
