// lib/screens/routes/route_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/place.dart';
import '../../providers/route_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/places/place_card.dart';

class RouteEditScreen extends StatefulWidget {
  @override
  _RouteEditScreenState createState() => _RouteEditScreenState();
}

class _RouteEditScreenState extends State<RouteEditScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Place> _searchResults = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults.clear();
        _isSearching = false;
      });
      return;
    }
    setState(() {
      _isSearching = true;
    });

    // TODO: 실제 API 호출로 교체
    await Future.delayed(Duration(milliseconds: 800));
    final dummyResults = [
      Place(
        id: 'dummy1',
        name: '$query 장소 1',
        address: '주소 1',
        type: '카페',
        rating: 4.0,
        ratingCount: 10,
        reviews: [],
        tags: [query],
        imageUrl: null,
        latitude: 37.5665,
        longitude: 126.9780,
      ),
      Place(
        id: 'dummy2',
        name: '$query 장소 2',
        address: '주소 2',
        type: '식당',
        rating: 4.5,
        ratingCount: 5,
        reviews: [],
        tags: [query],
        imageUrl: null,
        latitude: 37.5650,
        longitude: 126.9760,
      ),
    ];

    if (!mounted) return;
    setState(() {
      _searchResults = dummyResults
          .where((p) => p.name.contains(query) || p.tags.contains(query))
          .toList();
      _isSearching = false;
    });
  }

  Future<void> _saveRoute() async {
    setState(() => _isSaving = true);
    final routeProvider = Provider.of<RouteProvider>(context, listen: false);
    final currentRoute = routeProvider.currentRoute;
    if (currentRoute == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장할 경로 정보가 없습니다.')),
      );
      setState(() => _isSaving = false);
      return;
    }
    try {
      await routeProvider.updateRoute(currentRoute);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('경로가 저장되었습니다.')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final routeProvider = Provider.of<RouteProvider>(context);
    final route = routeProvider.currentRoute;

    if (route == null) {
      return Scaffold(
        appBar: AppBar(title: Text('경로 편집')),
        body: Center(child: Text('불러올 경로가 없습니다.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('경로 편집'),
        actions: [
          IconButton(
            icon: _isSaving
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(Icons.save),
            onPressed: _isSaving ? null : _saveRoute,
          ),
        ],
      ),
      body: Column(
        children: [
          // 검색 입력창
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '장소 검색',
                suffixIcon: _isSearching
                    ? Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () => _searchPlaces(_searchController.text),
                      ),
              ),
              onSubmitted: _searchPlaces,
            ),
          ),

          // 검색 결과가 있으면 리스트로, 아니면 경로 편집 리스트로
          Expanded(
            child: _searchResults.isNotEmpty
                ? ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (ctx, index) {
                      final place = _searchResults[index];
                      return PlaceCard(
                        place: place,
                        index: index + 1,
                        onTap: () {
                          routeProvider.addPlaceToRoute(place);
                        },
                      );
                    },
                  )
                : ReorderableListView.builder(
                    itemCount: route.places.length,
                    onReorder: (oldIndex, newIndex) {
                      routeProvider.reorderPlaces(oldIndex, newIndex);
                    },
                    itemBuilder: (ctx, index) {
                      final place = route.places[index];
                      return Dismissible(
                        key: ValueKey(place.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.redAccent,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          final result = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text('삭제 확인'),
                              content: Text('${place.name}을(를) 삭제하시겠습니까?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: Text('취소'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: Text('삭제'),
                                ),
                              ],
                            ),
                          );
                          return result ?? false;
                        },
                        onDismissed: (direction) async {
                          try {
                            await routeProvider.removePlaceFromRoute(place.id);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${place.name} 삭제됨')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('삭제 실패: $e')),
                              );
                            }
                          }
                        },
                        child: PlaceCard(
                          place: place,
                          index: index + 1,
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/place-detail',
                            arguments: place,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}