// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/route_provider.dart';
import '../../widgets/routes/route_card.dart';
import '../../config/routes.dart'; // <--- routes.dart import 추가!

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchData();
      }
    });
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final routeProvider = Provider.of<RouteProvider>(context, listen: false);
      await routeProvider.fetchRoutes();
    } catch (e) {
      if (mounted) {
        print("Error fetching data in HomeScreen _fetchData: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('데이터 로딩 중 오류 발생: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('여정'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              // '/profile' 경로가 routes.dart에 정의되어 있다면 사용
              // 예: Navigator.pushNamed(context, AppRoutes.profile);
              // 정의되지 않았다면 ProfileScreen 직접 푸시 또는 경로 정의 필요
              Navigator.pushNamed(context, '/profile'); // '/profile' 경로 정의 필요
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: Consumer2<AuthProvider, RouteProvider>(
                builder: (context, authProvider, routeProvider, _) {
                  if (!authProvider.isAuthenticated) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                       if(mounted) {
                          Navigator.pushReplacementNamed(context, AppRoutes.login); // 상수 사용
                       }
                    });
                    return Center(child: Text("로그인이 필요합니다. 로그인 화면으로 이동합니다..."));
                  }

                  if (routeProvider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Colors.red, size: 60),
                          SizedBox(height: 16),
                          Text('오류 발생: ${routeProvider.error}'),
                           SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              routeProvider.clearError();
                              _fetchData();
                            },
                            child: Text('다시 시도'),
                          )
                        ],
                      )
                    );
                  }

                  if (routeProvider.routes.isEmpty && !routeProvider.isLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.route, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('아직 생성된 여행 경로가 없습니다', style: Theme.of(context).textTheme.titleMedium),
                          SizedBox(height: 8),
                          Text('새로운 여행 경로를 만들어보세요!', style: Theme.of(context).textTheme.bodyMedium),
                          SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              // '/preference' 대신 정의된 상수 사용
                              Navigator.pushNamed(context, AppRoutes.preferenceInput); // <--- 수정된 부분!
                            },
                            icon: Icon(Icons.add),
                            label: Text('경로 만들기'),
                          ),
                        ],
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '안녕하세요, ${authProvider.user?.name ?? '여행자'}님!',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        SizedBox(height: 8),
                        Text(
                          '당신의 여행 경로를 확인하고 관리하세요',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        SizedBox(height: 24),
                        Text(
                          '내 여행 경로',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: routeProvider.routes.length,
                          itemBuilder: (context, index) {
                            final route = routeProvider.routes[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: RouteCard(
                                route: route,
                                onTap: () {
                                  routeProvider.setCurrentRoute(route);
                                  // route_detail 경로 상수 사용
                                  Navigator.pushNamed(context, AppRoutes.routeDetail); // <--- 상수 사용!
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (Provider.of<AuthProvider>(context, listen: false).isAuthenticated) {
             // '/preference' 대신 정의된 상수 사용
             Navigator.pushNamed(context, AppRoutes.preferenceInput); // <--- 수정된 부분!
          } else {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text('로그인이 필요합니다.'))
             );
          }
        },
        child: Icon(Icons.add),
        tooltip: '새 경로 만들기',
      ),
    );
  }
}