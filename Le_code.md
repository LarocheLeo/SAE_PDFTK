# SAE_PDFTK

## Mise en contexte

On veut un script bash qui puisse extraire une page ou un nombre de pages voulu dans un ou plusieurs pdf et qui ressort seulement un seul pdf après la manipulation. 
En plus de cette fonctionnalité, il faudrait pouvoir extraire les pages pas par le numéro de la page. Mais par rapport à des mots-clés.  

## Le codage

Pour répondre au besoin, j'ai réalisé plusieurs programmes qui permettent de donner une solution à cette problématique. 

Dans le dépôt, il existe les programmes suivants :

- Setup.sh
- programme_extraction.sh
- programme_final.sh

Pour éviter d'être répétitif, je vais seulement documenter le setup.sh et programme_final.sh. Car tout simplement, le programme_final.sh est le programme avec toutes les demandes réalisées et donc bien plus complet que le  programme_extratction.sh qui a seulement la première fonctionnalité terminée. 

## Setup.sh 

### Rôle

Setup.sh permet de vérifier si les paquets qui sont vitaux pour notre programme principal sont bel et bien installés, sinon il les installera.

### Code 

```
#!/bin/bash
```
Cette ligne permet au système de lancer le script en Bash. Il est dans tous les scripts bash. 
```
echo "=== Vérification des dépendances pour le programme PDF ==="

# Liste des paquets/commandes nécessaires
declare -A packages
packages=( 
    ["pdftk"]="pdftk"
    ["pdfgrep"]="pdfgrep"
    ["pdfinfo"]="poppler-utils"
)
```
```declare -A``` permet de créer un tableau associatif en Bash. Un tableau associatif stocke des paires clé/valeur plutôt que des indices numériques classiques.
```packages``` est le nom du dit tableau. 

Ensuite, on définit le tableau comme : 

| Élément dans le code          | Clé (key) | Valeur (value)  | Rôle dans le script                                                                                                            |
| ----------------------------- | --------- | --------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| `["pdftk"]="pdftk"`           | `pdftk`   | `pdftk`         | La clé `pdftk` sert à vérifier si la commande existe (`command -v pdftk`). La valeur `pdftk` est le nom du paquet à installer. |
| `["pdfgrep"]="pdfgrep"`       | `pdfgrep` | `pdfgrep`       | Même logique : clé = commande, valeur = paquet.                                                                                |
| `["pdfinfo"]="poppler-utils"` | `pdfinfo` | `poppler-utils` | Ici la clé `pdfinfo` est la commande à tester. La valeur `poppler-utils` est le paquet qui contient `pdfinfo`.                 |


Mais à quoi servent pdfgrep et pdfinfo ? Ces derniers sont utilisés dans le programme principal, donc ils seront plus détaillés par la suite. Mais pour expliquer en quelques lignes : 

- `pdfinfo` : récupère les informations d’un PDF, notamment le nombre total de pages, pour vérifier que les pages demandées existent avant extraction.
- `pdfgrep` : cherche un mot-clé dans un PDF et retourne les numéros de pages où il apparaît, permettant d’extraire automatiquement ces pages.

```
missing=()

# Vérification de chaque commande
for cmd in "${!packages[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        missing+=("${packages[$cmd]}")
        echo "La commande '$cmd' est manquante."
    fi
done
```
```missing=()``` On crée un tableau qui nous permettra de mettre tous les paquets manquants détectés lors de la vérification. 
```for cmd in "${!packages[@]}"; do``` On parcourt toutes les clés du tableau associatif de packages défini plutôt. ```"${!packages[@]}"``` permet de retourner toutes les clés du tableau. Puis ```cmd``` prend le relais pour chaque commande à vérifier. 
```if ! command -v "$cmd" >/dev/null 2>&1; then``` on fait un if. ```! command -v "$cmd"``` On vérifie donc si la commande existe cependant ! Grâce "!", on inverse le résultat, donc le if devient vrai seulement si la commande n'est pas dans le système. Pour finir, on fait ```>/dev/null 2>&1``` pour éviter d'avoir les messages qui soient erreurs et standards
```missing+=("${packages[$cmd]}")```, puis après avoir vérifié si la commande est bien absente du système. On la rajoute dans le tableau missing.et pour finir, on fait un écho pour avertir l'utilisateur des commandes absentes. 


```
# Installations des paquets manquants si nécessaire
if [ ${#missing[@]} -eq 0 ]; then
    echo "Toutes les dépendances sont déjà installées."
    exit
else
    echo "Les paquets suivants vont être installés : ${missing[*]}"
fi
```
ici c'est un simple if qui permet de savoir ce qu'on fait si. Le tableau missing est vide ou non. si il est vide, tout est déjà installer donc on exit car pas besoin de continuer. 
Cependant si c'est pas le cas, on dit à l'utilisateur ce qui va être installer. 

```

sudo apt update
sudo apt install -y "${missing[@]}"
echo "Installation terminée."

```
Les commandes basiques pour installer ce qu'ils manquent mais aussi prévient l'utilisateur quand l'installation est terminer. 

## progragmme_final.sh

### Rôle 

programme_final est la solution de la demande par rapport au pdf, il permet d'extraire les informations d'un pdf ou de plusieurs et de les mettres dans un pdf nomable appart. 

### Code 

```
#!/bin/bash

```

Cette ligne permet au système de lancer le script en Bash. Il est dans tous les scripts bash. 

```
# Liste des paquets/commandes nécessaires
declare -A packages
packages=( 
    ["pdftk"]="pdftk"
    ["pdfgrep"]="pdfgrep"
    ["pdfinfo"]="poppler-utils"
)

missing=()

# Vérifier chaque commande
for cmd in "${!packages[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        missing+=("${packages[$cmd]}")
        echo "La commande '$cmd' est manquante. Veulliez lancer setup.sh pour résoudre le problème"
        exit 1
    fi
done
```
Cette partie fait exactement comme ce qui est présenté dans le point Setup.sh. Cependant, au lieu d'installer, elle vérifie si tout est bien présent pour que le programme puisse travailler dans les meilleures conditions. Si c'est pas le cas, le script s'arrête et demande à l'utilisateur de lancer le setup.sh pour installer la ou les commandes manquantes. 

```
# Demander les fichiers PDF
read -p "Entrez le(s) nom(s) de fichier(s) PDF (séparés par des espaces) ou tapez 'all' pour tout prendre : " -a input_files

# Demander si on veut extraire par pages OU par mots-clés
read -p "Voulez-vous extraire par (p)ages ou par (m)ot-clé ? [p/m] : " mode

# Nom du fichier final
read -p "Comment se nommera le fichier final ? " pdf_final
```

Ici, c'est l'interaction basique avec l'utilisateur qui sera importante pour la suite. On demande quels PDF l'utilisateur veut utiliser, soit certains et donc il le précise, ou soit tous les PDF où se trouve le script. On demande ensuite quelle méthode d'extraction l'utilisateur veut, soit en indiquant les pages, soit avec un mot clé. Pour finir, on demande simplement à l'utilisateur de donner un nom pour le PDF qui aura toutes les informations extraites.

```
# Si l'utilisateur veut tous les PDFs du dossier
if [[ "${input_files[0]}" == "all" ]]; then
    pdfs=( *.pdf )
else
    pdfs=( "${input_files[@]}" )
fi
```
Un simple if, si l'utilisateur a dit "all", alors la variable pdfs sera remplie de tous les pdfs du dossier comme indiqué avec : ``` pdfs=( *.pdf )```. Cependant, si c'est pas le cas. On utilise la liste renseignée par l'utilisateur. 

```
# Vérifier l'extension du fichier final
if [[ "$pdf_final" != *.pdf ]]; then
    pdf_final="${pdf_final}.pdf"
fi
```
Petite fonction par rapport au nom donné par l'utilisateur. Car le fichier final, donc là où vont être toutes les informations extraites. Doit être en .pdf, donc ce if vérifie si l'utilisateur a bien renseigné l'extension pour le fichier final. Donc le .pdf, si c'est pas le cas, on le rajoute.


```
# Tableau pour stocker les PDFs temporaires
pdf_creer=()
```
On crée un tableau qui va nous servir, comme dit, à stocker les PDF temporaires qui sont créés lors des extractions des pages par pdftk. 

```
# Mode extraction par pages
if [[ "$mode" == "p" ]]; then
    read -p "Saisissez le(s) page(s) à récupérer (ex: 1-3 5 7) : " pages

    for pdf_input in "${pdfs[@]}"; do
        total_pages=$(pdfinfo "$pdf_input" 2>/dev/null | grep "Pages:" | awk '{print $2}')

        adjusted_pages=""
        for part in $pages; do
            if [[ "$part" =~ ^([0-9]+)-([0-9]+)$ ]]; then
                start=${BASH_REMATCH[1]}
                end=${BASH_REMATCH[2]}
                # Ajuster la borne max
                if (( end > total_pages )); then
                    end=$total_pages
                fi
                # Ajouter seulement si la plage est valide
                if (( start <= end && start <= total_pages )); then
                    adjusted_pages+="$start-$end "
                fi
            else
                # Page unique
                if (( part <= total_pages )); then
                    adjusted_pages+="$part "
                fi
            fi
        done
```

```if [[ "$mode" == "p" ]]; then``` si l'utilisateur choisit l'option P qui représente l'extraction en précisant les pages. Alors on demandera à l'utilisateur quelles pages il veut extraire en lui donnant un exemple. 
```for pdf_input in "${pdfs[@]}"; do``` On prend un par un chaque fichier sélectionné par l'utilisateur.

```total_pages=$(pdfinfo "$pdf_input" 2>/dev/null | grep "Pages:" | awk '{print $2}')``` 

Voici la seule utilisation de pdfinfo. Pdfinfo va permettre de récupérer le numéro de pages de chaque pdf. Les sorties sont envoyées vers null pour éviter d'encombrer le terminal de l'utilisateur. Mais pourquoi utiliser pdfinfo, juste pour récupérer le numéro de pages ? Tout simple, si l'utilisateur veut récupérer sur deux PDF la page 2 à 5. Sur l'un des PDF, il y aura 6 pages, donc cela passera. Cependant, du second, il n'y a que 4 pages. Ça va créer une erreur car pdftk ne peut pas récupérer de pages qui n'existent pas. Donc récupérer le nombre de pages va nous permettre de régler ce problème plus loin dans le programme.

```adjusted_pages="",``` On crée une variable vide où on mettra uniquement les pages/plages valides à extraire.
```for part in $pages; do``` se for permet de regarder l'entrée que l'utilisateur a mise.
```if [[ "$part" =~ ^([0-9]+)-([0-9]+)$ ]]; then``` Si dans l'entrée, l'utilisateur a mis une plage, on vérifie si elle est valide. Si elle contient bien un numéro, un tiret et un autre numéro collé. Si, on remplit cette condition. Nous sommes dans une plage.   $part est toute expression régulière car elle contient la plage s'il y en a une.

```start=${BASH_REMATCH[1]}``` et ```end=${BASH_REMATCH[2]}``` BASH_REMATCH contient les parties capturées par l’expression régulière. 1 et 2 sont le début et la fin d'une plage. 
```
if (( end > total_pages )); then
    end=$total_pages
fi
```
Voilà à quoi sert pdfinfo en pratique. Car si on le met pas, on aura une erreur disant qu'on a pas pu extraire la page car la plage n'était pas bonne. Comme mon exemple avec les deux PDF. Mais ! Grâce au fait qu'on récupère le nombre total de pages dans les PDF avec pdfinfo, on peut remplacer la fin de la plage par le nombre maximum de pages identifiées. Donc au lieu d'avoir une erreur et de ne pas pouvoir extraire les pages. On aura les pages 2 à 5 de mon pdf de 6 pages vues précédemment, mais aussi les pages 2 à 4 de mon pdf de 4 pages. On a ajusté la fin de la plage avec le nombre total de pages récupérées par pdfinfo.  


```
# Ajouter seulement si la plage est valide
if (( start <= end && start <= total_pages )); then
   adjusted_pages+="$start-$end "
fi
```

Pour être sûr que la plage reste valide dans tous les cas, on la teste avec cette fonction if. Qui va vérifier si le début (start) est bien plus petit que la fin (end) ou le nombre de pages total. Puis on rajoute à la variable adjusted_pages.

```
# Page unique
if (( part <= total_pages )); then
    adjusted_pages+="$part "
fi
```

Puis, si c'est pas une plage mais une page simple, donc un numéro, on vérifie que cette dernière existe dans le pdf. Et on le rajoute dans la variable. 

```
        if [[ -z "$adjusted_pages" ]]; then
            echo "Aucune page valide à extraire dans $pdf_input"
            continue
        fi
```
Teste la variable pour savoir si elle est vide. Puis si aucune page que l'utilisateur a renseignée ne correspond au pdf, alors on affiche le message suivant qui prévient l'utilisateur qu'il na pas trouvé la page dans le pdf et continue avec les autres pdf. 

```
        pdf_output="temp_${pdf_input%.pdf}.pdf"
        pdftk "$pdf_input" cat $adjusted_pages output "$pdf_output" 2>/dev/null
```

```pdf_output="temp_${pdf_input%.pdf}.pdf"``` On renomme le nom du fichier car ils vont nous servir de fichiers temporaires avant la fusion. 
```pdftk "$pdf_input" cat $adjusted_pages output "$pdf_output" 2>/dev/null``` Puis avec pdftk, on vient extraire les pages qu'on souhaite et qui vont être insérées dans les pdf qu'on a renommés.   On fait une redirection pour éviter tout affichage de bug ou autre qui gênerait le terminal de l'utilisateur. 

```
        if [[ -f "$pdf_output" ]]; then
            echo "Pages $adjusted_pages de $pdf_input extraites vers $pdf_output"
            pdf_creer+=("$pdf_output")
        else
            echo "Erreur : impossible d’extraire depuis $pdf_input"
        fi
    done
fi
```

Puis on vérifie si tout s'est bien déroulé. Si le fichier temporaire s'est bien créé. Sinon on affiche une erreur. Voici le dernier segment de code qui termine l'option P. 


```
# Mode extraction par mot-clé avec pdfgrep
if [[ "$mode" == "m" ]]; then
    read -p "Entrez le mot-clé à rechercher : " keyword
    read -p "Ignorer les majuscules/minuscules ? [o/n] : " ignore_case

    if [[ "$ignore_case" == "o" || "$ignore_case" == "O" ]]; then
        grep_option="-i"
    else
        grep_option=""
    fi
```

Maintenant, on va parler de l'option M qui va extraire les pages par mot-clé.
Déjà, si l'option est choisie. On demande le mot-clé que l'utilisateur recherche et on demande si, oui ou non, il veut ignorer les majuscules/minuscules. 
Si l'utilisateur choisit d'ignorer la différence de lettre. Alors on rajoutera l'argument –i qui permettra de ne pas faire la différence entre majuscules ou minuscules. Si c'est l'inverse, on fera la différence.

```
    for pdf_input in "${pdfs[@]}"; do
        echo "Recherche du mot-clé '$keyword' dans $pdf_input..."

        pages=$(pdfgrep -n $grep_option "$keyword" "$pdf_input" 2>/dev/null | cut -d: -f1 | sort -n | uniq)
```

```for pdf_input in "${pdfs[@]}"; do``` Boucle for pour regarder dans tous les fichiers PDF. 
```echo "Recherche du mot-clé '$keyword' dans $pdf_input..."``` On prévient ensuite l'utilisateur de quel mot-clé on cherche dans quel PDF. 
```pages=$(pdfgrep -n $grep_option "$keyword" "$pdf_input" 2>/dev/null | cut -d: -f1 | sort -n | uniq)``` Puis on utilise pdfgrep, qui permet donc de chercher le mot-clé dans le fichier pdf. On affiche le numéro de page où il apparait avec "-n". Si nous avions le grep_option avec "-i", on ignorerait les majuscules et minuscules, sinon, on fait la différence. On fait une redirection pour éviter les erreurs ou les messages parasites dans le terminal.
```cut -d: -f1 ``` Cette option permet de garder seulement les numéros de pages. 
```sort -n``` puis avec cette option on trie les numéros de pages dans l’ordre croissant.
```uniq``` Puis avec cette option on supprime les doublons.


```

        if [[ -z "$pages" ]]; then
            echo "Aucun résultat trouvé dans $pdf_input"
            continue
        fi
```
On teste la variable, pour savoir si elle est vide. Si c'est le cas, on dit alors que nous n'avons rien trouvé. 

```
        pdf_output="temp_${pdf_input%.pdf}.pdf"
        pdftk "$pdf_input" cat $pages output "$pdf_output" 2>/dev/null
        if [[ -f "$pdf_output" ]]; then
            echo "Pages $pages de $pdf_input extraites vers $pdf_output"
            pdf_creer+=("$pdf_output")
        fi
    done
fi
```

Puis comme dans l'option P, on vient renommer les PDF pour en faire des PDF temporaires où on mettra les pages extraites. Puis si tout s'est bien déroulé, on vient prévenir l'utilisateur. 

```
# Fusionner les fichiers extraits
if [[ ${#pdf_creer[@]} -gt 0 ]]; then
    pdftk "${pdf_creer[@]}" cat output "$pdf_final" 2>/dev/null
    echo "Création du fichier en cours..."
    echo "Fichier final créé : $pdf_final"
    # Supprimer seulement si le fichier existe
    for f in "${pdf_creer[@]}"; do
        [[ -f "$f" ]] && rm "$f"
    done
else
    echo "Aucun fichier n’a été généré (vérifiez vos mots-clés ou pages)."
fi
```

```if [[ ${#pdf_creer[@]} -gt 0 ]]; then``` On regarde s'il y a au moins 1 fichier créé par rapport à l'extraction des PDF via l'option p ou m.
```pdftk "${pdf_creer[@]}" cat output "$pdf_final" 2>/dev/null``` Puis avec cette commande, on va mettre chaque pdf temporaire créé dans le pdf final que l'utilisateur a nommé au tout début. Et pour éviter les messages parasites, on fait une redirection des erreurs. 

```
echo "Création du fichier en cours..."
echo "Fichier final créé : $pdf_final"  
```
Puis on informe l'utilisateur que son fichier final s'est créé.

```
for f in "${pdf_creer[@]}"; do 
    [[ -f "$f" ]] && rm "$f"
```
Et si tout s'est bien déroulé, on vient supprimer les fichiers temporaires générés par l'extraction des pages. Car ces derniers prennent de la place inutilement vu qu'on les fusionne à la fin.

```echo "Aucun fichier n’a été généré (vérifiez vos mots-clés ou pages)."``` S'il na pas pu créer le fichier par manque de pdf ou autre, le script le dira à l'utilisateur avec ce message. 