// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth/social_login_buttons.dart'; // 소셜 로그인 버튼 위젯
import '../../widgets/common/loading_indicator.dart'; // 로딩 인디케이터

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    // 키보드 숨기기
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        await authProvider.loginWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        // 로그인 성공 시 홈 화면으로 이동 (AuthProvider의 notifyListeners에 의해 상태가 변경되어 main.dart에서 처리)
        if (mounted && authProvider.isAuthenticated) {
           print("Login successful, navigating to /home");
           // 모든 이전 라우트 제거하고 홈으로 이동
           Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('로그인 실패: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Stack( // 로딩 인디케이터를 위에 표시하기 위해 Stack 사용
        children: [
          GestureDetector( // 화면 다른 곳 탭 시 키보드 숨기기
             onTap: () => FocusScope.of(context).unfocus(),
             child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0), // 패딩 조정
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // 로고 또는 앱 이름
                      Text(
                        '여정', // TODO: 앱 이름 또는 로고 위젯으로 변경
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith( // 글꼴 크기 조정
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor, // 테마 색상 사용
                        ),
                      ),
                      SizedBox(height: 48), // 간격 조정

                      // 이메일 입력 필드
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: '이메일',
                          hintText: 'you@example.com',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next, // 다음 필드로 이동
                        validator: (value) {
                          if (value == null || value.isEmpty || !value.contains('@')) {
                            return '유효한 이메일을 입력해주세요.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // 비밀번호 입력 필드
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: '비밀번호',
                          hintText: '비밀번호 입력',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        obscureText: !_isPasswordVisible,
                        textInputAction: TextInputAction.done, // 입력 완료 액션
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '비밀번호를 입력해주세요.';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _submitLogin(), // 키보드에서 완료 시 로그인 시도
                      ),
                      SizedBox(height: 24),

                      // 로그인 버튼
                      ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _submitLogin, // 로딩 중 비활성화
                        child: Text('로그인'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold) // 버튼 텍스트 스타일
                        ),
                      ),
                      SizedBox(height: 16),

                      // 비밀번호 찾기 및 회원가입 링크
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/forgot-password');
                            },
                            child: Text('비밀번호 찾기'),
                          ),
                          Padding( // 구분선 (|) 스타일링
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('|', style: TextStyle(color: Colors.grey)),
                          ),
                          TextButton(
                            onPressed: () {
                               Navigator.pushNamed(context, '/signup');
                            },
                            child: Text('회원가입'),
                          ),
                        ],
                      ),

                      SizedBox(height: 32),
                      Row(
                        children: <Widget>[
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "또는",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      SizedBox(height: 24),

                      // 소셜 로그인 버튼 (Google)
                      SocialLoginButtons(),

                    ],
                  ),
                ),
              ),
                       ),
           ),
          // 로딩 인디케이터 표시
          if (authProvider.isLoading)
             LoadingIndicator(message: '로그인 중...'), // 메시지 수정
        ],
      ),
    );
  }
}