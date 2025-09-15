import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icc_claro_app/core/widgets/loading_progress.dart';

Future<T?> withImmersiveLoader<T>(
  BuildContext context,
  Future<T> Function() task,
) async {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  showDialog(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    builder: (_) => const Stack(
      children: [
        ModalBarrier(dismissible: false, color: Colors.black54),
        Center(child: LoadingProgress()),
      ],
    ),
  );

  try {
    await Future.delayed(const Duration(milliseconds: 16));
    return await task();
  } finally {
    final rootNav = Navigator.of(context, rootNavigator: true);
    if (rootNav.canPop()) rootNav.pop();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
}
