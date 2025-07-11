# Problèmes rencontrés & solutions apportées

### 1er problème

Le premier problème que nous avons rencontré c'était au niveau de l'affichage des table json. En effet, après avoir créé la table avec une colonne de type variant, on a essayé de l'afficher par l'intermédiaire d'une vue et allant chercher cahque colonne du fichers json comme ceci :

- data:company_name

Mais on avait pas les valeurs. La solution que l'on trouvé pour résoudre ce problème est "LATERAL FLATTEN", c'est pour cela que nous avons la syntaxe suivante :

<img width="1022" height="437" alt="Image" src="https://github.com/user-attachments/assets/4fb5c76f-609f-4fcf-81f5-63327b0a4b3d" />
