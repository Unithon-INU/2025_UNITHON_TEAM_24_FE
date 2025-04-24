import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/route_provider.dart';
import '../../widgets/places/place_card.dart';
import '../../widgets/common/loading_indicator.dart';

class PlaceListScreen extends StatefulWidget {
  @override
  _PlaceListScreenState createState() => _PlaceListScreenState();
}

class _PlaceListScreenState extends State<PlaceListScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = false;
  String _filterType = '전체';
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final routeProvider = Provider.of<RouteProvider>(context, listen: false);
      await routeProvider.fetchCurrentRoute();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('데이터를 불러오는데 실패했습니다: ${e.toString()}')),
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
        title: Text('장소 목록'),
      ),
      body: _isLoading
          ? LoadingIndicator()
          : Consumer<RouteProvider>(
              builder: (context, routeProvider, _) {
                if (routeProvider.currentRoute == null) {
                  return Center(child: Text('표시할 장소가 없습니다.'));
                }
                
                final allPlaces = routeProvider.currentRoute!.places;
                final filteredPlaces = allPlaces.where((place) {
                  if (tagProvider.selectedTags.isEmpty) return true;
                  return place.tags.any((tag) => tagProvider.selectedTags.contains(tag));
                }).toList();
                
                return Column(
                  children: [
                    // 검색 및 필터 영역
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: '장소 검색...',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() {
                                          _searchController.clear();
                                        });
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                          SizedBox(height: 16),
                          
                          // 장소 유형 필터
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterChip('전체'),
                                _buildFilterChip('관광지'),
                                _buildFilterChip('식당'),
                                _buildFilterChip('카페'),
                                _buildFilterChip('숙소'),
                                _buildFilterChip('쇼핑'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Divider(),
                    
                    // 장소 목록
                    Expanded(
                      child: filteredPlaces.isEmpty
                          ? Center(
                              child: Text('조건에 맞는 장소가 없습니다.'),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.all(16),
                              itemCount: filteredPlaces.length,
                              itemBuilder: (context, index) {
                                final place = filteredPlaces[index];
                                
                                // 검색어 필터링
                                if (_searchController.text.isNotEmpty &&
                                    !place.name.toLowerCase().contains(
                                        _searchController.text.toLowerCase()) &&
                                    !place.address.toLowerCase().contains(
                                        _searchController.text.toLowerCase())) {
                                  return SizedBox.shrink();
                                }
                                
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: PlaceCard(
                                    place: place,
                                    index: allPlaces.indexOf(place) + 1,
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/place-detail',
                                        arguments: place,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
    );
  }
  
  Widget _buildFilterChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: _filterType == label,
        onSelected: (selected) {
          setState(() {
            _filterType = selected ? label : '전체';
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
        checkmarkColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
