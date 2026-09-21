# Audit Claude AI — 2026-09-20/21

Ce document archive la synthèse du premier audit du repository avant développement.

## Points AUD-01 à AUD-08

- AUD-01 : permissions `course.review`, `enrollment.read_all`, `submission.read_own` sans endpoint explicite.
- AUD-02 : registre unique des invariants incomplet ; sort de INV-03/04/05 non documenté.
- AUD-03 : versions exactes Node/TS/Nest sans procédure de blocage explicite.
- AUD-04 : `.gitignore` absent.
- AUD-05 : processus Claude AI → validation humaine → Claude Code non formalisé.
- AUD-06 : périmètre stagiaire non documenté.
- AUD-07 : absence de CI/CD.
- AUD-08 : convention branches/PR non formalisée.

## Décisions de la revue de verrouillage

AUD-01, AUD-02, AUD-03, AUD-04, AUD-05, AUD-07 et AUD-08 sont fermés par la revue du 21/09/2026.

AUD-06 est volontairement différé jusqu'à l'arrivée effective du stagiaire.

Les corrections supplémentaires sont détaillées dans `FINAL_AUDIT.md`.
