# 01 — Analyse critique et suivi de résolution — APONGA LMS

**Rôle de ce document** : présenter, de façon traçable, les points critiques identifiés dans la conception, et montrer où et comment chacun est désormais fermé. Il remplace 07_ANALYSE_CRITIQUE.md reçu séparément, dont le contenu a été entièrement traité.

---

## 1. Constat général

L'analyse reçue était juste : le dossier précédent fixait correctement les décisions **métier** (rôles, périmètre V1, Guardian, assignation enseignant) mais laissait plusieurs zones de **conception technique** ouvertes à interprétation — en particulier le versionnement pédagogique, le cycle de vie des médias, les règles précises de cycle de vie des soumissions, l'autorisation fine, le contrat API, la sécurité, l'asynchronisme, les tests et l'exploitation.

Cette révision ferme l'ensemble de ces points. Vingt-et-un points sont recensés ci-dessous : dix-sept proviennent de l'analyse reçue (C-01 à C-17), quatre ont été identifiés lors de la confrontation entre cette analyse, les décisions architecturales complémentaires reçues et la conception d'origine (C-18 à C-21).

## 2. Table de suivi

| ID | Point critique | Risque initial | Résolution | Document |
|---|---|---|---|---|
| C-01 | Sémantique du versionnement du Course après publication non définie | Critique | La version publiée (`course_versions`) est immuable ; la ligne `courses` peut repasser en édition sans modifier les versions historiques ; les tables de travail (`courses`, `modules`, `lessons`) représentent toujours le brouillon courant ; `course_versions.snapshot` est la vérité figée servie aux inscrits | `05_VERSIONNEMENT_PEDAGOGIQUE.md` |
| C-02 | Contenu réel du snapshot `course_versions` imprécis (Activity ? Resources ?) | Élevé | `Activity` retirée du périmètre V1 ; le snapshot contient Course + Modules + Lessons + Resources + ordre + `is_required` + `requires_submission` + `media_asset_id` | `05_VERSIONNEMENT_PEDAGOGIQUE.md` |
| C-03 | Cycle de vie des médias incomplet (état, type, taille, propriétaire, upload abandonné) | Critique | Table `media_assets` dédiée avec machine d'états complète, partagée par Resource/Submission/Feedback | `06_MEDIA_LIFECYCLE.md` |
| C-04 | Règles métier de la Submission incomplètes (cardinalité, resoumission, annulation, SLA) | Élevé | Cardinalité, resoumission et annulation tranchées explicitement | `04_MACHINES_ETATS_ET_REGLES_METIER.md` §2 |
| C-05 | Incohérence `PENDING` (traçabilité) vs états normatifs (architecture) | Moyen, révélateur | `PENDING` supprimé partout ; seuls les états normatifs sont utilisés, y compris dans les routes API | `04_MACHINES_ETATS_ET_REGLES_METIER.md`, `08_CONTRAT_API.md` |
| C-06 | Guardian : âge minimal, unicité, création et acceptation du lien non définis | Élevé | Règles complètes : Guardian ≥ 18 ans, distinct du mineur, lien créé uniquement par Manager/Admin, consentement capturé à la création (V1), révocation possible | `04_MACHINES_ETATS_ET_REGLES_METIER.md` §4 |
| C-07 | `birth_date` nullable dans le modèle alors que le backlog l'exige obligatoire | Moyen | `birth_date NOT NULL` pour tout compte Learner, aligné modèle/API/validation | `03_MODELE_DE_DONNEES.md` |
| C-08 | Contraintes relationnelles laissées à la seule couche applicative, sans classification | Élevé | Chaque règle classée explicitement : contrainte DB, policy d'autorisation, ou invariant de domaine vérifié en transaction | `04_MACHINES_ETATS_ET_REGLES_METIER.md` §10 |
| C-09 | Historisation des assignations Teacher↔Course insuffisante | Moyen | Ajout de `deactivated_at`/`deactivated_by`, unicité de l'assignation active, historique jamais supprimé | `03_MODELE_DE_DONNEES.md` |
| C-10 | Lien entre progression et contenu versionné non défini | Élevé | La Progress référence la même `course_version_id` que l'Enrollment ; une leçon supprimée d'une nouvelle version n'affecte jamais un inscrit déjà pinné sur l'ancienne version | `04_MACHINES_ETATS_ET_REGLES_METIER.md` §3, `05_VERSIONNEMENT_PEDAGOGIQUE.md` |
| C-11 | Règles de doublon et d'annulation d'Enrollment absentes | Élevé | Un seul Enrollment `ACTIVE` par Learner/Course (contrainte DB) ; réinscription après annulation = nouvel Enrollment ; fermeture des inscriptions n'affecte jamais les inscrits existants | `04_MACHINES_ETATS_ET_REGLES_METIER.md` §3 |
| C-12 | Calcul de `COMPLETED` insuffisamment spécifié | Élevé | `lessons.is_required` ajouté ; `COMPLETED` calculé sur les leçons obligatoires de la version pinée par l'Enrollment | `04_MACHINES_ETATS_ET_REGLES_METIER.md` §3 |
| C-13 | Cardinalité et édition du Feedback non définies | Élevé | Un Feedback actif maximum par Submission ; immuable après publication ; pas d'édition en V1 (limitation assumée, pas un oubli) | `04_MACHINES_ETATS_ET_REGLES_METIER.md` §5 |
| C-14 | Architecture d'exécution des notifications non définie | Moyen/Élevé | Redis + BullMQ, pattern outbox transactionnel, idempotence des jobs, table `notification_deliveries` | `09_NOTIFICATIONS_ET_JOBS.md` |
| C-15 | Sécurité et authentification insuffisamment spécifiées | Élevé | Modèle de tokens, politique de mot de passe, rate limiting, CORS/CSP, gestion des secrets, audit | `07_SECURITE_ET_AUTORISATION.md` |
| C-16 | API : exemples de routes, pas de contrat stable | Élevé | Conventions (pagination, tri, filtres, erreurs, idempotence), liste complète des endpoints, format d'erreur normalisé | `08_CONTRAT_API.md` |
| C-17 | Observabilité et exploitation non documentées | Élevé | Environnements, migrations, sauvegardes, logs, health checks, définis à un niveau adapté à une petite équipe | `11_DEPLOIEMENT_ET_EXPLOITATION.md` |
| C-18 *(identifié lors de cette révision)* | Confusion possible entre « statut de la ligne Course » et « version réellement servie » lorsqu'un cours publié repasse en édition | Élevé | Tranché explicitement : le cours redevient invisible du catalogue et fermé aux nouvelles inscriptions tant qu'il n'est pas republié ; les inscrits existants ne sont jamais affectés (principe de non-rétroactivité) | `05_VERSIONNEMENT_PEDAGOGIQUE.md` |
| C-19 *(identifié lors de cette révision)* | Le cycle de vie des médias de contenu (Resource, versionné) et des médias personnels (Submission/Feedback, éphémères) risquait d'être confondu dans une implémentation unique | Moyen | Table technique partagée (`media_assets`) mais cycles de vie et politiques de rétention documentés séparément selon le point d'attache | `06_MEDIA_LIFECYCLE.md` |
| C-20 *(identifié lors de cette révision)* | Aucune garantie que l'événement métier ne soit jamais perdu entre l'écriture en base et la mise en file d'attente de la notification | Moyen | Pattern outbox transactionnel : l'événement est écrit dans la même transaction que le changement métier ; un worker séparé l'enfile ensuite | `09_NOTIFICATIONS_ET_JOBS.md` |
| C-21 *(identifié lors de cette révision)* | Cardinalité exacte des Submissions actives et politique de resoumission non tranchées par les décisions reçues | Élevé | Une Submission active (`SUBMITTED`/`IN_REVIEW`) maximum par couple Learner/Lesson ; resoumission possible après feedback, en créant une nouvelle ligne (historique conservé) | `04_MACHINES_ETATS_ET_REGLES_METIER.md` §2 |

## 3. Documents manquants — décision

L'analyse reçue proposait dix documents complémentaires (`07` à `16` dans sa propre numérotation). Après confrontation avec ce qui était déjà fourni dans 08_DECISIONS_ARCHITECTURALES.md et 09_SPECIFICATIONS_TECHNIQUES_COMPLEMENTAIRES.md, la décision retenue est :

| Document proposé par l'analyse | Décision |
|---|---|
| Décisions architecturales | **Intégré** — son contenu est réparti dans `04`, `05`, `06`, `07` selon le sujet, plutôt que conservé comme document séparé, pour éviter une deuxième source de vérité sur les mêmes règles |
| Règles et états | **Produit** — `04_MACHINES_ETATS_ET_REGLES_METIER.md` |
| Contrat API | **Produit** — `08_CONTRAT_API.md` |
| Sécurité et autorisation | **Produit** — `07_SECURITE_ET_AUTORISATION.md` |
| Media lifecycle | **Produit** — `06_MEDIA_LIFECYCLE.md` |
| Versionnement pédagogique | **Produit** — `05_VERSIONNEMENT_PEDAGOGIQUE.md` |
| Notifications et jobs | **Produit** — `09_NOTIFICATIONS_ET_JOBS.md` |
| Stratégie de test | **Produit** — `10_STRATEGIE_DE_TEST.md` (réellement absent jusqu'ici, au-delà des critères de sortie déjà listés) |
| Déploiement et exploitation | **Produit** — `11_DEPLOIEMENT_ET_EXPLOITATION.md`, calibré pour une petite équipe (pas un dossier d'exploitation industrielle) |
| ERD | **Intégré** — inclus directement dans `03_MODELE_DE_DONNEES.md` plutôt qu'en document séparé, pour garder le schéma et son diagramme au même endroit |

Aucun document supplémentaire n'est nécessaire à ce stade pour permettre le démarrage du développement.

## 4. Ce qui reste un choix V1 assumé — pas un manque

Certains points, en apparence incomplets, sont des simplifications volontaires pour le V1. Ils sont listés ici pour éviter qu'un développeur les interprète comme des oublis à combler de sa propre initiative :

| Point | Choix V1 | Raison |
|---|---|---|
| Édition d'un Feedback publié | Non supportée | Cohérent avec l'immutabilité déjà retenue pour les versions de contenu ; une correction se traite hors système en V1 |
| Acceptation du lien Guardian | Pas de parcours de double opt-in en ligne | Le consentement est capturé administrativement à la création du lien par un Manager/Admin ; un parcours d'acceptation en ligne est une évolution V2 possible sans changement de schéma |
| Migration automatique d'un Enrollment vers une nouvelle version publiée | Non supportée | Un inscrit reste sur la version pinée à son inscription ; une migration se fait manuellement si nécessaire |
| Plusieurs pièces média par Submission | Non supportée (une seule) | Simplicité du V1 ; `media_assets` est conçue pour supporter plusieurs pièces en V2 sans migration de schéma |
| Plafond automatique d'inscriptions et liste d'attente | Non supportés (alerte + fermeture manuelle seulement) | Cohérent avec un volume de 4 enseignants ; à observer avant de construire un mécanisme plus complexe |
| Tests de contrat API automatisés contre OpenAPI | Recommandés mais non obligatoires en V1 | La revue manuelle du contrat (`08_CONTRAT_API.md`) suffit à ce stade d'équipe réduite |
