# Invariants de développement

La liste normative complète est dans `00_REFERENCE/04_MACHINES_ETATS_ET_REGLES_METIER.md` et `02_ARCHITECTURE_CONCEPTION.md`.

Au minimum, les tests doivent garantir :
- aucun accès Learning sans Enrollment ACTIVE ;
- Enrollment pinné sur une CourseVersion ;
- CourseVersion append-only ;
- publication atomique ;
- Course non publiable sans Teacher actif ;
- Teacher limité à ses cours assignés ;
- Guardian limité aux mineurs liés ;
- mineur <15 ans bloqué sans Guardian actif ;
- une Submission active max par Learner/Lesson ;
- Feedback publié au maximum un actif par Submission ;
- événement métier écrit dans la même transaction que l'action source ;
- Idempotency-Key sans doublon.
