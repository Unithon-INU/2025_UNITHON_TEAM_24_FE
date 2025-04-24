import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api_config.dart';

class NetworkTestWidget extends StatefulWidget {
  @override
  _NetworkTestWidgetState createState() => _NetworkTestWidgetState();
}

class _NetworkTestWidgetState extends State<NetworkTestWidget> {
  String _result = '테스트 결과가 여기에 표시됩니다.';
  bool _isLoading = false;
  final TextEditingController _idController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('네트워크 테스트')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: '장소/경로 ID',
                hintText: '테스트할 ID를 입력하세요',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testPlaceApi,
                    child: Text('장소 API 테스트'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testRouteApi,
                    child: Text('경로 API 테스트'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testRootApi,
              child: Text('루트 API 테스트'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _isLoading 
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Text(_result),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _testPlaceApi() async {
    final id = _idController.text.trim();
    if (id.isEmpty) {
      setState(() => _result = '오류: ID를 입력해주세요.');
      return;
    }
    
    setState(() {
      _isLoading = true;
      _result = '요청 중...';
    });
    
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/places/$id');
      final response = await http.get(uri);
      
      setState(() {
        _isLoading = false;
        _result = '상태 코드: ${response.statusCode}\n\n'
                 '응답 헤더:\n${response.headers}\n\n'
                 '응답 본문:\n${_prettyJson(response.body)}';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _result = '오류 발생: $e';
      });
    }
  }
  
  Future<void> _testRouteApi() async {
    final id = _idController.text.trim();
    if (id.isEmpty) {
      setState(() => _result = '오류: ID를 입력해주세요.');
      return;
    }
    
    setState(() {
      _isLoading = true;
      _result = '요청 중...';
    });
    
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/routes/$id');
      final response = await http.get(uri);
      
      setState(() {
        _isLoading = false;
        _result = '상태 코드: ${response.statusCode}\n\n'
                 '응답 헤더:\n${response.headers}\n\n'
                 '응답 본문:\n${_prettyJson(response.body)}';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _result = '오류 발생: $e';
      });
    }
  }
  
  Future<void> _testRootApi() async {
    setState(() {
      _isLoading = true;
      _result = '요청 중...';
    });
    
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/');
      final response = await http.get(uri);
      
      setState(() {
        _isLoading = false;
        _result = '상태 코드: ${response.statusCode}\n\n'
                 '응답 헤더:\n${response.headers}\n\n'
                 '응답 본문:\n${_prettyJson(response.body)}';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _result = '오류 발생: $e';
      });
    }
  }
  
  String _prettyJson(String jsonString) {
    try {
      var jsonObject = json.decode(jsonString);
      var encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(jsonObject);
    } catch (e) {
      return jsonString;
    }
  }
}