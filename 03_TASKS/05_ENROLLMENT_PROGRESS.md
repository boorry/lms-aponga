# Enrollment & Progress

Implémenter T-401, T-401b, T-402, T-403, T-404, ainsi que T-306, T-307, T-601 (listés explicitement plutôt qu'en plage numérique, pour éviter toute ambiguïté sur l'inclusion de T-401b).

## Acceptance
Inscription idempotente, Guardian check pour les mineurs, pin CourseVersion, réinscription par nouvel Enrollment (jamais de réactivation de l'ancien), progression, `time_spent_seconds` monotone et calcul COMPLETED conformes.
