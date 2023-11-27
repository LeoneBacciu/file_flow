import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../state/sync/sync_cubit.dart';
import '../../../state/user/user_cubit.dart';

class AccountSheet extends StatelessWidget {
  const AccountSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        ListTile(
          leading: const Icon(Icons.switch_account),
          title: const Text('Cambia Profilo'),
          onTap: () {
            BlocProvider.of<SyncCubit>(context).clearCache();
            BlocProvider.of<UserCubit>(context).signOut();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
