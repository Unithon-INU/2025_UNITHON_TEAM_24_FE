import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 프로필'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.user;
          
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('로그인이 필요합니다'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: Text('로그인하기'),
                  ),
                ],
              ),
            );
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 프로필 이미지
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  backgroundImage: user.profileImageUrl != null
                      ? NetworkImage(user.profileImageUrl!)
                      : null,
                  child: user.profileImageUrl == null
                      ? Icon(
                          Icons.person,
                          size: 60,
                          color: Theme.of(context).primaryColor,
                        )
                      : null,
                ),
                SizedBox(height: 24),
                
                // 사용자 이름
                Text(
                  user.name ?? '이름 없음',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 8),
                
                // 이메일
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 32),
                
                // 구분선
                Divider(),
                SizedBox(height: 16),
                
                // 프로필 메뉴 항목들
                ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('프로필 편집'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    // 프로필 편집 화면으로 이동
                  },
                ),
                ListTile(
                  leading: Icon(Icons.map),
                  title: Text('내 여행 경로'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, '/routes');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('설정'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    // 설정 화면으로 이동
                  },
                ),
                ListTile(
                  leading: Icon(Icons.help_outline),
                  title: Text('도움말'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    // 도움말 화면으로 이동
                  },
                ),
                SizedBox(height: 16),
                Divider(),
                SizedBox(height: 24),
                
                // 로그아웃 버튼
                CustomButton(
                  text: '로그아웃',
                  icon: Icons.exit_to_app,
                  isLoading: authProvider.isLoading,
                  color: Colors.red,
                  onPressed: () async {
                    try {
                      await authProvider.logout();
                      Navigator.pushReplacementNamed(context, '/login');
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('로그아웃 실패: ${e.toString()}')),
                      );
                    }
                  },
                ),
                SizedBox(height: 8),
                
                // 계정 삭제 버튼
                TextButton(
                  onPressed: () {
                    // 계정 삭제 확인 다이얼로그 표시
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('계정 삭제'),
                        content: Text('정말로 계정을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                            },
                            child: Text('취소'),
                          ),
                          TextButton(
                            onPressed: () {
                              // 계정 삭제 로직 구현
                              Navigator.of(ctx).pop();
                            },
                            child: Text(
                              '삭제',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    '계정 삭제',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}