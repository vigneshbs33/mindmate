import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> canCheck() async => _auth.canCheckBiometrics;

  Future<bool> authenticate() async {
    final can = await _auth.isDeviceSupported();
    if (!can) return false;
    return _auth.authenticate(
      localizedReason: 'Unlock MindMate',
      options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
    );
  }
}


