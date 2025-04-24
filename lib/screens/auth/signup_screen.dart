// lib/screens/auth/signup_screen.dart (새 파일)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/loading_indicator.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  // final _nameController = TextEditingController(); // 이름 필드 필요시 주석 해제
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    // _nameController.dispose(); // 이름 필드 필요시 주석 해제
    super.dispose();
  }

  Future<void> _submitSignup() async {
     // 키보드 숨기기
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        await authProvider.signUpWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          // name: _nameController.text.trim(), // 이름 필드 사용 시 주석 해제
        );
        // 회원가입 성공 시 처리
        if (mounted && authProvider.isAuthenticated) {
           print("Signup successful, navigating to /home");
           // 모든 이전 라우트 제거하고 홈으로 이동
           Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        } else if (mounted) {
          // 성공했지만 바로 로그인되지 않는 경우 (이메일 인증 필요 등)
          print("Signup successful, returning to previous screen.");
           // 현재 화면 닫기 (로그인 화면으로 돌아감)
           Navigator.pop(context);
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('회원가입 성공! 로그인해주세요.')), // 또는 이메일 확인 안내
           );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('회원가입 실패: ${e.toString()}'),
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
      appBar: AppBar(
        title: Text('회원가입'),
      ),
      body: Stack(
        children: [
          GestureDetector( // 화면 다른 곳 탭 시 키보드 숨기기
             onTap: () => FocusScope.of(context).unfocus(),
             child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                       SizedBox(height: 20), // 상단 여백
                      // 이름 필드 (필요시 주석 해제)
                      // TextFormField(
                      //   controller: _nameController,
                      //   decoration: InputDecoration(
                      //     labelText: '이름 (닉네임)',
                      //     prefixIcon: Icon(Icons.person_outline),
                      //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                      //   ),
                      //   textInputAction: TextInputAction.next,
                      //   validator: (value) {
                      //     if (value == null || value.isEmpty) {
                      //       return '이름을 입력해주세요.';
                      //     }
                      //     return null;
                      //   },
                      // ),
                      // SizedBox(height: 16),

                      // 이메일
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: '이메일',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty || !value.contains('@')) {
                            return '유효한 이메일을 입력해주세요.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // 비밀번호
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: '비밀번호',
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
                          helperText: '6자 이상 입력해주세요.', // 안내 문구 추가
                        ),
                        obscureText: !_isPasswordVisible,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty || value.length < 6) {
                            return '6자 이상의 비밀번호를 입력해주세요.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // 비밀번호 확인
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: '비밀번호 확인',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                        obscureText: !_isConfirmPasswordVisible,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '비밀번호를 다시 입력해주세요.';
                          }
                          if (value != _passwordController.text) {
                            return '비밀번호가 일치하지 않습니다.';
                          }
                          return null;
                        },
                         onFieldSubmitted: (_) => _submitSignup(), // 완료 시 가입 시도
                      ),
                      SizedBox(height: 32),

                      // 회원가입 버튼
                      ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _submitSignup,
                        child: Text('가입하기'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                        ),
                      ),
                      SizedBox(height: 20), // 하단 여백
                    ],
                  ),
                ),
              ),
                     ),
           ),
           // 로딩 인디케이터
           if (authProvider.isLoading)
             LoadingIndicator(message: '가입 처리 중...'),
        ],
      ),
    );
  }
}