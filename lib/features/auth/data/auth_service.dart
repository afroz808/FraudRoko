import 'package:flutter/foundation.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fraudroko_app/core/analytics/analytics_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // ---------------------------------------------------------------------------
  // EMAIL / PASSWORD AUTHENTICATION
  // ---------------------------------------------------------------------------

  Future<UserCredential> signInWithEmail(String email, String password) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty || password.isEmpty) {
      throw FirebaseAuthException(
        code: 'invalid-input',
        message: 'Email and password are required.',
      );
    }

    // Warm up Firebase App Check before the authentication request. This keeps
    // the existing App Check protection enabled while avoiding a first-login
    // race where the auth request can be sent before an App Check token is
    // available. If App Check is not enforced, authentication can continue.
    try {
      final token = await FirebaseAppCheck.instance
          .getToken(false)
          .timeout(const Duration(seconds: 5));

      if (token == null || token.isEmpty) {
        await FirebaseAppCheck.instance
            .getToken(true)
            .timeout(const Duration(seconds: 5));
      }
    } catch (e) {
      // Do not turn an App Check warm-up failure into a generic login failure.
      // Firebase Auth remains the source of truth for authentication errors.
      debugPrint('EMAIL_LOGIN: App Check warm-up skipped: $e');
    }

    // Firebase authentication is the critical operation. Do not let analytics
    // delay or interfere with a successful login.
    final credential = await _auth
        .signInWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        )
        .timeout(const Duration(seconds: 15));

    // Analytics is best-effort only and runs after authentication succeeds.
    try {
      await AnalyticsService.instance
          .logLogin(method: 'email')
          .timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('EMAIL_LOGIN: Analytics skipped: $e');
    }

    debugPrint(
      'EMAIL_LOGIN: Firebase authentication successful for ${credential.user?.uid}',
    );
    return credential;
  }

  Future<UserCredential> createAccountWithEmail(
    String email,
    String password,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await AnalyticsService.instance.logSignUp(method: 'email');

    return credential;
  }

  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> reauthenticateWithEmail(String password) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No signed-in user found.',
      );
    }

    final email = user.email;

    if (email == null || email.isEmpty) {
      throw FirebaseAuthException(
        code: 'email-not-available',
        message: 'Account email is not available.',
      );
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    await user.reauthenticateWithCredential(credential);
  }

  // ---------------------------------------------------------------------------
  // GOOGLE SIGN-IN
  // ---------------------------------------------------------------------------

  Future<UserCredential?> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.instance;

    try {
      debugPrint('GOOGLE_LOGIN: Initializing Google Sign-In...');

      await googleSignIn.initialize(
        serverClientId:
            '860154648601-mo8n9be8h21d5ur6fitt5bnh4iaf9sc3.apps.googleusercontent.com',
      );

      debugPrint('GOOGLE_LOGIN: Initialization successful.');

      final account = await googleSignIn.authenticate();

      debugPrint('GOOGLE_LOGIN: Google account selected: ${account.email}');

      final googleAuth = account.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        debugPrint('GOOGLE_LOGIN_ERROR: ID token is NULL.');

        throw FirebaseAuthException(
          code: 'google-id-token-null',
          message: 'Google authentication token was not received.',
        );
      }

      debugPrint('GOOGLE_LOGIN: ID token received successfully.');

      final credential = GoogleAuthProvider.credential(idToken: idToken);

      debugPrint('GOOGLE_LOGIN: Firebase credential created successfully.');

      final userCredential = await _auth.signInWithCredential(credential);

      // Analytics is non-critical. Never block a successful login on analytics.
      try {
        await AnalyticsService.instance
            .logLogin(method: 'google')
            .timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint('GOOGLE_LOGIN: Analytics skipped: $e');
      }

      debugPrint('GOOGLE_LOGIN: Firebase authentication successful.');

      return userCredential;
    } on GoogleSignInException catch (e, st) {
      debugPrint('========================================');
      debugPrint('GOOGLE_SIGN_IN_EXCEPTION');
      debugPrint('CODE: ${e.code}');
      debugPrint('DESCRIPTION: ${e.description}');
      debugPrint('DETAILS: ${e.details}');
      debugPrint('========================================');

      debugPrintStack(stackTrace: st);

      rethrow;
    } on FirebaseAuthException catch (e, st) {
      debugPrint('========================================');
      debugPrint('FIREBASE_AUTH_EXCEPTION');
      debugPrint('CODE: ${e.code}');
      debugPrint('CODE: ${e.code}');
      debugPrint('========================================');

      debugPrintStack(stackTrace: st);

      rethrow;
    } catch (e, st) {
      debugPrint('========================================');
      debugPrint('GOOGLE_UNKNOWN_EXCEPTION');
      debugPrint('ERROR: $e');
      debugPrint('========================================');

      debugPrintStack(stackTrace: st);

      rethrow;
    }
  }

  Future<void> reauthenticateWithGoogle() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No signed-in user found.',
      );
    }

    final googleSignIn = GoogleSignIn.instance;

    await googleSignIn.initialize(
      serverClientId:
          '860154648601-mo8n9be8h21d5ur6fitt5bnh4iaf9sc3.apps.googleusercontent.com',
    );

    final account = await googleSignIn.authenticate();

    final idToken = account.authentication.idToken;

    if (idToken == null) {
      throw FirebaseAuthException(
        code: 'google-id-token-null',
        message: 'Google authentication token was not received.',
      );
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);

    await user.reauthenticateWithCredential(credential);
  }

  // ---------------------------------------------------------------------------
  // SIGN OUT
  // ---------------------------------------------------------------------------

  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      debugPrint('GOOGLE_SIGNOUT_ERROR: $e');
    }

    await _auth.signOut();
  }
}
