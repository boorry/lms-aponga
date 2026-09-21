# Learning Design & Versioning

Références : architecture, états, versionnement, modèle, API.

Le passage `DRAFT → IN_REVIEW` est explicite et consomme `course.review`. `Content Author` ne peut ni revoir ni publier ; `Academy Manager`/`Administrator` peuvent revoir et publier.

Implémenter T-701, T-702, T-703, T-707, T-707b, T-708, T-709 (Course/Module/Lesson/Resource, assignations Teacher, revue `DRAFT → IN_REVIEW`, publication atomique, snapshots append-only, retour explicite `PUBLISHED → IN_REVIEW` et historique).

Implémenter également T-201, T-202, T-203 (endpoints `GET /courses`, `GET /courses/:id`, recherche) : ce sont les endpoints de lecture du même domaine, naturellement livrés avec le modèle qu'ils exposent plutôt que dans un fichier séparé. *(Rattachement ajouté lors de l'audit final — ces tâches n'étaient citées dans aucun fichier, voir `FINAL_AUDIT.md`.)* Le catalogue ne doit lister que les cours `PUBLISHED`.

## Acceptance
Un Enrollment existant ne voit jamais les modifications d'une version ultérieure. Publication impossible sans au moins un Teacher activement assigné (INV-02 révisé). Catalogue et fiche de cours fonctionnels, filtrage/recherche opérationnels.
