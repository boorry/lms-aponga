# 05 — Versionnement pédagogique — APONGA LMS

**Statut : normatif.** Ce document ferme définitivement C-01 et C-02.

---

## 1. Le principe en une phrase

**Les tables de travail (`courses`, `modules`, `lessons`, `resources`) représentent toujours le brouillon courant. La vérité figée, réellement consommée par un apprenant inscrit, est un instantané immuable stocké dans `course_versions.snapshot`.**

Ce n'est pas deux objets parallèles (« le brouillon » et « le publié ») : c'est une seule ligne `courses` qui évolue dans le temps, et un historique de photographies de cette ligne (et de son contenu) prises à chaque publication.

## 2. Ce qui se passe à chaque étape

### Édition (DRAFT / IN_REVIEW)
Le Content Author ou l'Academy Manager modifie librement `courses`, `modules`, `lessons`, `resources`. Ces modifications n'ont **aucun effet** sur les apprenants déjà inscrits : ils ne consultent jamais ces tables directement, mais l'instantané de la version qu'ils ont pinée à leur inscription.

### Publication (→ PUBLISHED)
En une seule transaction (voir `04_MACHINES_ETATS_ET_REGLES_METIER.md` §10) :
1. Un nouvel enregistrement `course_versions` est créé, avec `version_number = current_version_number + 1`.
2. Le `snapshot` JSONB capture : les métadonnées du Course, tous les Modules, toutes les Lessons (avec `is_required`, `requires_submission`, position), toutes les Resources qui leur sont rattachées (avec leurs métadonnées de lecture : type, durée, bpm, time_signature).
3. `courses.published_version_id` pointe vers ce nouvel enregistrement.
4. `courses.current_version_number` est incrémenté.
5. Le cours redevient visible dans le catalogue public et rouvre aux inscriptions (si `enrollment_open = true`).

### Retour en édition d'un cours déjà publié
Le Manager peut remettre `courses.status` à `IN_REVIEW` (ou `DRAFT`) pour préparer une nouvelle version. Effet immédiat :
- Le cours **disparaît du catalogue public** et devient fermé aux nouvelles inscriptions.
- **Aucun effet** sur les apprenants déjà inscrits, qui continuent de consulter le `course_versions.snapshot` qu'ils ont pinée — ce contenu ne change jamais, même si le brouillon en cours d'édition modifie ou supprime des leçons.
- Cette règle ferme explicitement C-18 (point identifié lors de cette révision) : il n'y a jamais d'ambiguïté entre « statut de la ligne Course » et « version réellement servie ».

## 3. Ce qu'un Enrollment pine réellement

Au moment de la création d'un Enrollment, `enrollments.course_version_id` est renseigné avec la version actuellement `PUBLISHED`. Cette référence ne change **jamais** pour cet Enrollment :

- Une nouvelle publication du cours ne modifie pas le parcours des apprenants déjà inscrits.
- Une Lesson supprimée, renommée ou déplacée dans une version ultérieure n'affecte pas un apprenant resté sur une version antérieure — elle existe encore, intacte, dans le `snapshot` qu'il consulte.
- `progress.course_version_id` reprend la même valeur que l'Enrollment associé, ce qui permet une vérification de cohérence directe (voir `04_MACHINES_ETATS_ET_REGLES_METIER.md` §9).
- Aucune migration automatique d'un apprenant vers une nouvelle version n'est prévue en V1 (choix assumé — voir `01_ANALYSE_CRITIQUE_ET_SUIVI.md` §4). Si un Academy Manager souhaite qu'un apprenant bénéficie du contenu mis à jour, il crée manuellement un nouvel Enrollment.

## 4. Ce qu'une Submission pine réellement

`submissions.course_version_id` et `submissions.lesson_id` enregistrent la version et la leçon exactes que l'apprenant consultait au moment de sa soumission. Un Teacher qui corrige une soumission ancienne voit toujours le contexte pédagogique tel qu'il était à ce moment, même si le cours a depuis évolué.

## 5. Suppression de contenu

Une entité (Module, Lesson, Resource) appartenant à une version déjà publiée n'est **jamais supprimée physiquement** tant qu'une version historique la référence dans son `snapshot` — le snapshot JSONB étant une copie autonome, la suppression de la ligne source (`lessons`, `resources`) dans le brouillon de travail n'affecte jamais un `course_versions.snapshot` déjà écrit. Les suppressions ne portent donc que sur le brouillon courant ; la publication suivante produit un nouveau snapshot qui, naturellement, ne contient plus l'élément supprimé.

## 6. `Activity` n'existe pas en V1

Le périmètre V1 s'arrête à :
```text
Course → Module → Lesson → Resource
```
`Activity`, mentionnée dans des versions antérieures de la conception, est explicitement retirée du V1 (C-02). Si un besoin réel de sous-unité pédagogique distincte de la Lesson apparaît plus tard, il fera l'objet d'un modèle dédié plutôt que d'une entité ajoutée a posteriori sans usage clair.

## 7. Ce que ce document ferme

| Point de l'analyse critique | Fermé par |
|---|---|
| C-01 — sémantique du versionnement après publication | §2, §3 |
| C-02 — contenu exact du snapshot, sort d'`Activity` | §2, §6 |
| C-10 (partie versionnement) — lien progression/version | §3 |
| C-18 — confusion statut de ligne / version servie | §2 |
