# Problèmes rencontrés & solutions apportées

### 1er problème

Le premier problème que nous avons rencontré c'était au niveau de l'affichage des table json. En effet, après avoir créé la table avec une colonne de type variant, on a essayé de l'afficher par l'intermédiaire d'une vue et allant chercher cahque colonne du fichers json comme ceci :

- data:company_name

Mais on avait pas les valeurs. La solution que l'on trouvé pour résoudre ce problème est "LATERAL FLATTEN", c'est pour cela que nous avons la syntaxe suivante :
