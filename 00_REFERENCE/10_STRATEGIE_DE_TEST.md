# 10 — Stratégie de test — APONGA LMS

**Statut : nouveau document, absent des versions précédentes.** Complète les critères de sortie déjà listés dans `README.md`.

---

## 1. Pyramide de test retenue

```text
        e2e (parcours critiques)          — peu nombreux, lents, réalistes
     contrat API (revue manuelle V1)      — contre 08_CONTRAT_API.md
  intégration (API + base de données)     — la majorité des tests
unitaire (règles métier, invariants)      — la base, rapides et nombreux
```

## 2. Outils

| Niveau | Outil |
|---|---|
| Unitaire / intégration | Jest (cohérent avec NestJS) |
| End-to-end | Playwright |
| Contrat API | Revue manuelle contre `08_CONTRAT_API.md` en V1 ; automatisation contre OpenAPI envisageable en V2 |

## 3. Ce qui doit obligatoirement être testé automatiquement

- **Chaque règle métier de `04_MACHINES_ETATS_ET_REGLES_METIER.md`**, y compris les transitions API explicites `DRAFT → IN_REVIEW`, `SUBMITTED → IN_REVIEW` et `DRAFT → PUBLISHED`. (transitions d'état autorisées et refusées, contraintes d'unicité, cardinalités).
- **Chaque permission et chaque règle d'autorisation objet de `07_SECURITE_ET_AUTORISATION.md`** — un test qui vérifie qu'un accès non autorisé est bien refusé, pas seulement qu'un accès autorisé fonctionne.
- **Chaque tâche marquée « Sensible » dans `13_BACKLOG_V1.md`.**
- **Le cycle de vie complet d'un média** (upload → complete → accès → expiration de l'URL signée).
- **L'idempotence** des opérations listées en `04_MACHINES_ETATS_ET_REGLES_METIER.md` §12 (rejouer la même requête avec la même `Idempotency-Key` ne doit pas produire d'effet en double).
- **La non-perte d'un événement métier** (`domain_events`) même en cas d'échec du worker de notification.

## 4. Parcours e2e obligatoires avant le pilote

| Parcours | Ce qu'il vérifie |
|---|---|
| Learner majeur : découverte → inscription → leçon → soumission → feedback | Le cycle complet fonctionne sans paiement |
| Learner mineur sans Guardian actif | Blocage systématique à l'inscription et à la soumission (INV-08) |
| Learner mineur avec Guardian actif | Parcours complet autorisé |
| Teacher : correction d'une soumission assignée | Feedback publié, notification déclenchée |
| Teacher : tentative d'accès à une soumission non assignée | Refus (403) |
| Guardian : consultation de la progression du mineur lié | Lecture seule stricte, aucune action d'écriture possible |
| Academy Manager : publication d'un cours sans enseignant assigné | Refus explicite (INV-02 révisé) |
| Academy Manager : republication après modification | Les inscrits existants ne voient aucun changement rétroactif |

## 5. Matrice de couverture des invariants

Chaque invariant listé en `02_ARCHITECTURE_CONCEPTION.md`, chaque règle listée en `04_MACHINES_ETATS_ET_REGLES_METIER.md`, doit avoir au moins un test automatisé qui **échoue si la règle est violée**. Cette matrice est tenue à jour dans `12_MATRICE_TRACEABILITE.md`, colonne « Test ».

## 6. Condition de recette

Aucune tâche P0 de `13_BACKLOG_V1.md` n'est considérée terminée sans : un test automatisé couvrant son critère d'acceptation, et pour les parcours critiques listés en §4, une validation manuelle en conditions réelles (voir `14_PLAN_VALIDATION.md`).


## 7. Tests d'authentification persistante

Les tests doivent vérifier :
- rotation et révocation individuelle des refresh tokens ;
- impossibilité de réutiliser un refresh token déjà utilisé ;
- expiration/révocation des tokens de vérification email ;
- expiration/usage unique des tokens de reset password ;
- aucun token persistant stocké en clair ;
- `email_verified_at` requis avant première connexion.
