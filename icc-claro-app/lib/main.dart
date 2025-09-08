import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:icc_claro_app/core/widgets/inactivity_logout_widget.dart';
import 'package:icc_claro_app/features/authentication/data/models/notification_service.dart';
import 'package:icc_claro_app/features/authentication/presentation/login/login_page.dart';
import 'package:icc_claro_app/features/authentication/users/user_provider.dart';
import 'package:icc_claro_app/features/features/map/data/repositories/dropdown_data_loader.dart';
import 'package:icc_claro_app/features/features/map/data/repositories/form_state.dart';
import 'package:icc_claro_app/features/features/map/data/repositories/maps_repository.dart';
import 'package:icc_claro_app/features/features/map/domain/usecases/get_markers_usecase.dart';
import 'package:icc_claro_app/features/features/map/data/repositories/point_of_sale_repository.dart';
import 'package:icc_claro_app/features/features/map/presentation/widgets/point_of_sale_filtered_map_screen.dart';
import 'package:icc_claro_app/features/features/providers/coverage_provider.dart';
import 'package:icc_claro_app/features/features/providers/map_provider.dart';
import 'package:icc_claro_app/features/features/providers/point_of_sale_providers.dart';
import 'package:icc_claro_app/features/home/home_page.dart';
import 'package:icc_claro_app/features/routesicc/repository/route_state.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firebase_options.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();

  await NotificationService.init();
  tz.initializeTimeZones();

  await _requestLocationPermission();
  await _requestCameraPermission();
  await NotificationService.init();
  runApp(const MyApp());
}

Future<void> _requestLocationPermission() async {
  var status = await Permission.location.status;
  if (!status.isGranted) {
    status = await Permission.location.request();
  }
  if (status.isDenied) {
    print('El permiso de ubicación fue denegado.');
  }
  if (status.isPermanentlyDenied) {
    openAppSettings();
  }
}

Future<void> _requestCameraPermission() async {
  var status = await Permission.camera.status;
  if (!status.isGranted) {
    status = await Permission.camera.request();
  }
  if (status.isDenied) {
    print('El permiso de cámara fue denegado.');
  }
  if (status.isPermanentlyDenied) {
    openAppSettings();
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<MapsRepository>(
          create: (_) => MapsRepository(),
        ),
        ProxyProvider<MapsRepository, GetMarkersUseCase>(
          update: (_, repository, __) => GetMarkersUseCase(repository),
        ),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => DropdownDataLoader()),
        ChangeNotifierProvider(create: (_) => FormStateHandler()),
        ChangeNotifierProvider(create: (_) => RouteStateHandler()),
        ChangeNotifierProvider<MapProvider>(
          create: (context) => MapProvider(
            context.read<GetMarkersUseCase>(),
            context.read<MapsRepository>(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => CoverageProvider()),
        ChangeNotifierProvider(
          create: (_) => PointOfSaleProvider(PointOfSaleRepository()),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'IcClaro',
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginPage(),
          '/home': (context) => const InactivityLogoutWidget(
                child: HomePage(username: '', password: ''),
              )
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/filtered-map') {
            final filters = settings.arguments as Map<String, String>;
            return MaterialPageRoute(
              builder: (_) => PointOfSaleFilteredMapScreen(filters: filters),
            );
          }
          return null;
        },
      ),
    );
  }
}
