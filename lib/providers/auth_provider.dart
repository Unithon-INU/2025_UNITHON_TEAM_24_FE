// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException; // Firebase 예외만 import
import '../models/user.dart'; // User 모델
import '../services/auth_service.dart'; // AuthService
import '../services/storage_service.dart'; // StorageService

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final StorageService _storageService = StorageService(); // 인스턴스화

  User? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage; // UI 표시용 에러 메시지

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;

  AuthProvider(this._authService) {
    _initializeAuth(); // 앱 시작 시 인증 상태 초기화
  }

  // 앱 시작 시 인증 상태 확인 및 리스너 설정
  Future<void> _initializeAuth() async {
    print(">>> Initializing Authentication State...");
    _setLoading(true); // 초기 로딩 시작
    _authService.authStateChanges.listen(_onAuthStateChanged); // Firebase 상태 변경 리스너 시작
    // 초기 상태 확인 (리스너가 바로 호출되지 않을 수 있으므로)
    final initialUser = _authService.mapFirebaseUser(_authService.getCurrentFirebaseUser());
    await _updateUserAndSave(initialUser); // 초기 사용자 정보로 상태 업데이트
    print(">>> Auth Initialized. User: ${initialUser?.email ?? 'null'}");
    _setLoading(false); // 초기 로딩 완료
  }

  // Firebase Auth 상태 변경 리스너 콜백
  Future<void> _onAuthStateChanged(User? user) async {
    print(">>> Auth state changed via Listener. User: ${user?.email ?? 'null'}");
    // 로딩 상태가 아닐 때만 상태 업데이트 (로그인/로그아웃 액션과 중복 방지)
    if (!_isLoading) {
      await _updateUserAndSave(user); // 사용자 정보 업데이트 및 저장
      notifyListeners(); // UI 업데이트 알림
    }
  }


  void _setLoading(bool loading) {
    if (_isLoading != loading) { // 상태 변경 시에만 알림
      _isLoading = loading;
       _errorMessage = null; // 로딩 시작 시 이전 에러 메시지 초기화
      notifyListeners();
    }
  }

  void _setError(String? message) {
    _errorMessage = message;
  }

  // 사용자 설정 및 저장 로직 통합
  Future<void> _updateUserAndSave(User? user) async {
    _user = user;
    _isAuthenticated = user != null;
    if (user != null) {
      await _storageService.saveUser(user);
      // 백엔드 토큰이 있다면 여기서 저장 (AuthService에서 반환받거나 가져와야 함)
      // String? token = await _authService.getCurrentUserToken(); // 예시
      // if (token != null) await _storageService.saveToken(token);
    } else {
      await _storageService.deleteUser();
      await _storageService.deleteToken();
    }
     // notifyListeners(); // 상태 변경 후 마지막에 한 번만 호출하도록 변경
  }

  // --- 신규 메소드: 이메일/비밀번호 회원가입 ---
  Future<void> signUpWithEmailAndPassword(String email, String password, {String? name}) async {
    _setLoading(true);
    _setError(null);
    try {
      User newUser = await _authService.signUpWithEmail(email, password, name: name);
      await _updateUserAndSave(newUser); // 가입 성공 시 사용자 정보 업데이트 및 저장
      print(">>> Sign up successful: ${newUser.email}");
    } on FirebaseAuthException catch (e) { // Firebase 예외 명시적 처리
      _setError(_authService.firebaseErrorMsg(e.code)); // 서비스의 에러 메시지 변환 사용
      await _updateUserAndSave(null);
      print(">>> Sign up failed (Firebase): ${e.code}");
      rethrow;
    } catch (e) {
      _setError('회원가입 중 알 수 없는 오류가 발생했습니다.');
      await _updateUserAndSave(null);
      print(">>> Sign up failed (Unknown): $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // --- 신규 메소드: 이메일/비밀번호 로그인 ---
  Future<void> loginWithEmailAndPassword(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      User loggedInUser = await _authService.loginWithEmail(email, password);
      await _updateUserAndSave(loggedInUser); // 로그인 성공 시 사용자 정보 업데이트 및 저장
      print(">>> Login successful: ${loggedInUser.email}");
    } on FirebaseAuthException catch (e) {
      _setError(_authService.firebaseErrorMsg(e.code));
      await _updateUserAndSave(null);
      print(">>> Login failed (Firebase): ${e.code}");
      rethrow;
    } catch (e) {
      _setError('로그인 중 알 수 없는 오류가 발생했습니다.');
      await _updateUserAndSave(null);
      print(">>> Login failed (Unknown): $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // --- 신규 메소드: 비밀번호 재설정 이메일 발송 ---
  Future<void> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.sendPasswordResetEmail(email);
      print(">>> Password reset email sent to: $email");
      // 성공 피드백은 UI에서 직접 처리
    } on FirebaseAuthException catch (e) {
      _setError(_authService.firebaseErrorMsg(e.code));
      print(">>> Password reset email failed (Firebase): ${e.code}");
      rethrow;
    } catch (e) {
      _setError('비밀번호 재설정 메일 발송 중 오류가 발생했습니다.');
      print(">>> Password reset email failed (Unknown): $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // --- Google 로그인 메소드 (모바일용) ---
  Future<void> loginWithGoogle() async {
    _setLoading(true);
    _setError(null);
    try {
      User googleUser = await _authService.signInWithGoogle();
      await _updateUserAndSave(googleUser); // 성공 시 사용자 정보 업데이트 및 저장
      print(">>> Google login successful: ${googleUser.email}");
    } on FirebaseAuthException catch (e) {
      _setError(_authService.firebaseErrorMsg(e.code));
      await _updateUserAndSave(null);
      print(">>> Google login failed (Firebase): ${e.code}");
      // GoogleSignIn 자체 오류는 AuthService에서 Exception으로 변환하여 던짐
    } catch (e) {
      // GoogleSignIn 취소 등 AuthService에서 던진 예외 처리
      _setError('Google 로그인 실패: ${e.toString()}');
      await _updateUserAndSave(null);
      print(">>> Google login failed: $e");
    } finally {
      _setLoading(false);
    }
  }

  // --- 웹 Google 로그인 처리 메소드 (AuthProvider에는 유지, 웹 전용 코드에서 호출) ---
  Future<void> processGoogleToken(String idToken) async {
     // 웹 전용 기능이므로, 호출 자체가 웹에서만 이루어져야 함
    _setLoading(true);
    _setError(null);
    try {
      User googleUser = await _authService.handleGoogleIdToken(idToken); // AuthService에 해당 메소드 필요
      await _updateUserAndSave(googleUser); // 성공 시 업데이트 및 저장
       print(">>> Google ID Token processed successfully: ${googleUser.email}");
    } on FirebaseAuthException catch (e) {
       _setError(_authService.firebaseErrorMsg(e.code));
       await _updateUserAndSave(null);
       print(">>> Google ID Token processing failed (Firebase): ${e.code}");
       rethrow;
    } catch (e) {
       _setError('Google 로그인 처리 중 오류 발생: ${e.toString()}');
       await _updateUserAndSave(null);
       print(">>> Google ID Token processing failed (Unknown): $e");
       rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // --- 로그아웃 메소드 ---
  Future<void> logout() async {
    print(">>> Attempting logout...");
    _setLoading(true);
    _setError(null);
    try {
      await _authService.signOut(); // 내부적으로 Firebase, Google 로그아웃 처리
      // _onAuthStateChanged 리스너가 호출되어 _updateUserAndSave(null) 실행됨
      print(">>> Logout successful via AuthService.");
    } catch (e) {
      _setError('로그아웃 실패: ${e.toString()}');
      // 리스너가 실패 시 호출되지 않을 수 있으므로 명시적으로 null 처리
      await _updateUserAndSave(null);
      print(">>> Logout failed: $e");
    } finally {
      _setLoading(false);
    }
  }
}