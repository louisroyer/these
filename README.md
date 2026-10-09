# Architecture de contrôle pour l’intégration de l’edge computing dans les réseaux mobiles 5G

> Thèse présentée et soutenue le 10 juillet 2026 par Louis ROYER

## Résumé
L’*edge computing* consiste à traiter les données au plus près des utilisateurs afin de dépasser certaines limites des infrastructures fondées sur le *cloud computing*.
En rapprochant les ressources de calcul et de stockage, il permet de réduire la latence, d’améliorer la qualité d’expérience et de répondre aux besoins de nouveaux domaines d’applications tels que les villes intelligentes, l’agriculture connectée, les véhicules autonomes ou encore la réalité augmentée.

Alors que les opérateurs déploient d’ores et déjà à grande échelle des réseaux mobiles de cinquième génération (5G), ceux-ci ne sont paradoxalement que très peu ou pas intégrés à l’*edge computing*.
Malgré des efforts de standardisation, avec notamment l’architecture de *multi-access edge computing* (MEC) de l’ETSI, la plupart des projets de cœurs de réseau 5G *open-source* n’implémentent pas encore cette architecture.
De plus, les méthodes d’intégration proposées limitent à la fois le passage à l’échelle et la capacité de l’opérateur à apporter des garanties de qualité de service (QoS).

L’objectif de cette thèse est de proposer des solutions permettant l’intégration forte de l’*edge computing* dans les réseaux 5G.
Dans ce contexte, nous proposons SR4MEC, une architecture qui utilise le routage par segments pour diriger le trafic utilisateur vers des ressources *edge*.
Cette architecture repose sur SRv6 et sur l’abstraction *One Big UPF*, qui présente l’ensemble du plan de données comme une unique fonction UPF du point de vue du plan de contrôle 5G.
Elle reste ainsi compatible avec les mécanismes existants du cœur de réseau 5G.

SR4MEC permet à l’opérateur d’exprimer des politiques *edge* de haut niveau, associant une *slice* du réseau, une zone géographique et un service à une instance ou à un réseau *edge* cible.
Ces politiques sont traduites automatiquement en règles de routage SRv6 afin d’établir les chemins nécessaires dans le plan de données.
Cette approche sépare l’identifiant d’un service de celui de ses instances, rend la sélection d’instance transparente pour l’équipement utilisateur et réduit le nombre d’états et de messages de contrôle nécessaires pour établir, modifier ou migrer les chemins d’accès aux services.

Nous proposons ensuite des procédures permettant de prendre en compte la mobilité des utilisateurs dans cette architecture.
Elles s’intègrent aux mécanismes de *handover* des réseaux 5G et permettent soit de préserver l’instance *edge* déjà utilisée, soit de changer immédiatement d’instance lorsque la mobilité de l’utilisateur le justifie.

Enfin, nous présentons une plateforme d’expérimentation libre et *open-source* qui intègre une implémentation de SR4MEC, un contrôleur compatible avec un cœur de réseau 5G existant, ainsi que des passerelles et endpoints SRv6 permettant la redirection transparente du trafic utilisateur.
Les résultats obtenus montrent que SR4MEC permet d’accéder efficacement à des instances de service proches de l’utilisateur, aussi bien lors de l’établissement d’une session PDU que lors de changements dynamiques d’instance ou d’événements de mobilité. 

## Mots clés
5G ; Multi-Access Edge Computing ; Réseaux mobiles ; Redirection de trafic ; Gestion de ressources ; Routage par segments

## Jury
- Fabrice VALOIS (INSA Lyon) – Président
- Anne FLADENMULLER (Sorbonne Université) – Rapporteure
- Stefano SECCI (Cnam) – Rapporteur
- Damien SAUCEZ (Inria) – Examinateur

## Direction de thèse :
- Emmanuel CHAPUT (Institut National Polytechnique de Toulouse)
- Emmanuel LAVINAL (Université de Toulouse)

## École doctorale
EDMITT - Ecole Doctorale Mathématiques, Informatique et Télécommunications de Toulouse
Spécialité Informatique et Télécommunications

## Unité de recherche
IRIT : Institut de Recherche en Informatique de Toulouse


## Licence
Ce document est mis à disposition selon les termes de la licence CC BY-SA 4.0
