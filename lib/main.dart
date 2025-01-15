import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'firebase_options.dart';

// import 'package:icc_maps/data/form/form_state.dart';
// import 'package:icc_maps/data/services/dropdown_data_loader.dart';
// import 'package:icc_maps/ui/context/user_provider.dart';
// import 'package:icc_maps/ui/pages/login/login_page.dart';
// import 'package:icc_maps/ui/pages/map/provider/points_of_sale_provider.dart';
// import 'package:icc_maps/ui/pages/map/provider/map_provider.dart';
import 'package:icc_maps/ui/pages/map/provider/google_map_provider.dart';
import 'package:icc_maps/ui/pages/map/widgets/map/google_map_page.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  // await Hive.initFlutter();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // await _requestLocationPermission();

  runApp(const MyApp());
}

// Future<void> _requestLocationPermission() async {
//   var status = await Permission.location.status;
//   if (!status.isGranted) {
//     status = await Permission.location.request();
//   }
//   if (status.isDenied) {
//     print('El permiso de ubicación fue denegado.');
//   }
//   if (status.isPermanentlyDenied) {
//     openAppSettings();
//   }
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          // ChangeNotifierProvider(create: (_) => UserProvider()),
          // ChangeNotifierProvider(create: (_) => PointsOfSaleProvider()),
          // ChangeNotifierProvider(create: (_) => MapProvider()),
          // ChangeNotifierProvider(create: (_) => DropdownDataLoader()),
          // ChangeNotifierProvider(create: (_) => FormStateHandler()),
          ChangeNotifierProvider(create: (_) => GoogleMapProvider()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'IcClaro',
          initialRoute: '/',
          routes: {'/': (context) => const GoogleMapPage()},
        ),
      );
}
