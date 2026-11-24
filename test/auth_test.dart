import 'package:notiva/services/auth/auth_exceptions.dart';
import 'package:notiva/services/auth/auth_provider.dart';
import 'package:notiva/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();

    test('Should not be initialized to begin with', () {
      expect(provider.isInitialized, false);
    });

    test('Cannot log out if not initialized', () {
      expect(provider.logOut(), throwsA(const TypeMatcher<NotInitializedException>()));
    });

    test('Should be initialized', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test('User should be null after initialization', () {
      expect(provider.currentUser, null);
    });

    test('Should initialize in less than 2 seconds', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    }, timeout: const Timeout(Duration(seconds: 2)));

    test('Create user should delegate to logIn function', () async {
      final badEmailUser = provider.createUser(email: 'foo@bar.com', password: 'pass1234');
      await expectLater(badEmailUser, throwsA(const TypeMatcher<InvalidCredentialAuthException>()));
      final badPasswordUser = provider.createUser(email: 'testuser@example.com', password: 'foobar');
      await expectLater(badPasswordUser, throwsA(const TypeMatcher<InvalidCredentialAuthException>()));
      final user = await provider.createUser(email: 'testuser@example.com', password: 'pass1234');
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    test('Logged in user should be able to get verified', () async {
      await provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('Should be able to log out and log in again', () async {
      await provider.logOut();
      await provider.logIn(email: 'testuser@example.com', password: 'pass1234');
      final user = provider.currentUser;
      expect(user, isNotNull);
    });

    test('Password reset should fail for an invalid email', () async {
      await expectLater(
        provider.sendPasswordReset(toEmail: 'not-an-email'),
        throwsA(const TypeMatcher<InvalidEmailAuthException>()),
      );
    });

    test('Password reset should succeed for a valid email', () async {
      await expectLater(
        provider.sendPasswordReset(toEmail: 'testuser@example.com'),
        completes,
      );
    });
  });

  group('Delete account', () {
    final provider = MockAuthProvider();

    test('Cannot reauthenticate or delete account if not initialized', () async {
      await expectLater(
        provider.reauthenticate(password: 'pass1234'),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
      await expectLater(
        provider.deleteAccount(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });

    test('Cannot reauthenticate without a logged in user', () async {
      await provider.initialize();
      await expectLater(
        provider.reauthenticate(password: 'pass1234'),
        throwsA(const TypeMatcher<UserNotFoundAuthException>()),
      );
    });

    test('Reauthenticate should fail with a wrong password', () async {
      await provider.logIn(email: 'testuser@example.com', password: 'pass1234');
      await expectLater(
        provider.reauthenticate(password: 'foobar'),
        throwsA(const TypeMatcher<InvalidCredentialAuthException>()),
      );
      expect(provider.currentUser, isNotNull);
    });

    test('Deleting the account should clear the current user', () async {
      await provider.reauthenticate(password: 'pass1234');
      await provider.deleteAccount();
      expect(provider.currentUser, null);
    });
  });

  test('Cannot send password reset if not initialized', () async {
    final uninitializedProvider = MockAuthProvider();
    await expectLater(
      uninitializedProvider.sendPasswordReset(toEmail: 'testuser@example.com'),
      throwsA(const TypeMatcher<NotInitializedException>()),
    );
  });
}

class NotInitializedException implements Exception {}

class UserNotFoundAuthException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'foo@bar.com') throw InvalidCredentialAuthException();
    if (password == 'foobar') throw InvalidCredentialAuthException();
    const user = AuthUser(
      id: 'my_id',
      email: 'testuser@example.com',
      isEmailVerified: false,
    );
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(
      id: 'my_id',
      email: 'testuser@example.com',
      isEmailVerified: true,
    );
    _user = newUser;
  }

  @override
  Future<void> sendPasswordReset({required String toEmail}) async {
    if (!isInitialized) throw NotInitializedException();
    if (!toEmail.contains('@')) throw InvalidEmailAuthException();
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> reauthenticate({required String password}) async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    if (password == 'foobar') throw InvalidCredentialAuthException();
  }

  @override
  Future<void> deleteAccount() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    _user = null;
  }
}
