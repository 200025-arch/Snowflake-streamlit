# Commandes sql utilisées & Explications

Dans cette partie, nous mettrons en avons ce que nous avons fait et pourquoi nous l'avons fait. Nos explications seront accompagnées soit d'images tirées de snoflake soit de bout de code.

## Création de la base de données "LinkedIn"

On a commencé par créer une base de données que l'on a nommé "LinkedIn", pour créer cette base nous avons utilisé la commande sql suivante :

CREATE OR REPLACE DATABASE linkedin;

La commande fait ceci ;
-crée une base de données appelée linkedin
-remplace la base si elle existe déjà (⚠️ cela supprime tout son contenu existant !).

USE DATABASE linkedin;
