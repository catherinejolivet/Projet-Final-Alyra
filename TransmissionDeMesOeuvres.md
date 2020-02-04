# TransmissionDeMesOeuvres
_Vous pouvez utiliser ce contrat si vous êtes l'auteur d'écrits (manuscrits, allocutions, journaux intimes...) que vous ne souhaitez pas publier pour le moment. Ces oeuvres seront enregistrées sur la blockchain Ethereum et auront alors une date certaine. Vous désignerez un ou des mandataire(s), et ainsi, à votre décès, ces écrits ne seront pas perdus, mais transmis à vos ayants droit ou à un légataire._
> Created By Catherine (chef de projet : Yosra).

Un seul contrat est déclaré, composé de structures (les "structs"), de modificateurs (les "modifiers") et de fonctions, ainsi que des structures de contrôle ("break", "if").Une boucle for a également été rajoutée pour permettre à l'auteur d'ajouter plusieurs mandataires et non qu'un seul.
## Stockage horodaté et transmission successorale de "créations".

## AjouterLesHeritiers - read
|name |type |description
|-----|-----|-----------
|_heritier|address|Adresse Ethereum des héritiers (indivisaires ou légataire).
|_auteur|address|Adresse Ethereum de l'auteur.
La fonction va ajouter l'adresse Ethereum des héritiers (indivisaires ou légataire). "Require" est lancée pour vérifier qu'une des 2 conditions requises est remplie. L'opérateur || qui signifie "ou" est ainsi utilisé. Si l'une des 2 conditions est remplie, "true" est renvoyée, sinon une exception est lancée.

## AjouterUnMandataire - read
|name |type |description
|-----|-----|-----------
|_mandataire|address|une adresse Ethereum d'un mandataire.
La fonction va ajouter une variable au struct Auteur. Cette variable étant un tableau, elle peut comprendre plusieurs valeurs, les adresses Ethereum des mandataires.

## AjouterUneOeuvre - read
|name |type |description
|-----|-----|-----------
|_titre|string|Titre du document.
|_typeContenu|string|Type de contenu du document (manuscrit, allocution, journal intime).
|_date|uint256|Date à laquelle le document a été rédigé.
|_hash|bytes32|Hash du document.
|_nom|string|Nom de l'auteur.
|_prenom|string|Prénom de l'auteur.
|_biographie|string|Biographie de l'auteur.
|_dateNaissance|uint256|Date de naissance de l'auteur.
|_heritier|address|Adresse Ethereum des héritiers (indivisaires ou légataire).
La fonction va initialiser les structures et les ajouter dans les mappings. Cette fonction utilise le mot clé "public", ce qui la rend accessible depuis l'extérieur du smart contract.

## DeclarerLeDeces - read
|name |type |description
|-----|-----|-----------
|_auteur|address|Adresse Ethereum de l'auteur.
|_dateDeces|uint256|Date de décès de l'auteur.
|_hash|bytes32|Hash du document.
La fontion va ajouter la date de décès et permettre le transfert de propriété du document après qu'une structure de contrôle est mise en place.

## LAuteur - view
|name |type |description
|-----|-----|-----------
|_auteur|address|Adresse de l'auteur sur le réseau Ethereum.
La fonction permet de récupérer l'adresse de l'auteur sur le réseau Ethereum, sans que cette fonction ne nécessite une nouvelle transaction.  Cette fonction est non seulement publique, mais aussi en "lecture seule" (mot clé "view"),  c’est-à-dire qu’elle ne modifie en rien les variables du contrat.
Return : l'adresse Ethereum de l'auteur.

## LeDocument - view
|name |type |description
|-----|-----|-----------
|_hash|bytes32|Hash du document.
La fonction permet de récupérer la variable de la fonction, soit le hash du document, sans que cette fonction ne nécessite une nouvelle transaction.Cette fonction est non seulement publique, mais aussi en "lecture seule" (mot clé "view"),c’est-à-dire qu’elle ne modifie en rien les variables du contrat et donc l'état de la blockchain.
Return : le hash du document.

## LesMandataires - view
|name |type |description
|-----|-----|-----------
|_auteur|address|Adresse Ethereum de l'auteur.
|_mandataires|address|Adresse(s) Ethereum du ou des mandataires.
La fonction va rechercher dans le mapping auteurs s'il y a des mandataires désignés. Cette fonction utilise le mot clé "public", ce qui la rend accessible depuis l'extérieur du smart contract. La boucle for est utilisée pour parcourir le tableau des mandataires et vérifier si l'auteur en a désigné ou pas, grâce à la structure de contrôle "if". Toute la longueur du tableau est vérifiée. "Break" a été déclarée dans la fonction pour permettre de sortir de la boucle dès que le tableau est vide.

## ProprietaireDuDocument - view
|name |type |description
|-----|-----|-----------
|_hash|bytes32|Hash du document appartenant au propriétaire du document.
La fonction permet de récupérer le hash du document appartenant à son propriétaire, sans que cette fonction ne nécessite une nouvelle transaction.Cette fonction est non seulement publique, mais aussi en "lecture seule" (mot clé "view"),c’est-à-dire qu’elle ne modifie en rien les variables du contrat.
Return : le hash du document appartenant au propriétaire du document.

## TransfererLaPropriete - read
|name |type |description
|-----|-----|-----------
|_hash|bytes32|Hash du document.
|_auteur|address|Adresse Ethereum de l'auteur.
La fonction exécute le transfert de propriété du document.