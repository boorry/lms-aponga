# 00 — Vision et périmètre — APONGA LMS

**Statut : conception métier fermée, inchangée par la présente révision technique.**

---

## 1. Qu'est-ce que le LMS APONGA ?

Une plateforme d'apprentissage en ligne pour la batterie et les percussions, avec un accompagnement humain (feedback vidéo/audio par un enseignant), intégrée au site existant **www.aponga.com**. Le LMS est un système **indépendant** : il ne gère ni l'école physique, ni la Drumline.

## 2. Quel problème résout-il ?

L'accès à une pédagogie musicale de qualité est limité par la disponibilité de professeurs qualifiés localement. Le LMS apporte une pédagogie structurée en ligne, avec un vrai retour personnalisé d'un enseignant.

## 3. Pour quels utilisateurs ?

| Rôle | Objectif |
|---|---|
| **Learner** (Apprenant) | Suivre les cours, soumettre ses pratiques, progresser |
| **Teacher** (Enseignant) | Corriger les soumissions des cours qui lui sont assignés |
| **Content Author** (Auteur de contenu) | Créer et structurer les cours (en brouillon) |
| **Academy Manager** (Gestionnaire d'Académie) | Publier les cours, assigner les enseignants, gérer les utilisateurs |
| **Administrator** (Administrateur) | Maintenir le système, configuration globale |
| **Guardian** (Tuteur) | Suivi en lecture seule d'un apprenant mineur de moins de 15 ans |

## 4. Quel est son périmètre ?

**Inclus** : catalogue, structure pédagogique (Course → Module → Lesson → Resource), diffusion de contenu, inscription et accès (sans paiement en V1), suivi de progression, soumission de pratique et feedback enseignant, administration, reporting basique.

**Exclu, de façon définitive** : gestion de l'école physique ou de la Drumline, application mobile native.

**Différé en V2** : paiement (abonnement, achat, Mobile Money, carte), certificats et badges.

## 5. Le choix le plus structurant : pas de paiement en V1

L'inscription à un cours est directe et gratuite en V1. L'architecture est conçue pour recevoir un module de paiement en V2 sans réécriture (voir `02_ARCHITECTURE_CONCEPTION.md` §6).

## 6. Quels sont ses modules ?

Identity, Learning Design, Content & Media, Enrollment, Learning Delivery, Assessment, Progression, Communication, Reporting, Administration, Localisation.

## 7. Quelle architecture ?

Un **monolithe modulaire**. Stack définitive : **Next.js (PWA) + NestJS + PostgreSQL + Cloudflare R2 + Cloudflare Stream + Redis**. Détail complet en `02_ARCHITECTURE_CONCEPTION.md`.

## 8. Langues au lancement

**Français et Anglais.**

## 9. Carte du dossier

Voir `README.md` pour la liste complète et l'ordre de lecture recommandé des seize documents qui composent ce dossier.
