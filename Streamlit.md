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

<img width="888" height="330" alt="Image" src="https://github.com/user-attachments/assets/9843c685-4fa9-4bc8-94ef-ef509be51e88" />

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

<img width="1120" height="520" alt="Image" src="https://github.com/user-attachments/assets/4f0c8bef-4518-4cdf-9541-937112d26789" />

- else: st.warning("Aucune donnée salariale à afficher.")

  - Si df2 est vide (pas de résultats), Streamlit affiche un message d'avertissement jaune à l’utilisateur.

#### Troisième visualisation

👉 Afficher la Répartition des offres d’emploi par secteur d’activité.

##### Requête SQL :

<img width="842" height="258" alt="Image" src="https://github.com/user-attachments/assets/29ded7e0-94df-4dc0-af47-42c24780db26" />

- i.industry_name : sélectionne le nom du secteur d’activité (par ex. : "Finance", "Santé", "Technologie", etc.).

- COUNT(\*) AS nb_offres : compte le nombre d’offres d’emploi associées à chaque secteur.

- La colonne de résultat est nommée nb_offres.

- Les jointures permettent de relier :

  - jobs_postings_clean (jp) : la table principale contenant les offres d’emploi.

  - job_industries_clean (ji) : table de liaison qui connecte chaque offre à un ou plusieurs secteurs.

  - industries_csv (i) : table contenant la liste des secteurs avec leurs noms.

En clair :

On reconstitue la relation entre chaque offre et son secteur d’activité, pour pouvoir ensuite compter les offres par secteur.

- WHERE i.industry_name IS NOT NULL :

  - Élimine les cas où industry_name serait vide ou inconnu.

  - Permet de ne garder que les secteurs bien identifiés dans l’analyse.

- GROUP BY i.industry_name

  - Regroupe les résultats par nom de secteur pour pouvoir les compter (COUNT(\*)).

- ORDER BY nb_offres DESC

  - Trie les secteurs du plus grand nombre d’offres au plus petit, afin de visualiser les plus populaires en premier.

<img width="1002" height="511" alt="Image" src="https://github.com/user-attachments/assets/304b1310-553c-4c90-99bc-d18680184662" />

##### code streamlit

<img width="842" height="392" alt="Image" src="https://github.com/user-attachments/assets/67be80f7-d6a0-46af-9409-2caae616ef87" />

- df3 = run_query(query3)

- Exécute la requête SQL (query3) avec run_query() → récupère les résultats dans un DataFrame Pandas df3.

- st.dataframe(df3)

  - Affiche le tableau brut dans l'interface Streamlit avec st.dataframe(df3).

* if not df3.empty:

  - Vérifie que le DataFrame contient des données avant d’essayer de construire un graphique.

df3['nb_offres'] = pd.to_numeric(df3['NB_OFFRES'], errors='coerce')

df3['industry_name'] = df3['INDUSTRY_NAME'].astype(str)

- Convertit les noms de colonnes retournés par Snowflake (en majuscules) en noms adaptés pour Altair.

- Transforme NB_OFFRES en nombre (float) si ce n’est pas déjà le cas.

- Transforme INDUSTRY_NAME en chaîne de caractères (str) pour qu’Altair puisse l’utiliser comme nom de secteur.

* mark_arc(innerRadius=50)

  - Crée un diagramme en anneau (donut) au lieu d’un camembert plein

* theta=alt.Theta(...)

  - Détermine la taille de chaque part en fonction du nombre d’offres

* color=alt.Color(...)

  - Attribue une couleur différente à chaque secteur

* tooltip

  - Affiche les infos quand on survole une part du graphique

* .properties(width=..., height=...)

  - Définit la taille du graphique

* st.altair_chart(chart3)

  - Affiche le graphique Altair dans l’application Streamlit.

<img width="1127" height="622" alt="Image" src="https://github.com/user-attachments/assets/c71ea756-4a20-4ed6-8d8b-8baca1660ba3" />

- else: st.warning("Aucune donnée disponible pour la répartition.")

  - Affiche un message d’avertissement si le DataFrame est vide.

#### Quatrième visualisation

👉 Afficher la répartition des offres d’emploi par type d’emploi (temps plein, stage, temps partiel).

##### Requête SQL :

<img width="772" height="238" alt="Image" src="https://github.com/user-attachments/assets/0c521a43-fd98-4319-8c5c-017c01d42d44" />

- formatted_work_type : champ qui contient le type d’emploi formaté (ex : "Full-time", "Internship", "Contract"...).

- AS type_emploi : on renomme cette colonne pour l'affichage (en français) → ce sera plus clair dans le tableau ou graphique.

- COUNT(\*) AS nb_offres : on compte le nombre total d’offres par type.

* On utilise la table principale des offres d’emploi.

* Elle contient toutes les colonnes utiles : titre, localisation, salaire, type d’emploi, etc.

* On ne garde que les lignes où le type d’emploi est connu, ça évite d’avoir une catégorie "vide" dans le graphique.

* On regroupe les offres par type d’emploi. Cela permet de compter combien d’offres sont dans chaque catégorie.

* Trie les résultats du type d’emploi le plus représenté au moins représenté. Cela facilite la lecture du graphique (les plus fréquents sont en haut ou en premier).

<img width="987" height="370" alt="Image" src="https://github.com/user-attachments/assets/47ccce38-943c-42a4-ae92-12ba6faa0104" />

##### code streamlit

- La fonction run_query() exécute la requête query4 (celle que tu viens d’examiner).

- Le résultat est un DataFrame Pandas (df4) contenant :

  - TYPE_EMPLOI (ex : Full-time, Internship…)

  - NB_OFFRES (le nombre d’offres par type)

* Ce tableau est affiché directement dans Streamlit via st.dataframe(df4).

* On vérifie que df4 contient des données avant d’essayer d’afficher un graphique.

* NB_OFFRES → converti en nombre (float) pour pouvoir être utilisé dans Altair (:Q pour quantitatif).

* TYPE_EMPLOI → renommé en type_emploi et converti en texte (str).

* Nécessaire car Snowflake renvoie les colonnes en majuscules, et Altair ne gère pas bien les noms de colonnes en majuscules.

* total_offres = int(df4['nb_offres'].sum()) :

  - On calcule la somme de toutes les offres (nb_offres) pour afficher le total au centre du graphique.

* .mark_arc(innerRadius=100)

  - Crée un donut chart (graphique en anneau)

* theta

  - Contrôle la taille de chaque part, selon nb_offres

* color

  - Donne une couleur différente à chaque type d’emploi

* tooltip

  - Affiche infos au survol : type + nombre d’offres

* properties(...)

  - Définit la taille du graphique (600x500)

le texte affiche (mmettre image)

- Crée une chart Altair séparée avec du texte centré.

* Le texte affiche :

* st.altair_chart(chart4 + text) :

  - Additionne les deux graphiques Altair (chart4 + text) pour superposer :

    - Le donut en fond

    - Le texte total au centre

* else: st.warning("Aucune donnée disponible pour le type d’emploi.")

  - Affiche un message d’avertissement si le DataFrame est vide.
