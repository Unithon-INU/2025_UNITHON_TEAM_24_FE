// lib/screens/routes/route_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'package:map_launcher/map_launcher.dart' as mapLauncher;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/place.dart';
import '../../models/route.dart';
import '../../providers/route_provider.dart';
import '../../widgets/routes/route_map.dart';
import '../../widgets/places/place_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../places/place_detail_screen.dart';

class RouteDetailScreen extends StatefulWidget {
  @override
  _RouteDetailScreenState createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prov = Provider.of<RouteProvider>(context, listen: false);
      print("RouteDetailScreen initialized. Current route: ${prov.currentRoute?.id}");
      print("Is loading: ${prov.isLoading}");
      
      if (!prov.isLoading) {
        if (prov.currentRoute == null) {
          print("No current route available");
          // Try to load from arguments if available
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is String) {
            print("Trying to load route with ID: $args");
            try {
              await prov.fetchRouteById(args);
            } catch (e) {
              print("Error fetching route by ID from args: $e");
            }
          }
          return;
        }
        
        print("Current route has ${prov.currentRoute!.places.length} places");
        print("Current route has ${prov.currentRoute!.movingInfo.length} moving info items");
        
        // 장소 목록이 없거나(요약 데이터만 있는 경우) 또는 이동 정보 누락 시 상세 정보 요청
        if (prov.currentRoute!.places.isEmpty || 
            (prov.currentRoute!.places.length > 1 && prov.currentRoute!.movingInfo.length < prov.currentRoute!.places.length - 1)) {
          try {
            print("Fetching detailed route information for ID: ${prov.currentRoute!.id}");
            await prov.fetchRouteById(prov.currentRoute!.id);
            print("After fetch: Route has ${prov.currentRoute?.places.length} places");
          } catch (e) {
            print("Error fetching route details: $e");
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('경로 정보를 불러오는데 실패했습니다: $e')),
              );
            }
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print("RouteDetailScreen build method called");
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Consumer<RouteProvider>(builder: (_, prov, __) {
        final route = prov.currentRoute;
        print("Consumer rebuild - isLoading: ${prov.isLoading}, route: ${route?.id}, places: ${route?.places.length}");
        
        if (prov.isLoading) {
          return LoadingIndicator(message: '경로 정보를 불러오는 중...');
        }
        if (route == null) {
          return Center(child: Text('경로 정보를 표시할 수 없습니다.'));
        }
        if (route.places.isEmpty) {
          return Center(child: Text('경로에 등록된 장소가 없습니다.'));
        }
        return _RouteContent(route: route);
      }),
      floatingActionButton: _BuildNavigateFab(),
    );
  }

  AppBar _buildAppBar(BuildContext context) => AppBar(
        title: Text('추천 경로'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined),
            onPressed: () {
              final prov = Provider.of<RouteProvider>(context, listen: false);
              if (prov.currentRoute != null) {
                Navigator.pushNamed(context, '/edit-route');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('편집할 경로 정보가 없습니다.')),
                );
              }
            },
          ),
          IconButton(icon: Icon(Icons.share_outlined), onPressed: () {/* TODO: 공유 기능 */}),
        ],
      );
}

// ---------------------------------------------------
// 메인 내용 위젯 (_RouteContent)
// ---------------------------------------------------
class _RouteContent extends StatelessWidget {
  final TravelRoute route;
  
  const _RouteContent({required this.route});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 지도 표시 영역
        SizedBox(
          height: 250,
          child: RouteMap(
            route: route,  // Pass the entire route object instead of individual properties
          ),
        ),
        // 장소 목록
        Expanded(child: _PlaceList(route: route)),
      ],
    );
  }
}

// ---------------------------------------------------
// 장소 목록 위젯 (_PlaceList)
// ---------------------------------------------------
class _PlaceList extends StatelessWidget {
  final TravelRoute route;
  
  const _PlaceList({required this.route});

  @override
  Widget build(BuildContext context) {
    if (route.places.isEmpty) {
      return Center(child: Text('등록된 장소가 없습니다.'));
    }
    
    // 총 아이템 수 = 장소 수 + (장소 사이의 이동정보 수)
    final itemCount = route.places.length * 2 - 1;
    
    return ListView.builder(
      padding: EdgeInsets.only(bottom: 80, top: 8),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index.isEven) {
          // 장소 카드 표시
          final placeIndex = index ~/ 2;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: PlaceCard(
              place: route.places[placeIndex],
              index: placeIndex + 1,
              onTap: () {
                final placeId = route.places[placeIndex].id;
                print("Navigating to place detail with ID: $placeId");
                
                // 화면을 교체하는 방식으로 네비게이션 (중복 헤더 방지)
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlaceDetailScreen(placeId: placeId),
                  ),
                );
              },
            ),
          );
        } else {
          // 이동 정보 표시 (장소 사이의 이동)
          final movingIndex = index ~/ 2;
          if (movingIndex >= route.movingInfo.length) {
            return SizedBox.shrink(); // 이동 정보가 없는 경우
          }
          
          return _MovingInfoCard(movingInfo: route.movingInfo[movingIndex]);
        }
      },
    );
  }
}

// ---------------------------------------------------
// 이동 정보 카드 위젯 (_MovingInfoCard)
// ---------------------------------------------------
class _MovingInfoCard extends StatelessWidget {
  final MovingInfo movingInfo;
  
  const _MovingInfoCard({required this.movingInfo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.arrow_downward, color: Colors.grey),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${movingInfo.transportType ?? "이동"} · ${movingInfo.distance ?? "거리 정보 없음"}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                if (movingInfo.duration != null)
                  Text('소요 시간: ${movingInfo.duration}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------
// 내비게이션 FAB 위젯 (_BuildNavigateFab)
// ---------------------------------------------------
class _BuildNavigateFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final route = Provider.of<RouteProvider>(context).currentRoute;
    if (route == null || route.places.isEmpty) return SizedBox.shrink();
    
    return FloatingActionButton.extended(
      onPressed: () async {
        // Get first place to navigate to
        final firstPlace = route.places.first;
        if (firstPlace.latitude == null || firstPlace.longitude == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('위치 정보가 없어 내비게이션을 시작할 수 없습니다.')),
          );
          return;
        }
        
        try {
          // For mobile devices
          if (!kIsWeb) {
            final availableMaps = await mapLauncher.MapLauncher.installedMaps;
            if (availableMaps.isNotEmpty) {
              await availableMaps.first.showMarker(
                coords: mapLauncher.Coords(firstPlace.latitude!, firstPlace.longitude!),
                title: firstPlace.name ?? '목적지',
              );
              return;
            }
          }
          
          // Fallback to web URL
          final url = 'https://www.google.com/maps/search/?api=1&query=${firstPlace.latitude},${firstPlace.longitude}';
          if (await canLaunch(url)) {
            await launch(url);
          } else {
            throw 'Could not launch maps';
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('내비게이션을 시작할 수 없습니다: $e')),
          );
        }
      },
      icon: Icon(Icons.navigation_outlined),
      label: Text('길찾기'),
    );
  }
}