# Commandes sql utilisées & Explications

Dans cette partie, nous mettrons en avons ce que nous avons fait et pourquoi nous l'avons fait. Nos explications seront accompagnées soit d'images tirées de snoflake soit de bout de code.

## Création de la base de données "LinkedIn"

On a commencé par créer une base de données que l'on a nommé "LinkedIn", pour créer cette base nous avons utilisé la commande sql suivante :

CREATE OR REPLACE DATABASE linkedin;

<img width="718" height="180" alt="Image" src="https://github.com/user-attachments/assets/8911ee2b-ec8d-44da-97e2-fc5468bebd83" />

La commande fait ceci ;

-crée une base de données appelée linkedin

-remplace la base si elle existe déjà (⚠️ cela supprime tout son contenu existant !).

USE DATABASE linkedin;

Cette commande :

-indique que l'on veux travailler dans la base linkedin pour toutes les commandes SQL suivantes (création de tables, requêtes, etc.).

-Elle change le contexte actif vers cette base.

## Création du stage

Un "stage" dans Snowflake est comme une zone temporaire ou un point de passage où on peut stocker ou lire des fichiers (CSV, JSON, etc.) avant de les charger dans des tables. Pour créer ce stage, on a utilisé la commande suivante ;

CREATE OR REPLACE STAGE bucket_s3 URL = 's3://snowflake-lab-bucket/';

<img width="757" height="62" alt="Image" src="https://github.com/user-attachments/assets/482a7394-8207-4734-b6d1-13745a211886" />

## Format de fichier (csv & json)

### Format csv

Cette commande SQL permet de définir un format de fichier personnalisé pour lire ou écrire des fichiers CSV.

### Format json
