import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class ProfileOverview extends StatelessWidget {
  ProfileOverview({super.key});

  final random = Random();

  final colors = List.generate(8, (i) => Colors.blue[(i + 1) * 100]!);

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
              child: ListView(
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
                        'Leone Bacciu',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: 90,
                    backgroundColor: Theme.of(context).colorScheme.onPrimary,
                    child: const CircleAvatar(
                      radius: 80,
                      backgroundImage: AssetImage('assets/avatar.jpg'),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
