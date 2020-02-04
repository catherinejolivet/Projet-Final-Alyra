/* 
Le code source du smart contract est écrit avec le programme solidity, l'un des deux languages de programmation
pour développer des contrats sur le réseau Ethereum. Le contrat débute avec une ligne appelée "pragma"
qui indique la version du compilateur solidity compatible. Ainsi le contrat ne pourra pas être compilé
avec une version antérieure. Il ne pourra non plus l'être avec une version ultérieure (puisqu'ici le "^"
n'a pas été rajouté au début du numéro de version). Cette ligne donne donc des instructions au compilateur.
*/
pragma solidity 0.5.15;
/* 
Le deuxième pragma est un pragma expérimental. Il est utilisé pour activer des fonctions qui ne le sont par défaut.
Pour ce contrat, rajouter le pragma expérimental "ABIEncoderV2" permet de retourner des structs dans des fonctions,
sans erreur de compilation.
*/
pragma experimental ABIEncoderV2;
/** 
@title Stockage horodaté et transmission successorale de "créations".
@author Catherine (chef de projet : Yosra).
@notice Vous pouvez utiliser ce contrat si vous êtes l'auteur d'écrits 
@notice (manuscrits, allocutions, journaux intimes...) que vous ne souhaitez pas publier pour le moment. 
@notice Ces oeuvres seront enregistrées sur la blockchain Ethereum et auront alors 
@notice une date certaine. Vous désignerez un ou des mandataire(s), et ainsi, à votre décès, 
@notice ces écrits ne seront pas perdus, mais transmis à vos ayants droit ou à un légataire.
@dev Un seul contrat est déclaré, composé de structures (les "structs"), de modificateurs (les "modifiers") et de fonctions, 
@dev ainsi que des structures de contrôle ("break", "if").
@dev Une boucle for a également été rajoutée pour permettre à l'auteur d'ajouter plusieurs mandataires et non qu'un seul.
*/
contract TransmissionDeMesOeuvres {
/* 
Une structure est créée déclarant un type complexe représentant un auteur et contenant plusieurs champs
et un tableau. Elle sera utilisée pour ses variables tout au long du smart contract.
*/
   struct Auteur{
       string nom;
       string prenom;
       string biographie;
       uint dateNaissance;
       uint dateDeces;
       address auteur;
       address heritier;
       address[] mandataires;
   }
 /* 
 Une deuxième structure est créée déclarant un type complexe représentant un document et contenant 5 champs.
 */
   struct Document{
       string titre;
       string typeContenu;
       uint date;
       address auteur; 
       bytes32 hash;
   }
/*   
Ce mappage déclare une variable d'état qui stocke un élément de structure "documents" pour chaque document.
*/
   mapping(bytes32 => Document) documents;
/* 
Un tableau dynamique de la structure "Document".
*/
   Document[] listeDocuments;
/*
Ce mappage déclare une variable d'état qui mappe le hash d'un document à l'adresse Ethereum du propriétaire du document.
*/
   mapping(bytes32 => address) docOwner;
/*
Ce mappage déclare une variable d'état qui stocke un élément de structure "auteurs" pour chaque auteur.
*/
   mapping(address => Auteur) auteurs;
/*
Modificateur qui sera utilisé pour modifier facilement le comportement de fonctions du smart contract, en modifiant sa sémantique.
Si "onlyAuteur" est rajouté à la sémantique d'une fonction, celle-ci ne pourra être appelée
que par l'auteur du document. Si ce n'est pas l'auteur qui appelle la fonction, elle ne sera pas exécutée.
*/
   modifier onlyAuteur(){
       require(msg.sender == auteurs[msg.sender].auteur, "seul l'auteur du document peut appeler cette fonction.");
       _;
   }
   
   /* 
Modificateur qui sera utilisé pour modifier facilement le comportement de fonctions du smart contract, en modifiant sa sémantique.
Si "onlyMandataire" est rajouté à la sémantique d'une fonction, celle-ci ne pourra être appelée
que par un mandataire désigné par l'auteur. 
*/
   modifier onlyMandataire(address _auteur){
        require(LesMandataires(msg.sender, _auteur), "seul un mandataire désigné par l'auteur peut appeler cette fonction.");
       _  ;
   }
/**
@notice Vérifie si l'auteur a désigné un ou des mandataires.
@dev La fonction va rechercher dans le mapping auteurs s'il y a des mandataires désignés. 
@dev Cette fonction utilise le mot clé "public", ce qui la rend accessible depuis l'extérieur du smart contract. 
@dev La boucle for est utilisée pour parcourir le tableau des mandataires et vérifier si l'auteur en a désigné ou pas, 
@dev grâce à la structure de contrôle "if". 
@dev Toute la longueur du tableau est vérifiée. 
@dev "Break" a été déclarée dans la fonction pour permettre de sortir de la boucle dès que le tableau est vide.
@param _auteur Adresse Ethereum de l'auteur.
@param _mandataires Adresse(s) Ethereum du ou des mandataires.
*/
   function LesMandataires(address _auteur, address _mandataires) public view returns (bool) {
       for (uint i= 0; i < auteurs[_auteur].mandataires.length; i++){
           if (auteurs[_auteur].mandataires[i] == _mandataires){
               return true;
               break;
           }
       }
       return false;
   }

/**
@notice Ajoute un document qui sera horodaté dans la blockchain Ethereum. 
@dev La fonction va initialiser les structures et les ajouter dans les mappings. 
@dev Cette fonction utilise le mot clé "public", ce qui la rend accessible depuis l'extérieur du smart contract.
@param _titre Titre du document.
@param _typeContenu Type de contenu du document (manuscrit, allocution, journal intime).
@param _date Date à laquelle le document a été rédigé.
@param _hash Hash du document.
@param _nom Nom de l'auteur.
@param _prenom Prénom de l'auteur.
@param _biographie Biographie de l'auteur.
@param _dateNaissance Date de naissance de l'auteur.
@param _heritier Adresse Ethereum des héritiers (indivisaires ou légataire).
*/
   function AjouterUneOeuvre (string memory _titre, string memory _typeContenu, uint _date, bytes32 _hash,
   string memory _nom, string memory _prenom, string memory _biographie, uint _dateNaissance, address _heritier) public{
       // Assigne une référence "nouveauDoc".
       Document memory nouveauDoc = Document(_titre, _typeContenu, _date, msg.sender, _hash);
       // Le hash du document est stocké pour chaque nouveau document.
       documents[_hash] = nouveauDoc;
       // Pour chacun des documents, un nouveau type d'élément Document est rajouté au tableau listeDocuments.
       listeDocuments.push(nouveauDoc);
       // Déclaration d'un tableau vide pour les mandataires
       address[] memory _mandataires;
        // Assigne une référence "nouveauAuteur" ; la date de décès de l'auteur est renseignée à 0.
       Auteur memory nouveauAuteur = Auteur(_nom, _prenom, _biographie, _dateNaissance, 0, msg.sender, _heritier, _mandataires);
       // A chaque hash de document correspond l'adresse du msg.sender.
       docOwner[_hash] = msg.sender;
       // L'adresse du msg.sender est stockée pour chaque nouvel auteur.
       auteurs[msg.sender] = nouveauAuteur;
   }
/** 
@notice Ajoute la ou les adresses Ethereum d'un ou des mandataire(s) (notaire, ayant droit ou toute personne de son choix).
@notice Seul l'auteur est habilité à désigner un mandataire.
@dev La fonction va ajouter une variable au struct Auteur. 
@dev Cette variable étant un tableau, elle peut comprendre plusieurs valeurs, les adresses Ethereum des mandataires.
@param _mandataire une adresse Ethereum d'un mandataire.
*/
   function AjouterUnMandataire (address _mandataire) onlyAuteur public{
        Auteur storage auteur = auteurs[msg.sender];
        auteur.mandataires.push(_mandataire);
   }
/** 
@notice Ajoute l'adresse Ethereum des héritiers d'un auteur.
@notice Celui qui ajoute les héritiers est soit l'auteur (première condition), 
@notice soit un mandataire désigné par lui (deuxième condition).
@dev La fonction va ajouter l'adresse Ethereum des héritiers (indivisaires ou légataire). 
@dev "Require" est lancée pour vérifier qu'une des 2 conditions requises est remplie. 
@dev L'opérateur || qui signifie "ou" est ainsi utilisé. 
@dev Si l'une des 2 conditions est remplie, "true" est renvoyée, sinon une exception est lancée.
@param _heritier Adresse Ethereum des héritiers (indivisaires ou légataire).
@param _auteur Adresse Ethereum de l'auteur.
*/
   function AjouterLesHeritiers (address _heritier, address _auteur) public{
       require(msg.sender == auteurs[msg.sender].auteur || LesMandataires (msg.sender,_auteur));
       Auteur storage auteur = auteurs[_auteur];
       auteur.heritier = _heritier;
   }
/**
@notice Déclare une date de décès qui est conservée de façon persistante dans la base de donnée.
@notice Seul le mandataire désigné par l'auteur peut exécuter cette action.
@dev La fontion va ajouter la date de décès et permettre le transfert de propriété du document 
@dev après qu'une structure de contrôle est mise en place.
@param _auteur Adresse Ethereum de l'auteur.
@param _dateDeces Date de décès de l'auteur.
@param _hash Hash du document.
*/
   function DeclarerLeDeces (address _auteur, uint _dateDeces, bytes32 _hash) onlyMandataire(_auteur) public{
       Auteur storage auteur = auteurs[_auteur];
       auteur.dateDeces = _dateDeces;
       if(auteurs[_auteur].heritier != address(0)){
           TransfererLaPropriete(_hash, _auteur);
       }
   }
/**
@notice Transfère la propriété du document aux héritiers.
@notice Seul un des mandataires désigné par l'auteur peut exécuter cette action,
@notice dès lors que la date de décès est renseignée et les héritiers désignés.
@dev La fonction exécute le transfert de propriété du document.
@param _hash Hash du document.
@param _auteur Adresse Ethereum de l'auteur.
*/
   function TransfererLaPropriete (bytes32 _hash, address _auteur) public{
       require(msg.sender == address(this) || LesMandataires(msg.sender, _auteur));
       require(auteurs[_auteur].heritier != address(0));
       require(auteurs[_auteur].dateDeces > 0);
       docOwner[_hash] = auteurs[_auteur].heritier;
   }
/**
@notice Renvoie le hash du document. 
@dev La fonction permet de récupérer la variable de la fonction, soit le hash du document, 
@dev sans que cette fonction ne nécessite une nouvelle transaction.
@dev Cette fonction est non seulement publique, mais aussi en "lecture seule" (mot clé "view"),
@dev c’est-à-dire qu’elle ne modifie en rien les variables du contrat et donc l'état de la blockchain.
@param _hash Hash du document.
@return le hash du document.
*/
   function LeDocument(bytes32 _hash) public view returns(Document memory){
       return documents[_hash];
   }
/**
@notice Renvoie le hash du document appartement à son propriétaire.
@dev La fonction permet de récupérer le hash du document appartenant à son propriétaire, 
@dev sans que cette fonction ne nécessite une nouvelle transaction.
@dev Cette fonction est non seulement publique, mais aussi en "lecture seule" (mot clé "view"),
@dev c’est-à-dire qu’elle ne modifie en rien les variables du contrat.
@param _hash Hash du document appartenant au propriétaire du document.
@return le hash du document appartenant au propriétaire du document.
*/
   function ProprietaireDuDocument (bytes32 _hash) public view returns(address){
   return docOwner[_hash];
   }  
/**
@notice Renvoie l'adresse de l'auteur sur le réseau Ethereum. 
@dev La fonction permet de récupérer l'adresse de l'auteur sur le réseau Ethereum, 
@dev sans que cette fonction ne nécessite une nouvelle transaction.  
@dev Cette fonction est non seulement publique, mais aussi en "lecture seule" (mot clé "view"),  
@dev c’est-à-dire qu’elle ne modifie en rien les variables du contrat.
@param _auteur Adresse de l'auteur sur le réseau Ethereum.
@return l'adresse Ethereum de l'auteur.
*/
   function LAuteur(address _auteur) public view returns (Auteur memory){
       return auteurs[_auteur];
    }
}