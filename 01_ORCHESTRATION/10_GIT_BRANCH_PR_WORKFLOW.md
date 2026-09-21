# Git — branches, commits et Pull Requests

## Statut

**Normatif avant le premier développement applicatif.**

## Branches

`main` est la branche d'intégration protégée.

Le développement applicatif se fait sur une branche dédiée :

```text
feat/<domaine>-<sujet>
fix/<domaine>-<sujet>
chore/<sujet>
docs/<sujet>
refactor/<sujet>
test/<sujet>
```

Exemples :

```text
feat/foundation-bootstrap
feat/identity-auth
feat/course-versioning
feat/enrollment
fix/submission-authorization
```

Une branche ne doit pas mélanger plusieurs décisions architecturales indépendantes.

## Pull Request

Toute modification applicative destinée à `main` passe par une Pull Request.

Une PR doit indiquer :

- mission(s) concernée(s) ;
- objectif ;
- références normatives ;
- résumé des changements ;
- tests exécutés ;
- migrations éventuelles ;
- impact sécurité ;
- impact API ;
- éventuels changements documentaires ;
- éventuels blockers.

## Protection de `main`

Après activation de la CI :

- les checks CI obligatoires doivent être verts ;
- aucune fusion ne doit contourner une Quality Gate rouge ;
- les changements architecturaux nécessitent la décision humaine prévue par `05_CHANGE_CONTROL.md`.

## Commits

Préférer des commits petits et logiques.

Format recommandé :

```text
feat: ...
fix: ...
chore: ...
docs: ...
test: ...
refactor: ...
```

Un commit ne doit pas servir à masquer un changement non documenté.

## Travail du stagiaire

Le stagiaire ne travaille pas directement sur `main`. Ses branches et PR sont soumises au même workflow et à la revue humaine définie par le projet.
