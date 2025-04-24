// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// --- 필요한 스크린 import 추가 ---
import 'screens/home/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
// --- import 끝 ---

import 'config/routes.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/route_provider.dart';
import 'providers/preference_provider.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/storage_service.dart';
import 'models/preference.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // .env 파일 사용 시
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // --- 서비스 인스턴스 생성 ---
  final apiService = ApiService(baseUrl: dotenv.env['API_URL'] ?? 'http://localhost:5904');
  final storageService = StorageService();
  final authService = AuthService(apiService: apiService, storageService: storageService);

  runApp(MyApp(authService: authService, apiService: apiService, storageService: storageService)); // 다른 서비스도 전달
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  final ApiService apiService;
  final StorageService storageService;

  const MyApp({
    Key? key,
    required this.authService,
    required this.apiService,
    required this.storageService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // --- ADD THIS LINE ---
        // Provide the ApiService instance that was created in main()
        Provider<ApiService>.value(value: apiService), // <<< --- FIX

        // --- Other Providers ---
        // AuthProvider depends on AuthService (which indirectly uses ApiService and StorageService)
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService),
        ),
        // RouteProvider depends on ApiService
        ChangeNotifierProvider(
          // Pass the already existing apiService instance
          create: (_) => RouteProvider(
            apiService: apiService,
            storageService: storageService,
            travelPreference: TravelPreference(
              region: '', // Provide defaults for all required fields
              style: '',
              budget: '',
              companion: '',
              mobilityLimit: '',
              usePublicTransport: true,
            ),
          ),
        ),
        // PreferenceProvider depends on ApiService and StorageService
        ChangeNotifierProvider(
           create: (_) => PreferenceProvider(
              apiService: apiService, // Pass existing instance
              storageService: storageService // Pass existing instance
           ),
        ),
        // You might also need to provide StorageService if other widgets need it directly
        // Provider<StorageService>.value(value: storageService), // Optional: uncomment if needed
      ],
      child: Consumer<AuthProvider>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Pathmaker',
          theme: appTheme,
          home: auth.isLoading
                ? SplashScreen()
                : auth.isAuthenticated
                  ? HomeScreen()
                  : LoginScreen(),
          onGenerateRoute: AppRoutes.generateRoute,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}