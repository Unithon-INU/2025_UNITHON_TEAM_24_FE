import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/preference_provider.dart';
import '../../providers/route_provider.dart';
import '../../widgets/preference/style_selector.dart';
import '../../widgets/preference/budget_slider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../models/preference.dart';

class PreferenceInputScreen extends StatefulWidget {
  @override
  _PreferenceInputScreenState createState() => _PreferenceInputScreenState();
}

class _PreferenceInputScreenState extends State<PreferenceInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _regionController = TextEditingController();
  final _specialRequestController = TextEditingController();

  String _selectedStyle = '문화탐방';
  String _selectedBudget = '중간';
  String _selectedCompanion = '혼자';
  String _selectedMobility = '3시간 이내';
  bool _isPublicTransport = true;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedPreference();
    });
  }

  @override
  void dispose() {
    _regionController.dispose();
    _specialRequestController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedPreference() async {
    final preferenceProvider = Provider.of<PreferenceProvider>(context, listen: false);
    final savedPreference = preferenceProvider.preference;

    if (savedPreference != null && mounted) { // mounted 확인 추가
      setState(() {
        _regionController.text = savedPreference.region;
        _selectedStyle = savedPreference.style;
        _selectedBudget = savedPreference.budget;
        _selectedCompanion = savedPreference.companion;
        _specialRequestController.text = savedPreference.specialRequest ?? '';
        _selectedMobility = savedPreference.mobilityLimit;
        _isPublicTransport = savedPreference.usePublicTransport;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('여행 선호도 입력')),
        body: LoadingIndicator(message: '경로를 생성 중입니다...'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('여행 선호도 입력'),
      ),
      body: Consumer2<PreferenceProvider, RouteProvider>(
        builder: (context, preferenceProvider, routeProvider, _) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(24.0),
              children: [
                // --- 폼 필드들 (이전과 동일) ---
                 Text('여행 정보를 입력해주세요', style: Theme.of(context).textTheme.headlineSmall),
                 SizedBox(height: 8),
                 Text('입력하신 정보에 맞춰 최적의 여행 경로를 추천해 드립니다.', style: Theme.of(context).textTheme.bodyMedium),
                 SizedBox(height: 32),
                 TextFormField(controller: _regionController, decoration: InputDecoration(labelText: '지역', hintText: '예: 서울 강남구', prefixIcon: Icon(Icons.location_on), border: OutlineInputBorder()), validator: (value) => value == null || value.isEmpty ? '지역을 입력해주세요' : null),
                 SizedBox(height: 24),
                 Text('여행 스타일', style: Theme.of(context).textTheme.titleMedium),
                 SizedBox(height: 8),
                 StyleSelector(options: ['문화탐방', '미식', '관광', '쇼핑', '휴양'], selectedOption: _selectedStyle, onChanged: (value) => setState(() => _selectedStyle = value)),
                 SizedBox(height: 24),
                 Text('예산', style: Theme.of(context).textTheme.titleMedium),
                 SizedBox(height: 8),
                 BudgetSlider(selectedBudget: _selectedBudget, onChanged: (value) => setState(() => _selectedBudget = value)),
                 SizedBox(height: 24),
                 Text('동반자', style: Theme.of(context).textTheme.titleMedium),
                 SizedBox(height: 8),
                 DropdownButtonFormField<String>(decoration: InputDecoration(prefixIcon: Icon(Icons.people), border: OutlineInputBorder()), value: _selectedCompanion, items: ['혼자', '가족', '친구', '연인', '단체'].map((label) => DropdownMenuItem(value: label, child: Text(label))).toList(), onChanged: (value) { if (value != null) setState(() => _selectedCompanion = value); }, validator: (value) => value == null ? '동반자를 선택해주세요.' : null),
                 SizedBox(height: 24),
                 Text('특별 요청 사항 (선택)', style: Theme.of(context).textTheme.titleMedium),
                 SizedBox(height: 8),
                 TextFormField(controller: _specialRequestController, decoration: InputDecoration(hintText: '예: 드라마 촬영지, 인플루언서 추천 맛집', prefixIcon: Icon(Icons.star_border), border: OutlineInputBorder()), maxLines: 2),
                 SizedBox(height: 24),
                 Text('이동 제한', style: Theme.of(context).textTheme.titleMedium),
                 SizedBox(height: 8),
                 DropdownButtonFormField<String>(decoration: InputDecoration(prefixIcon: Icon(Icons.timelapse), border: OutlineInputBorder()), value: _selectedMobility, items: ['1시간 이내', '2시간 이내', '3시간 이내', '제한 없음'].map((label) => DropdownMenuItem(value: label, child: Text(label))).toList(), onChanged: (value) { if (value != null) setState(() => _selectedMobility = value); }, validator: (value) => value == null ? '이동 제한을 선택해주세요.' : null),
                 SizedBox(height: 16),
                 SwitchListTile(title: Text('대중교통 우선'), subtitle: Text('대중교통을 우선적으로 이용한 경로를 추천합니다'), value: _isPublicTransport, onChanged: (value) => setState(() => _isPublicTransport = value), secondary: Icon(Icons.directions_bus), contentPadding: EdgeInsets.zero),
                 SizedBox(height: 32),
                // --- 폼 필드들 끝 ---

                // 경로 생성 버튼
                CustomButton(
                  text: '경로 생성하기',
                  icon: Icons.map,
                  isLoading: _isLoading,
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      return; // 폼 유효성 검사 실패 시 중단
                    }

                    // ** 중요: context를 사용하는 작업을 await 전에 처리 **
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context); // Navigator 상태도 미리 가져옴

                    setState(() { _isLoading = true; });

                    try {
                      await preferenceProvider.savePreference(
                        region: _regionController.text,
                        style: _selectedStyle,
                        budget: _selectedBudget,
                        companion: _selectedCompanion,
                        specialRequest: _specialRequestController.text.isNotEmpty
                            ? _specialRequestController.text
                            : null,
                        mobilityLimit: _selectedMobility,
                        usePublicTransport: _isPublicTransport,
                      );

                      final currentPreference = preferenceProvider.preference;
                      if (currentPreference == null) {
                        throw Exception("선호도 정보가 저장되지 않았습니다.");
                      }

                      await routeProvider.generateRouteWithPreference(currentPreference);
                      print(">>> Route generation finished. Current route ID: ${routeProvider.currentRoute?.id}");

                      // ** 중요: await 이후 context 대신 미리 저장한 navigator 사용 및 mounted 확인 **
                      if (!mounted) return; // 작업 완료 후 위젯이 unmount 되었다면 아무것도 하지 않음
                      navigator.pushNamed('/route-detail'); // Navigator 상태 사용

                    } catch (e) {
                      print("Error during preference save or route generation: $e");
                      // ** 중요: await 이후 context 대신 미리 저장한 scaffoldMessenger 사용 및 mounted 확인 **
                      if (!mounted) return;
                      scaffoldMessenger.showSnackBar( // ScaffoldMessenger 상태 사용
                        SnackBar(content: Text('오류 발생: ${e.toString()}')),
                      );
                    } finally {
                      // ** 중요: mounted 확인 **
                      if (mounted) {
                        setState(() { _isLoading = false; });
                      }
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}