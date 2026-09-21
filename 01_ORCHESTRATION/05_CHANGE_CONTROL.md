# Change Control

## Aucun changement architectural silencieux

Un changement est architectural s'il touche :
- stack ;
- modèle de données ;
- invariant ;
- machine d'état ;
- contrat API ;
- sécurité ;
- versionnement ;
- cycle média ;
- stratégie de déploiement.

Dans ce cas :
1. stopper l'implémentation dépendante ;
2. documenter le problème ;
3. proposer la modification minimale ;
4. mettre à jour la source de vérité ;
5. mettre à jour tests/backlog/traçabilité ;
6. seulement ensuite reprendre le développement.
