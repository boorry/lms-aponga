# 06 — Cycle de vie des médias — APONGA LMS

**Statut : normatif.** Ferme définitivement C-03 et C-19.

---

## 1. Une table technique, deux logiques métier distinctes

Tous les fichiers (vidéo, audio, PDF, image) transitent par une seule table technique, `media_assets` (schéma complet en `03_MODELE_DE_DONNEES.md`), référencée depuis trois points d'attache :

| Point d'attache | Qui uploade | Logique métier | Rétention |
|---|---|---|---|
| `resources.media_asset_id` | Content Author | Contenu pédagogique, **versionné** via `course_versions.snapshot` | Permanente tant que référencée par une version publiée |
| `submissions.media_id` | Learner | Preuve de pratique, **personnelle et éphémère** | Limitée, par défaut 24 mois (`submissions.retention_expires_at`) |
| `feedbacks.response_media_id` | Teacher | Réponse personnelle, **éphémère** | Alignée sur celle de la Submission associée |

**C'est la distinction que l'analyse critique (C-19) signalait comme manquante** : une seule table technique ne veut pas dire une seule politique. Un développeur ne doit jamais appliquer la logique de rétention des Submissions à une Resource, ni l'inverse.

### Règle de routage provider *(ajoutée lors de l'audit final — absente jusqu'ici, voir `FINAL_AUDIT.md`)*

`media_assets.provider` n'est pas un choix libre à l'upload : il est déterminé uniquement par `resource_kind`.

| `resource_kind` | `provider` |
|---|---|
| `VIDEO` | `stream` (Cloudflare Stream) |
| `AUDIO` | `r2` |
| `PDF` | `r2` |
| `IMAGE` | `r2` |

Aucune vidéo n'est stockée sur R2 ; aucun autre type de fichier n'est envoyé à Cloudflare Stream, qui est un service spécialisé pour la vidéo. Le backend doit rejeter toute combinaison non conforme à ce tableau à la création du `media_asset` (`INITIATED`), pas seulement au moment de l'upload.

## 2. États

```text
INITIATED → UPLOADING → READY
INITIATED → UPLOADING → FAILED
READY → DELETED
```

| État | Signification |
|---|---|
| `INITIATED` | Une URL d'upload a été générée, aucun octet encore reçu |
| `UPLOADING` | Le client a commencé l'envoi vers R2/Stream |
| `READY` | L'upload est confirmé et vérifié côté backend |
| `FAILED` | Upload abandonné ou rejeté à la vérification |
| `DELETED` | Suppression effective (purge ou action explicite) |

Un `media_asset` en `INITIATED` ou `UPLOADING` depuis plus de 24h sans confirmation est considéré comme abandonné (nettoyage périodique, voir `11_DEPLOIEMENT_ET_EXPLOITATION.md`).

## 3. Flux d'upload

```text
Client
  ↓
POST /media/upload-url            (crée le media_asset en INITIATED, retourne une URL présignée)
  ↓
Upload direct vers R2 / Stream    (le backend n'est jamais traversé par le fichier)
  ↓
POST /media/{id}/complete
  ↓
Le backend considère l'upload comme `UPLOADING` puis vérifie : taille, type MIME, existence réelle de l'objet chez le provider,
                      état cohérent, propriétaire logique (owner_user_id = utilisateur courant)
  ↓
media_asset.status = READY  (ou FAILED si une vérification échoue). `complete` peut effectuer atomiquement `INITIATED → UPLOADING → READY/FAILED` si aucun événement intermédiaire `UPLOADING` n'a été reçu.
```

Ce flux est identique pour une Resource (Content Author), une Submission (Learner) et un Feedback (Teacher) — seul le point d'attache change une fois le `media_asset` prêt.

## 4. Accès à un média

```text
GET /lessons/{lessonId}/resources/{resourceId}/access
GET /submissions/{submissionId}/access
GET /feedbacks/{feedbackId}/access
```

Chaque endpoint retourne une URL temporaire (jamais une URL publique permanente), après vérification de l'autorisation objet correspondante (voir `07_SECURITE_ET_AUTORISATION.md`) :

| Type de fichier | Durée de vie de l'URL |
|---|---|
| Streaming vidéo | 1 heure |
| Téléchargement de fichier sensible (PDF, audio) | 15 à 30 minutes |

Ces durées, déjà actées, restent configurables sans changement de schéma (`settings`).

## 5. Suppression

- **Resources** : jamais supprimées tant qu'elles sont référencées par un `course_versions.snapshot` publié (voir `05_VERSIONNEMENT_PEDAGOGIQUE.md` §5). Une Resource retirée du brouillon courant reste intacte dans l'historique.
- **Submissions / Feedbacks** : purgées automatiquement à l'expiration de `retention_expires_at` — **le job de purge automatique n'est pas construit en V1** (choix assumé). Le champ existe pour permettre son ajout en V2 sans migration.
- **Uploads abandonnés** (`INITIATED`/`UPLOADING` > 24h) : nettoyage périodique, purge de l'objet chez le provider si présent.

## 6. Ce que ce document ferme

| Point de l'analyse critique | Fermé par |
|---|---|
| C-03 — cycle de vie des médias incomplet | §1 à §5 |
| C-19 — confusion entre médias de contenu et médias personnels | §1 |
