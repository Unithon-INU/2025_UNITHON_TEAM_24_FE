import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/route_provider.dart';
import '../../widgets/routes/route_card.dart';
import '../../widgets/common/loading_indicator.dart';

class RouteListScreen extends StatefulWidget {
  @override
  _RouteListScreenState createState() => _RouteListScreenState();
}

class _RouteListScreenState extends State<RouteListScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchRoutes();
  }

  Future<void> _fetchRoutes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<RouteProvider>(context, listen: false).fetchRoutes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('경로를 불러오는데 실패했습니다: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 여행 경로'),
      ),
      body: _isLoading
          ? LoadingIndicator()
          : Consumer<RouteProvider>(
              builder: (context, routeProvider, _) {
                // ... (empty list case) ...

                return RefreshIndicator(
                  onRefresh: _fetchRoutes,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: routeProvider.routes.length,
                    itemBuilder: (context, index) {
                      // --- 추가: itemCount 변경으로 인한 오류 방지 ---
                      // 삭제 도중 index가 범위를 벗어날 수 있으므로 확인
                      if (index >= routeProvider.routes.length) {
                        return SizedBox.shrink(); // 안전하게 빈 위젯 반환
                      }
                      // --- 추가 끝 ---
                      final route = routeProvider.routes[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Dismissible(
                          key: Key(route.id), // 고유 키 사용
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: 20.0),
                            color: Colors.red,
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text('삭제 확인'),
                                content: Text('이 경로를 정말 삭제하시겠습니까?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(false),
                                    child: Text('취소'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(true), // true 반환하여 삭제 진행
                                    child: Text('삭제', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                          onDismissed: (direction) async { // async 추가
                            // --- 수정: Provider 호출 및 오류 처리 ---
                            try {
                              await routeProvider.deleteRoute(route.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${route.id} 경로가 삭제되었습니다')), // TODO: routeName 사용?
                              );
                            } catch (e) {
                              // 오류 발생 시 목록 새로고침 또는 사용자에게 알림
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('경로 삭제 실패: ${e.toString()}')),
                              );
                              // 삭제 실패 시 UI 상태 복원 (Provider가 롤백하므로 UI는 자동으로 복원될 수 있음)
                              // 필요하다면 _fetchRoutes() 호출하여 목록 동기화
                              _fetchRoutes();
                            }
                            // --- 수정 끝 ---
                          },
                          child: RouteCard(
                            route: route,
                            onTap: () {
                              routeProvider.setCurrentRoute(route);
                              Navigator.pushNamed(context, '/route-detail');
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/preference');
        },
        child: Icon(Icons.add),
        tooltip: '새 경로 만들기',
      ),
    );
  }
}