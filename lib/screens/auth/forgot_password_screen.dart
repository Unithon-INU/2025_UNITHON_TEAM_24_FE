// lib/screens/auth/forgot_password_screen.dart (새 파일)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/loading_indicator.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitPasswordReset() async {
    // 키보드 숨기기
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        await authProvider.sendPasswordResetEmail(_emailController.text.trim());
        // 성공 메시지 표시 후 이전 화면으로 돌아가기
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('비밀번호 재설정 이메일을 발송했습니다. 이메일을 확인해주세요.'),
              backgroundColor: Colors.green, // 성공 피드백 색상
            ),
          );
          // 잠시 후 자동으로 이전 화면으로 돌아가기 (선택 사항)
          await Future.delayed(Duration(seconds: 1)); // 시간 단축
          if(mounted) Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('비밀번호 재설정 이메일 발송 실패: ${e.toString()}'),
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
        title: Text('비밀번호 찾기'),
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
                       SizedBox(height: 20),
                       Text(
                        '가입 시 사용한 이메일 주소를 입력하시면,\n비밀번호 재설정 링크를 보내드립니다.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium, // 글꼴 스타일 조정
                      ),
                      SizedBox(height: 32),
                      // 이메일
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: '이메일',
                          hintText: 'you@example.com',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty || !value.contains('@')) {
                            return '유효한 이메일을 입력해주세요.';
                          }
                          return null;
                        },
                         onFieldSubmitted: (_) => _submitPasswordReset(), // 완료 시 발송 시도
                      ),
                      SizedBox(height: 32),

                      // 재설정 링크 발송 버튼
                      ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _submitPasswordReset,
                        child: Text('재설정 링크 받기'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                        ),
                      ),
                       SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
                     ),
           ),
          // 로딩 인디케이터
          if (authProvider.isLoading)
            LoadingIndicator(message: '이메일 발송 중...'),
        ],
      ),
    );
  }
}