# Submission & Feedback

Implémenter explicitement T-501, T-503, T-504, T-505, T-506, T-507, T-508 et T-509.

`T-504` comprend la prise en charge explicite d'une Submission : `SUBMITTED → IN_REVIEW`. Une simple lecture ne change jamais l'état.

`T-505` crée/modifie un Feedback `DRAFT`. `T-506` le publie explicitement via `POST /feedbacks/:id/publish` et produit `FeedbackPublished` dans l'outbox.

Acceptance : soumission idempotente, Guardian check, Teacher filtering, prise en charge explicite, feedback publié immuable et événement de notification produit.
