# Notifications & Jobs

Références : `09_NOTIFICATIONS_ET_JOBS.md`.

Implémenter T-801, T-802, T-803 : table `domain_events` avec écriture transactionnelle, worker d'enfilage BullMQ et envoi email, idempotence des jobs de notification. Ajouter également le nettoyage périodique des `notification_deliveries` en échec définitif.

## Acceptance
Aucune perte d'événement si le worker est indisponible. Rejouer un job ne produit jamais d'envoi en double.
