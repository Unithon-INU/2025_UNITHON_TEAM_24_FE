// lib/services/auth_service.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user.dart' as app_user; // User 모델 import 확인
import '../config/api_config.dart';  // ApiConfig import 추가
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final ApiService _apiService;
  final StorageService _storageService;
  final _authStateController = StreamController<bool>.broadcast();

  Stream<bool> get authStateStream => _authStateController.stream;

  AuthService({
    required ApiService apiService,
    required StorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService {
    // Listen to Firebase auth state changes
    _firebaseAuth.authStateChanges().listen(_handleAuthStateChange);
  }

  // Firebase 사용자(fb_auth.User)를 앱 모델(User)로 변환하는 헬퍼 함수
  app_user.User? mapFirebaseUser(fb_auth.User? firebaseUser) {
    if (firebaseUser == null) return null;
    return app_user.User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName,
      profileImageUrl: firebaseUser.photoURL,
      // --- 수정된 부분: User 모델의 createdAt이 DateTime? 이므로 직접 할당 가능 ---
      createdAt: firebaseUser.metadata.creationTime,
      // --- 수정 끝 ---
    );
  }

  // 로그인 상태 변경 스트림
  Stream<app_user.User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map(mapFirebaseUser);
  }

  // 현재 로그인된 Firebase 사용자 가져오기
  fb_auth.User? getCurrentFirebaseUser() {
    return _firebaseAuth.currentUser;
  }

  // 현재 Firebase 사용자의 ID 토큰 가져오기 (필요시)
  Future<String?> getCurrentUserToken() async {
     final user = _firebaseAuth.currentUser;
     return await user?.getIdToken();
  }

  Future<void> _handleAuthStateChange(fb_auth.User? user) async {
    if (user != null) {
      try {
        final token = await user.getIdToken();
        ApiConfig.setToken(token);  // 토큰 저장
        print('>>> Auth state changed via Listener. User: ${user.email}');
        
        // 사용자 데이터 저장
        final userData = app_user.User(
          id: user.uid,
          email: user.email ?? '',
          name: user.displayName,
          profileImageUrl: user.photoURL,
          createdAt: user.metadata.creationTime,
        );
        
        await _storageService.saveUser(userData);
        print('StorageService: User data saved.');
        _authStateController.add(true); // Emit true for signed-in state
      } catch (e) {
        print('Error in auth state change: $e');
      }
    } else {
      ApiConfig.setToken(null);  // 토큰 제거
      await _storageService.deleteUser();
      print('>>> Auth state changed: User signed out');
      _authStateController.add(false); // Emit false for signed-out state
    }
  }

  // --- 신규: 이메일/비밀번호 회원가입 ---
  Future<app_user.User> signUpWithEmail(String email, String password, {String? name}) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) throw Exception('Firebase user is null after sign up.');

      if (name != null && name.isNotEmpty && firebaseUser.displayName != name) {
         await firebaseUser.updateDisplayName(name);
         await firebaseUser.reload();
      }
       final updatedUser = _firebaseAuth.currentUser;
       final appUser = mapFirebaseUser(updatedUser);
       if(appUser == null) throw Exception('Failed to map Firebase user after update.');

       await _storageService.saveUser(appUser);
       return appUser;
    } on fb_auth.FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw Exception('회원가입 중 오류: $e');
    }
  }

  // --- 신규: 이메일/비밀번호 로그인 ---
  Future<app_user.User> loginWithEmail(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
       final appUser = mapFirebaseUser(userCredential.user);
       if(appUser == null) throw Exception('Failed to map Firebase user after login.');

       await _storageService.saveUser(appUser);
       return appUser;
    } on fb_auth.FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw Exception('로그인 중 오류: $e');
    }
  }

  // --- 신규: 비밀번호 재설정 이메일 ---
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on fb_auth.FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw Exception('비밀번호 재설정 메일 발송 오류: $e');
    }
  }

  // --- Google 로그인 (모바일) ---
  Future<app_user.User> signInWithGoogle() async {
    if (kIsWeb) throw UnimplementedError('Use Google Sign-In Button flow for web');

    GoogleSignInAccount? googleUser;
    try {
      googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google 로그인이 취소되었습니다.');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final fb_auth.AuthCredential credential = fb_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final appUser = mapFirebaseUser(userCredential.user);
      if(appUser == null) throw Exception('Failed to map Firebase user after Google sign in.');

      await _storageService.saveUser(appUser);
      return appUser;

    } on fb_auth.FirebaseAuthException catch (e) {
       if (googleUser != null && (e.code == 'user-cancelled' || e.code == 'cancelled')) {
           await _googleSignIn.signOut();
       }
      throw e;
    } catch (e) {
       if (googleUser != null) await _googleSignIn.signOut();
      if (e is Exception) throw e;
      throw Exception('Google 로그인 중 오류: $e');
    }
  }

   // --- 웹 Google ID 토큰 처리 ---
   Future<app_user.User> handleGoogleIdToken(String idToken) async {
     if (!kIsWeb) throw UnimplementedError('This method is for web only');
     try {
       final credential = fb_auth.GoogleAuthProvider.credential(idToken: idToken);
       final userCredential = await _firebaseAuth.signInWithCredential(credential);
       final appUser = mapFirebaseUser(userCredential.user);
       if(appUser == null) throw Exception('Failed to map Firebase user after Google ID token sign in.');

       await _storageService.saveUser(appUser);
       return appUser;

     } on fb_auth.FirebaseAuthException catch (e) {
       throw e;
     } catch (e) {
       throw Exception('Google 로그인 처리 오류: $e');
     }
   }

  // --- 로그아웃 ---
  Future<void> signOut() async {
    try {
      if (!kIsWeb && await _googleSignIn.isSignedIn()) {
           await _googleSignIn.signOut();
           print("AuthService: Google signed out (Mobile).");
      }
      await _firebaseAuth.signOut();
      print("AuthService: Firebase signed out.");
    } catch (e) {
      print('AuthService Error: Error during sign out: $e');
      await _storageService.deleteToken();
      await _storageService.deleteUser();
      throw Exception('로그아웃 중 오류: $e');
    }
  }

  // Firebase 오류 코드를 사용자 친화적 메시지로 변환
  String firebaseErrorMsg(String errorCode) {
    switch (errorCode) {
      case 'invalid-email': return '유효하지 않은 이메일 형식입니다.';
      case 'user-disabled': return '사용 중지된 계정입니다.';
      case 'user-not-found': return '존재하지 않는 사용자입니다.';
      case 'wrong-password': return '비밀번호가 올바르지 않습니다.';
      case 'email-already-in-use': return '이미 사용 중인 이메일입니다.';
      case 'operation-not-allowed': return '이메일/비밀번호 로그인이 비활성화되었습니다.';
      case 'weak-password': return '비밀번호가 너무 약합니다. (6자 이상)';
      case 'requires-recent-login': return '보안을 위해 최근 로그인이 필요합니다. 다시 로그인 후 시도해주세요.';
      case 'account-exists-with-different-credential': return '다른 로그인 방식으로 가입된 이메일입니다.';
      default: return '인증 오류가 발생했습니다 ($errorCode)';
    }
  }
}