import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/features/lock/data/biometric_gate.dart';
import 'package:ecoleplus/features/lock/data/lock_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final lockServiceProvider = Provider<LockService>(
  (ref) => LockService(ref.watch(databaseProvider)),
);
final biometricGateProvider = Provider<BiometricGate>((ref) => LocalAuthGate());

/// Code enregistré sur ce téléphone (null : à créer).
final appLockProvider = StreamProvider<AppLockRow?>(
  (ref) => ref.watch(lockServiceProvider).watch(),
);

/// Vrai tant que l'application n'a pas été déverrouillée (au démarrage, et
/// après plus de 2 minutes en arrière-plan).
class LockedNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void lock() => state = true;
  void unlock() => state = false;
}

final lockedProvider = NotifierProvider<LockedNotifier, bool>(
  LockedNotifier.new,
);
