# APONGA LMS — Development Orchestration Pack

**Statut : prêt pour le démarrage du développement avec Claude Code.**

Ce pack reprend les 17 documents de conception fournis comme **source de vérité** et ajoute la couche d'orchestration nécessaire au passage à l'implémentation.

## Règle fondamentale

Les documents de `00_REFERENCE/` sont la référence métier et architecture. Les fichiers d'orchestration indiquent **comment** les implémenter, pas **quoi inventer**.

Toute contradiction découverte pendant le développement doit être inscrite dans `07_TRACKING/BLOCKERS.md` et ne doit pas être résolue silencieusement par Claude Code.

## Entrée Claude Code

Lire dans cet ordre :
1. `CLAUDE.md`
2. `00_REFERENCE/README.md`
3. `00_REFERENCE/02_ARCHITECTURE_CONCEPTION.md`
4. `00_REFERENCE/03_MODELE_DE_DONNEES.md`
5. `00_REFERENCE/04_MACHINES_ETATS_ET_REGLES_METIER.md`
6. `00_REFERENCE/05_VERSIONNEMENT_PEDAGOGIQUE.md`
7. `00_REFERENCE/06_MEDIA_LIFECYCLE.md`
8. `00_REFERENCE/07_SECURITE_ET_AUTORISATION.md`
9. `00_REFERENCE/08_CONTRAT_API.md`
10. `00_REFERENCE/09_NOTIFICATIONS_ET_JOBS.md`
11. `00_REFERENCE/10_STRATEGIE_DE_TEST.md`
12. `00_REFERENCE/11_DEPLOIEMENT_ET_EXPLOITATION.md`
13. `00_REFERENCE/12_MATRICE_TRACEABILITE.md`
14. `00_REFERENCE/13_BACKLOG_V1.md`
15. `00_REFERENCE/14_PLAN_VALIDATION.md`
16. `00_REFERENCE/15_GLOSSAIRE_ET_FAQ.md`
17. `01_ORCHESTRATION/00_MASTER_ORCHESTRATION.md`

## Résumés opérationnels (`02_PROJECT/`)

*(section ajoutée lors de l'audit final : ce dossier existait mais n'était référencé nulle part — voir `FINAL_AUDIT.md`)*

`02_PROJECT/` contient des résumés courts et opérationnels (PRD, architecture, invariants, catalogue d'écrans, contrat écran/API, TODO) dérivés de `00_REFERENCE/`. Ils sont utiles pour un accès rapide pendant le développement, mais n'ont **aucune autorité propre** : en cas de divergence, `00_REFERENCE/` fait foi. Les tâches frontend (`03_TASKS/10` à `12`) s'appuient directement dessus.

## Validation de développement (`04_VALIDATION/`)

*(section ajoutée lors de l'audit final, même raison)*

`04_VALIDATION/` contient le plan de test opérationnel, la checklist de recette et le suivi de traçabilité de développement. Le fichier maître pour la traçabilité métier reste `00_REFERENCE/12_MATRICE_TRACEABILITE.md` ; `04_VALIDATION/TRACEABILITY_DEV.md` en est le suivi d'exécution. Utilisé par `03_TASKS/13_E2E_VALIDATION.md`.

## Démarrage environnement

Voir `09_ENVIRONMENT/ENVIRONMENT_SETUP.md` et les scripts de `08_SCRIPTS/`.

## Template frontend

Déposer le template fourni par le designer dans `05_FRONTEND/template-source/`. Ne jamais modifier directement le template original. Le code adapté et maintenu par le projet appartient à `05_FRONTEND/production-ui/`.
