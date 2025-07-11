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

#### Première visualisation

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

* if not df.empty:

  - Vérifie que df n’est pas vide avant d’essayer de construire un graphique.

* Les colonnes issues de Snowflake sont souvent en majuscules, on les renomme en minuscules pour compatibilité avec Altair.

  - pd.to_numeric() convertit les chaînes "123" en nombres 123, et met NaN si la conversion échoue.

  - astype(str) assure que industry_name est bien du texte, ce qui est requis pour l’axe Y du graphique.

* alt.Chart(df) → base du graphique à partir du DataFrame.

* .mark_bar() → crée un graphique en barres.

* .encode(...) → définit les axes et les options :

  - x='nb_postes:Q' → axe horizontal = nombre de postes (:Q = quantitatif)

  - y='industry_name:N' → axe vertical = nom du secteur (:N = nominal)

  - sort='-x' → trie les secteurs du plus grand au plus petit nombre de postes

  - color → chaque barre a une couleur différente

  - tooltip → affiche les valeurs au survol

* .properties(...) → définit la taille du graphique.

* st.altair_chart(chart):

  - Affiche le graphique dans l’interface Streamlit.

<img width="1286" height="518" alt="Image" src="https://github.com/user-attachments/assets/42668383-8e87-4b40-a58d-89dd74599f86" />

- else: st.warning("Aucune donnée à afficher.")

  - Si df est vide, Streamlit affiche un message jaune pour prévenir l’utilisateur.

#### Deuxième visualisation

👉 Afficher le top 10 des postes les mieux rémunérés par industrie.

##### Requête SQL :

<img width="871" height="366" alt="Image" src="https://github.com/user-attachments/assets/414bfc27-27c6-445a-bfb2-e33cdaf22df3" />

Sous-requête interne

- 📄 jobs_postings_clean (jp) : table principale contenant les offres d’emploi.

- 🔗 job_industries_clean (ji) : table de liaison entre offres et secteurs.

- 📊 industries_csv (i) : table contenant le nom des secteurs.

- Clauses importantes :

  - jp.job_id = ji.job_id → associe les offres à leur(s) secteur(s)

  - ji.industry_id = i.industry_id → récupère le nom du secteur

  - TRY_TO_DOUBLE(jp.max_salary) → convertit les salaires en valeur numérique (car souvent stockés sous forme de texte ou chaîne).

  - WHERE ... IS NOT NULL → on exclut les secteurs et les salaires vides.

Le résultat : une table temporaire avec les colonnes.

Agrégation de la sous-requête :

- SELECT industry_name, MAX(max_salary) AS salaire_max :

  - Pour chaque industry_name, on calcule le salaire le plus élevé trouvé dans les offres correspondantes.

  - MAX() retourne le plus grand salaire par secteur.

Groupement et tri :

- GROUP BY industry_name
  ORDER BY salaire_max DESC
  LIMIT 10

  - GROUP BY : regroupe les lignes par secteur (industry_name).

  - ORDER BY salaire_max DESC : trie du salaire le plus élevé au plus bas.

  - LIMIT 10 : garde les 10 meilleurs secteurs.

Pourquoi avoir utilisé une sous requête ? :

- Parce que dans jobs_postings_clean, les salaires sont souvent stockés sous forme de texte → il faut d’abord les convertir (TRY_TO_DOUBLE) avant d’utiliser MAX().

- Il est plus clair et sûr de faire la conversion dans la sous-requête, puis d’agréger proprement dans la requête principale.

<img width="1016" height="487" alt="Image" src="https://github.com/user-attachments/assets/8815697e-1967-43d3-a1de-dc179a8f3420" />

##### code streamlit

- Vérifie que le DataFrame df2 contient bien des données.

- Si df2 est vide (ex. si la requête SQL n’a rien retourné), le bloc suivant est ignoré.

- SALAIRE_MAX → converti en valeur numérique (float). S’il y a une erreur (ex: texte), on remplace par NaN.

- INDUSTRY_NAME → converti en chaîne (str) pour être utilisable comme label dans le graphique.

- Cela adapte les noms de colonnes retournées en majuscules par Snowflake.

- alt.Chart(df2)

  - Base du graphique (à partir des données df2)

- .mark_circle(size=200)

  - Affiche des cercles de taille fixe (200)

- x='salaire_max:Q'

  - Axe horizontal = montant du salaire max (:Q pour quantitatif)

- y='industry_name:N'

  - Axe vertical = nom du secteur (:N pour nominal)

- sort='-x'

  - Trie les secteurs du plus haut salaire vers le plus bas

- color=industry_name

  - Chaque secteur a une couleur différente

- tooltip=[...]

  - Quand on survole une bulle, on voit les infos du secteur et du salaire

- .properties(width=700, height=400)

  - Taille du graphique

* st.altair_chart(chart2)

  - Affiche le graphique interactif dans l'application Streamlit.

* else: st.warning("Aucune donnée salariale à afficher.")

  - Si df2 est vide (pas de résultats), Streamlit affiche un message d'avertissement jaune à l’utilisateur.
