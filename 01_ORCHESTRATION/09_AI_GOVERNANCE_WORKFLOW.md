# Gouvernance du développement assisté par IA

## Statut

**Normatif.** Ce document définit la séparation des responsabilités entre Claude AI, le responsable humain et Claude Code.

## 1. Principe

Claude Code n'est pas l'agent qui décide de l'architecture APONGA.

Avant toute mission d'implémentation significative, le dépôt réel doit avoir été analysé par Claude AI ou par un processus humain équivalent, les décisions nécessaires doivent avoir été validées par le responsable du projet, puis une mission explicite doit être remise à Claude Code.

## 2. Chaîne obligatoire

```text
Dépôt Git réel
      ↓
Claude AI — analyse / audit / conception
      ↓
Décisions proposées
      ↓
Responsable humain — validation
      ↓
Mission Claude Code figée
      ↓
Claude Code — analyse locale
      ↓
proposition d'implémentation
      ↓
validation humaine si changement sensible
      ↓
implémentation + tests
      ↓
review
      ↓
commit / PR
```

## 3. Responsabilités

### Claude AI

- analyser le dépôt et les documents existants ;
- identifier contradictions, dépendances et risques ;
- proposer des corrections et des décisions ;
- préparer les missions Claude Code ;
- ne pas décider seul d'une modification métier ou architecturale.

### Responsable humain

- valider ou refuser les décisions métier et architecturales ;
- arbitrer les changements de périmètre ;
- valider les changements de sécurité, API, données, stack et invariants ;
- décider de la fusion des changements importants.

### Claude Code

- travailler dans le repository local ;
- lire les références avant modification ;
- implémenter uniquement la mission validée ;
- tester et documenter ;
- arrêter et signaler toute contradiction non couverte par la mission.

## 4. Conditions de démarrage d'une mission

Une mission ne peut commencer que si :

1. son identifiant est défini ;
2. ses références normatives sont connues ;
3. ses dépendances sont satisfaites ;
4. les décisions nécessaires sont tranchées ;
5. son périmètre est explicite ;
6. ses critères d'acceptation sont vérifiables.

Une mission dont une décision architecturale est encore ouverte est **BLOCKED**, sauf décision humaine explicite de la traiter malgré ce point.

## 5. Archivage

Chaque audit externe ou interne important doit être résumé dans :

`07_TRACKING/AUDIT_LOG.md`

Les décisions issues de l'audit sont consignées dans :

`07_TRACKING/DECISIONS_DEV.md`

Les points non résolus sont consignés dans :

`07_TRACKING/BLOCKERS.md`.

## 6. Règle anti-interprétation

Claude Code ne doit pas « choisir la meilleure option » lorsqu'une décision touche :

- métier ;
- invariant ;
- état ;
- contrat API ;
- permission ;
- modèle de données ;
- sécurité ;
- stack ;
- déploiement.

Il doit STOPPER, documenter et demander la décision prévue par `05_CHANGE_CONTROL.md`.
