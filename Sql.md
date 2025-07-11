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

## Format de fichiers (csv & json)

### Format csv

<img width="580" height="217" alt="Image" src="https://github.com/user-attachments/assets/c1a07b16-7551-46a6-bffc-45db1264be5e" />

Cette commande SQL permet de définir un format de fichier personnalisé pour lire ou écrire des fichiers CSV.

### Format json

<img width="460" height="62" alt="Image" src="https://github.com/user-attachments/assets/9ca2ca9b-ed0b-466f-a7d8-073fe4c3b0e2" />

Cette commande :

-Crée un format de fichier nommé json_format, ou le remplace s’il existe déjà.

-Indique que le format s’applique à des fichiers JSON.

## Création des tables

### Table créée à partir de fichiers csv

<img width="467" height="141" alt="Image" src="https://github.com/user-attachments/assets/06527b42-b112-4b67-be74-357e468e5c44" />

Pour créer les tables, nous avons utilisé la commande suivante :

CREATE OR REPLACE TABLE "nom de la table"(
"colonne1" string,
"Colonne2" integer,
etc
);

L'instruction "Create or replace" crée une table ou la remplace si elle existe déjà. Les instructions à l'intérieur de la table permettent de créer les colonnes et de donner des types à ces colonnes. Pour les tables créées à partir des données des fichiers csv, il est possibile de créer toutes les colonnes au moment de la création de la table.

### Table créée à partir de fichiers json

<img width="573" height="62" alt="Image" src="https://github.com/user-attachments/assets/bb8f8c9a-89ee-4017-8fad-a82b04895e46" />

L'instruction pour créer une table reste la même 'CREATE OR REPLACE TABLE "nom de la table"', la différence intervient au moment de la création des colonnes. En effet au moment de la création de la table, on peut créer une seule colonne de type "Variant".

CREATE OR REPLACE TABLE "nom de la table"(
"data" Variant,
);
