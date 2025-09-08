// ignore_for_file: unnecessary_import

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:icc_claro_app/core/widgets/loading_animation.dart';

class LoadingProgress extends StatelessWidget {
  const LoadingProgress({super.key});

  @override
  Widget build(BuildContext context) => Container(color: const Color(0xFFC21618),
                child: Center(child: LoadingAnimation()),
      );
}
