// lib/config/routes.dart
import 'package:flutter/material.dart';
import '../models/place.dart'; // Arguments 타입 위해 import
import '../models/route.dart'; // Arguments 타입 위해 import
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart'; // import 추가
import '../screens/home/home_screen.dart';
// import '../screens/home/profile_screen.dart'; // ProfileScreen 사용 시 import
import '../screens/preference/preference_input_screen.dart';
// import '../screens/routes/route_list_screen.dart'; // RouteListScreen 사용 시 import
import '../screens/routes/route_detail_screen.dart';
import '../screens/routes/route_edit_screen.dart';
// import '../screens/places/place_list_screen.dart'; // PlaceListScreen 사용 시 import
import '../screens/places/place_detail_screen.dart';
import '../screens/splash_screen.dart';
import '../widgets/debug/network_test_widget.dart'; // NetworkTestWidget import 추가

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String preferenceInput = '/preference-input';
  static const String routeDetail = '/route-detail';
  static const String routeEdit = '/edit-route';
  static const String placeDetail = '/place-detail';
  // 필요에 따라 다른 라우트 이름 정의
  // static const String profile = '/profile';
  // static const String routeList = '/routes';
  // static const String placeList = '/places';


  // onGenerateRoute 방식으로 변경
  static Route<dynamic> generateRoute(RouteSettings settings) {
    print("Navigating to ${settings.name}");
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => SignupScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => ForgotPasswordScreen());
      case home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case preferenceInput:
        return MaterialPageRoute(builder: (_) => PreferenceInputScreen());
      case routeDetail:
         // arguments 타입 캐스팅 및 null 체크 강화
         final route = settings.arguments is TravelRoute ? settings.arguments as TravelRoute : null;
        return MaterialPageRoute(builder: (_) => RouteDetailScreen(/* route: route */)); // 파라미터 전달 방식 확인 필요
      case routeEdit:
         final route = settings.arguments is TravelRoute ? settings.arguments as TravelRoute : null;
        return MaterialPageRoute(builder: (_) => RouteEditScreen(/* route: route */)); // 파라미터 전달 방식 확인 필요
      case placeDetail:
        final placeId = settings.arguments as String?;
        if (placeId == null || placeId.isEmpty) {
          print("Routes: Invalid placeId provided to placeDetail route");
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: Text('오류')),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red),
                    SizedBox(height: 16),
                    Text('장소 ID가 유효하지 않습니다.'),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.of(_).pop(),
                      child: Text('돌아가기'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        print("Routes: Navigating to PlaceDetailScreen with placeId: $placeId");
        return MaterialPageRoute(builder: (_) => PlaceDetailScreen(placeId: placeId));

      // 다른 라우트들 정의 (필요시)
      // case profile:
      //   return MaterialPageRoute(builder: (_) => ProfileScreen());
      // case routeList:
      //   return MaterialPageRoute(builder: (_) => RouteListScreen());
      // case placeList:
      //   return MaterialPageRoute(builder: (_) => PlaceListScreen());
      case '/network-test':
        return MaterialPageRoute(builder: (_) => NetworkTestWidget());
      default:
        // 정의되지 않은 라우트 처리
        return MaterialPageRoute(
          builder: (_) => Scaffold(
             appBar: AppBar(title: Text('오류')),
            body: Center(
              child: Text('${settings.name} 경로를 찾을 수 없습니다.'),
            ),
          ),
        );
    }
  }
}

// 기존 appRoutes 맵은 이제 사용하지 않음 (onGenerateRoute 사용 시)
// final appRoutes = <String, WidgetBuilder>{
//   '/login': (ctx) => LoginScreen(),
//   '/signup': (ctx) => SignupScreen(),
//   '/forgot-password': (ctx) => ForgotPasswordScreen(),
//   '/home': (ctx) => HomeScreen(),
//   // ... 다른 라우트들 ...
// };