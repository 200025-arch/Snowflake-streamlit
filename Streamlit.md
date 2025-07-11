# Code streamlit & visualisations

Dans cette partie, nous vous expliquerons le code que nous avons utilisé pour générer chacun de nos graphiques.

## Imports et configuration de base

#### Imports

<img width="663" height="150" alt="Image" src="https://github.com/user-attachments/assets/1ac5d507-1dfb-443f-8488-d22598cad863" />

Pourquoi réaliser ces imports ? :

- streamlit pour créer l’interface web.

- pandas pour la manipulation de tableaux (DataFrames).

- altair pour la création de graphiques.

- get_active_session → récupère la session Snowflake en cours (connexion déjà active).

#### configurations

<img width="867" height="152" alt="Image" src="https://github.com/user-attachments/assets/c2bd28b1-673f-404e-91a6-a3c67c8d2768" />

- Configure le titre de la page et la largeur de l’interface.

- Affiche le titre principal du tableau de bord.

## Connexion à Snowflake

<img width="393" height="77" alt="Image" src="https://github.com/user-attachments/assets/8df5f8b7-f2f0-4e1b-9c97-35725f167e46" />

- Récupère la session Snowflake actuelle (déjà authentifiée).

## Fonction utilitaire pour exécuter une requête

<img width="572" height="156" alt="Image" src="https://github.com/user-attachments/assets/f564a475-e368-4bff-ba87-1fe2963a9f02" />

- Prend une requête SQL en paramètre.

- L’exécute via Snowflake.

- Renvoie le résultat sous forme de DataFrame Pandas.

- Affiche une erreur si la requête échoue.

## Sélecteur d’analyse

<img width="781" height="227" alt="Image" src="https://github.com/user-attachments/assets/a498d8a5-4bc2-480f-b2a8-8f5dea938203" />

- Permet de choisir parmis une des visualisations

<img width="1087" height="445" alt="Image" src="https://github.com/user-attachments/assets/bb71ad93-7fb4-4221-ab33-6ca491f99a4b" />

## Les visualisations

👉 Afficher le top 10 des titres de postes les plus publiés par industrie.

##### Requête SQL :

<img width="732" height="303" alt="Image" src="https://github.com/user-attachments/assets/0bc3113d-87bb-455f-949c-8009531853f5" />

- i.industry_name : sélectionne le nom du secteur d’activité (par exemple : "Technologie", "Santé", etc.).

- COUNT(\*) AS nb_postes : compte le nombre total d’offres associées à chaque secteur, et renomme la colonne résultante en nb_postes.

* 3 tables sont jointes :

  - jobs_postings_clean contient les offres d’emploi (jp)

  - job_industries_clean est une table de liaison entre les offres et les secteurs (ji)

  - industries_csv contient la liste des secteurs (i)

* Jointures logiques :

  - jp.job_id = ji.job_id lie chaque offre à son/leurs secteur(s)

  - ji.industry_id = i.industry_id récupère le nom du secteur depuis l’identifiant

* WHERE i.industry_name IS NOT NULL :

  - Filtre les secteurs vides ou inconnus pour éviter les résultats incomplets.

* GROUP BY i.industry_name:

  - Regroupe toutes les offres par secteur d’activité afin de pouvoir compter combien de postes sont associés à chacun.

* ORDER BY nb_postes DESC:

  - Trie les secteurs du plus grand nombre de postes au plus petit.

<img width="1055" height="496" alt="Image" src="https://github.com/user-attachments/assets/683e66e5-25cd-4bce-8642-3d5fc3e543dc" />

##### code streamlit

<img width="897" height="473" alt="Image" src="https://github.com/user-attachments/assets/cb2aeb7b-242b-4b2d-988d-808a7860ce23" />

- st.code(query, language="sql"):

  - Affiche la requête SQL (query) dans une zone de code avec coloration syntaxique.

  - Permet à l’utilisateur de voir quelle requête est exécutée.

  - Utile pour la transparence et le debug.

- run_query(query) → exécute la requête SQL via la session Snowflake et récupère les données dans un DataFrame Pandas (df).

- st.dataframe(df) → affiche ces données dans un tableau interactif Streamlit (triable, scrollable).
