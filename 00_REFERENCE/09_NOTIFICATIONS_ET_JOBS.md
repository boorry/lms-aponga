# 09 — Notifications et traitement asynchrone — APONGA LMS

**Statut : normatif.** Ferme C-14 et C-20.

---

## 1. Principe

**Une action métier ne dépend jamais de la réussite d'une notification.** Si l'envoi d'un email échoue, l'Enrollment, la Submission ou le Feedback concerné reste néanmoins valide.

## 2. Comment l'événement n'est jamais perdu (C-20)

Publier un job directement dans Redis au milieu d'une requête HTTP crée un risque réel : si le processus s'arrête entre l'écriture en base et l'appel à Redis, l'événement est perdu silencieusement — l'analyse reçue ne précisait pas comment l'éviter. La réponse retenue est un **pattern outbox transactionnel** :

```text
Transaction métier (ex. création de Submission)
  ├── écriture de la donnée métier
  └── écriture d'une ligne dans domain_events   ← même transaction, donc atomique
        ↓
Worker séparé (polling léger ou LISTEN/NOTIFY PostgreSQL)
        ↓
Enfile un job BullMQ (Redis)
        ↓
Traitement du job → provider email/SMS
        ↓
retry avec backoff exponentiel → échec définitif après N tentatives → journalisé
```

`domain_events` est une table technique minimale :
```text
id UUID PK, event_type, payload JSONB, created_at, dispatched_at (nullable)
```
Elle garantit qu'aucun événement métier n'est perdu même en cas de crash entre l'écriture DB et l'enfilage du job — c'est la garantie que l'analyse critique demandait sans la nommer explicitement.

## 3. Événements V1

```text
UserRegistered
EnrollmentActivated
SubmissionSubmitted
FeedbackPublished
TeacherLoadThresholdExceeded
GuardianLinkActivated
GuardianLinkDeactivated
```

## 4. Table de suivi des envois

```text
notification_deliveries
  id, event_id, channel (email), recipient_user_id, template_code,
  status (QUEUED / SENT / FAILED), attempt_count, last_error, sent_at, created_at
```

## 5. Idempotence des jobs

Chaque job de notification est identifié de façon stable (par `event_id` + `channel` + `recipient_user_id`) pour qu'un rejouage (retry, redémarrage du worker) ne produise jamais d'envoi en double non maîtrisé — une contrainte d'unicité sur ce triplet dans `notification_deliveries` empêche une double insertion.

## 6. Ce que ce document ferme

| Point de l'analyse critique | Fermé par |
|---|---|
| C-14 — architecture d'exécution des notifications non définie | §1 à §5 |
| C-20 — garantie de non-perte de l'événement entre écriture DB et mise en file | §2 |
