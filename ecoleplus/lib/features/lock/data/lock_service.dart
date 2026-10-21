import 'dart:isolate';

import 'package:drift/drift.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/features/auth/data/auth_api.dart';
import 'package:ecoleplus/features/lock/domain/pin.dart';

enum ResultatCode { ok, faux, attendre, motDePasseRequis }

class VerificationCode {
  const new(this.resultat, [this.attente = Duration.zero]);
  final ResultatCode resultat;
  final Duration attente;
}

/// Verrouillage de l'application : par code PIN OU par l'empreinte (au
/// choix, jamais les deux). Le code n'est jamais enregistré : seule son
/// empreinte cryptographique l'est.
class LockService {
  new(this.db, {this.iterations = 20000, DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase db;
  final int iterations;
  final DateTime Function() _now;

  Stream<AppLockRow?> watch() => db.select(db.appLock).watchSingleOrNull();
  Future<AppLockRow?> get() => db.select(db.appLock).getSingleOrNull();

  Future<void> definir(String pin) async {
    final erreur = validerPin(pin);
    if (erreur != null) throw UserMessage(erreur);
    final sel = nouveauSel();
    final n = iterations;
    final hash = await Isolate.run(() => empreintePin(pin, sel, n));
    await db
        .into(db.appLock)
        .insertOnConflictUpdate(
          AppLockCompanion.insert(
            id: const Value(1),
            pinHash: hash,
            pinSalt: sel,
            iterations: iterations,
            biometric: const Value(false),
            failedAttempts: const Value(0),
            blockedUntil: const Value(null),
          ),
        );
  }

  Future<VerificationCode> verifier(String pin) async {
    final lock = await get();
    if (lock == null) return const VerificationCode(ResultatCode.ok);
    if (lock.empreinteSeule) return const VerificationCode(ResultatCode.faux);
    if (attenteApresErreurs(lock.failedAttempts) == null) {
      return const VerificationCode(ResultatCode.motDePasseRequis);
    }
    final bloque = lock.blockedUntil == null
        ? null
        : DateTime.parse(lock.blockedUntil!);
    if (bloque != null && bloque.isAfter(_now())) {
      return VerificationCode(ResultatCode.attendre, bloque.difference(_now()));
    }
    final sel = lock.pinSalt;
    final n = lock.iterations;
    final hash = await Isolate.run(() => empreintePin(pin, sel, n));
    if (hash == lock.pinHash) {
      await _reinitialiserErreurs();
      return const VerificationCode(ResultatCode.ok);
    }
    final erreurs = lock.failedAttempts + 1;
    final attente = attenteApresErreurs(erreurs);
    await db
        .update(db.appLock)
        .write(
          AppLockCompanion(
            failedAttempts: Value(erreurs),
            blockedUntil: Value(
              attente == null || attente == Duration.zero
                  ? null
                  : _now().add(attente).toUtc().toIso8601String(),
            ),
          ),
        );
    if (attente == null) {
      return const VerificationCode(ResultatCode.motDePasseRequis);
    }
    return attente == Duration.zero
        ? const VerificationCode(ResultatCode.faux)
        : VerificationCode(ResultatCode.attendre, attente);
  }

  Future<void> reussiteBiometrie() => _reinitialiserErreurs();

  /// Ouverture par l'empreinte seule : aucun code EcolePlus (pin_hash vide).
  Future<void> definirEmpreinte() => db
      .into(db.appLock)
      .insertOnConflictUpdate(
        AppLockCompanion.insert(
          id: const Value(1),
          pinHash: '',
          pinSalt: '',
          iterations: 0,
          biometric: const Value(true),
          failedAttempts: const Value(0),
          blockedUntil: const Value(null),
        ),
      );

  /// Après reconnexion par mot de passe (code oublié) : nouveau code à choisir.
  Future<void> effacer() => db.delete(db.appLock).go();

  Future<void> _reinitialiserErreurs() => db
      .update(db.appLock)
      .write(
        const AppLockCompanion(
          failedAttempts: Value(0),
          blockedUntil: Value(null),
        ),
      );
}

extension MethodeOuverture on AppLockRow {
  /// Vrai si l'application s'ouvre avec l'empreinte (et non un code).
  bool get empreinteSeule => biometric && pinHash.isEmpty;
}
