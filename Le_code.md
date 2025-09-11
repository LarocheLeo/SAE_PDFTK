# SAE_PDFTK

## Mise en contexte

On veut un script bash qui puisse extraire une page ou un nombre de page voulu dans un ou plusieurs pdf et qui ressort seulement un seul pdf après la manipulation. 
En plus de cette fonctionalité, il faudrai pouvoir extraire les pages pas par le numéro de la page. Mais par rapport à des mots clés. 

## Le codage

Pour répondre au besoin, j'ai réaliser plusieurs programmes qui permet de donner une solution à cette problèmatique. 

Dans le dêpot, il existe les programmes suivant :

- Setup.sh
- programme_extraction.sh
- programme_final.sh

Pour éviter d'être répétitif, je vais seulement documenter le setup.sh et programme_final.sh. Car tout simplement, le programme_final.sh est le programme avec toutes les demandes réaliser et donc bien plus complet que le  programme_extratction.sh qui a seulement la première fonctionaliter terminer. 

## Setup.sh 

### Rôle

Setup.sh permet de vérifier si les paquets qui sont vitale pour notre programme principal sont belle et bien, installer sinon il les installeras.

### Code 

```
#!/bin/bash
```
Cette ligne permet au system de lançer le script en bash. Il est dans tous les scripts bash. 

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
```declare -A``` permet de créer un tableau associatif en bash. Un tableau associatif stocke des paires clé/valeur plutôt que des indices numériques classiques.
```packages``` est le nom du dis tableau. 

Ensuite, on définie le talbeau comme : 

| Élément dans le code          | Clé (key) | Valeur (value)  | Rôle dans le script                                                                                                            |
| ----------------------------- | --------- | --------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| `["pdftk"]="pdftk"`           | `pdftk`   | `pdftk`         | La clé `pdftk` sert à vérifier si la commande existe (`command -v pdftk`). La valeur `pdftk` est le nom du paquet à installer. |
| `["pdfgrep"]="pdfgrep"`       | `pdfgrep` | `pdfgrep`       | Même logique : clé = commande, valeur = paquet.                                                                                |
| `["pdfinfo"]="poppler-utils"` | `pdfinfo` | `poppler-utils` | Ici la clé `pdfinfo` est la commande à tester. La valeur `poppler-utils` est le paquet qui contient `pdfinfo`.                 |


Mais ? à quoi sert pdfgrep et le pdfinfo ? ces derniers sont utiliser dans le programme principal donc il sera plus détailler par la suite. Mais pour expliquer en quelque ligne : 

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
```missing=()``` on créer un talbeau qui nous permettra de mettre tout les paquets manquants détécter lors de la vérification. 
```for cmd in "${!packages[@]}"; do``` On parcours toutes les clés du tableau associatif de packages défini plutôt. ```"${!packages[@]}"``` permet de retourner toutes les clés du tableau. Puis ```cmd``` prend le reler pour chaque commande vérifier. 
```if ! command -v "$cmd" >/dev/null 2>&1; then``` on fait un if. ```! command -v "$cmd"``` on vérifie donc si la commande exsite cependant ! Grâce "!", on inverse le résulthat donc le if devient vrai seulement si la commande n'est pas dans le system. pour finir on fait ```>/dev/null 2>&1``` pour éviter d'avoir les messages qui soit erreurs et standards
```missing+=("${packages[$cmd]}")```, puis après avoir vérifier si la commande est bien absente du system. On la rajoute dans le tableau missing.
et pour finir, on fait un echo pour avertir l'utilisateur des commandes absentes. 


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

Cette ligne permet au system de lançer le script en bash. Il est dans tous les scripts bash. 

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
Cette partie fait exactement, comme ce qui est présenter dans le point Setup.sh. Cependant au lieu d'installer, elle vérifie si tout est bien présent pour que le programme puisse travailler dans les meilleurs conditions. Si c'est pas le cas, le script s'arrête et demande à l'utilisateur de lancer le setup.sh pour installer la ou les commandes manquantes. 

```
# Demander les fichiers PDF
read -p "Entrez le(s) nom(s) de fichier(s) PDF (séparés par des espaces) ou tapez 'all' pour tout prendre : " -a input_files

# Demander si on veut extraire par pages OU par mots-clés
read -p "Voulez-vous extraire par (p)ages ou par (m)ot-clé ? [p/m] : " mode

# Nom du fichier final
read -p "Comment se nommera le fichier final ? " pdf_final
```

Ici, c'est l'interaction basique avec l'utilisateur qui seront important pour la suite. on demande quels pdf l'utilisateur veut utiliser, soit certains et donc il le présice ou soit tout les pdfs ou se trouve le script. 
On demande ensuite quel méthode d'extraction l'utilisateur veux, soit en indicant les pages ou soit avec un mot clé. 
Pour finir, on demande simplement a l'utilisateur de donner un nom pour le pdf qui aura tout les informations extraites.

```
# Si l'utilisateur veut tous les PDFs du dossier
if [[ "${input_files[0]}" == "all" ]]; then
    pdfs=( *.pdf )
else
    pdfs=( "${input_files[@]}" )
fi
```
Un simple if, si l'utilisateur a dit "all", alors la variable pdfs sera remplie de tout les pdfs du dossier comme indoiquer avec : ``` pdfs=( *.pdf )```. Cependant, si c'est pas le cas. On utilise la liste renseigner par l'utilisateur. 

```
# Vérifier l'extension du fichier final
if [[ "$pdf_final" != *.pdf ]]; then
    pdf_final="${pdf_final}.pdf"
fi
```
Petite fonction par rapport au nom donner par l'utilisateur. Car le fichier final, donc la ou va être toutes les informations extraites. Doit être en .pdf, donc se if vérifie, si l'utilisateur à bien renseigner l'extension pour le fichier final. Donc le .pdf, si c'est pas le cas, on le rajoute.

```
# Tableau pour stocker les PDFs temporaires
pdf_creer=()
```
On créer un tableau qui va nous servire, comme dit à stocker les pdfs temporaires qui sont créer lors des extractions des pages par pdftk. 

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

```if [[ "$mode" == "p" ]];``` then si l'utilisateur choisi l'option P qui représente l'extaction en précisiant les pages. Alors on demandera à l'utilisateur quelles pages, il veut extraire en lui donnant un exemple. 
```for pdf_input in "${pdfs[@]}"; do``` on prend un par un chaque fichier sélectionner par l'utilisateur.

```total_pages=$(pdfinfo "$pdf_input" 2>/dev/null | grep "Pages:" | awk '{print $2}')``` 

Voici la seul utilisation de pdfinfo. Pdfinfo va permettre de récuperer le numero pages de chaque pdfs. C'est sortie sont envoyer vers null pour éviter d'encombrer le terminal de l'utilisateur. Mais pourquoi utiliser pdfinfo, juste pour récuperer le numero de pages ? tous simple, si l'utilisateur veut récuperer sur deux pdf la page 2 à 5. Sur l'un des pdfs, il aura 6 pages donc cela passera. Cependant du le second, il n'y a que 4 pagges. Sa va créer une erreur car pdftk ne peut pas récuperer de pages qui n'existe pas. Donc récupèrer le nombre de page va nous permettre de regler ce probleme plus loin dans le programme.

```adjusted_pages="",``` on créer une variable vide ou on mettra uniquement les pages/plages valides à extraire.
```for part in $pages; do``` se for permet de regarder, l'entrer que l'utilisateur a mmis.
```if [[ "$part" =~ ^([0-9]+)-([0-9]+)$ ]]; then``` si dans l'entrer, l'utilisateur a mis une plage, on vérifie si elle est valides. Si elle contient bien un numero, un tirer et un autre numero coller. Si, on remplis cette condition. Nous somme dans une plage.  $part est tout expression régulière car elle contient la plage s'il y en à une.

```start=${BASH_REMATCH[1]}``` et ```end=${BASH_REMATCH[2]}``` BASH_REMATCH contient les parties capturées par l’expression régulière. 1 et 2, sont le début et la fin d'une plage. 

```
if (( end > total_pages )); then
    end=$total_pages
fi
```
voila à quoi sert pdfinfo en pratique. Car si, on le met pas, on aura un erreur disant qu'on à pas pu extraire la page car la plage n'était pas bonne. Comme mon exemples avec les deux pdfs. Mais ! grâce au faite qu'on récupère le nombre total de page dans les pdfs avec pdfinfo, on peut remplacer la fin de la plage par le nombre maximun de page identifier. Donc au lieux d'avoir une erreur et de ne pas pouvoir extraire les pages. On aura les pages 2 à 5 de mon pdf de 6 pages vu précedement mais aussi les pages 2 à 4 de mon pdf de 4 pages, on à ajuster la fin de la plage avec le nombre totale de page récuperer par pdfinfo.  


```
# Ajouter seulement si la plage est valide
if (( start <= end && start <= total_pages )); then
   adjusted_pages+="$start-$end "
fi
```

Pour être sur que la plage reste valide dans tout les cas, on la test avec ce fonction if. Qui va vérifier si le début(start) est bien plus petit que la fin(end) ou le nombre de page total. Puis on rajoute à la variable adjusted_pages.

```
# Page unique
if (( part <= total_pages )); then
    adjusted_pages+="$part "
fi
```

Puis, si c'est pas une plage mais une page simple donc un numero, on vérife que cette dernière existe dans le pdf. Et on le rajoute dans la vairable. 

```
        if [[ -z "$adjusted_pages" ]]; then
            echo "Aucune page valide à extraire dans $pdf_input"
            continue
        fi
```
Test la variable pour savoir si elle est vide. Puis si aucune page que l'utilisateur à renseigner correspont au pdf alors on affiche le message suivant qui prévient l'utilisateur qu'il na pas trouver la page dans le pdf et continue avec les autres pdfs. 

```
        pdf_output="temp_${pdf_input%.pdf}.pdf"
        pdftk "$pdf_input" cat $adjusted_pages output "$pdf_output" 2>/dev/null
```

```pdf_output="temp_${pdf_input%.pdf}.pdf"``` on renome le nom du fichier car il vont nous servir de ficher temporaire avant la fusion. 
```pdftk "$pdf_input" cat $adjusted_pages output "$pdf_output" 2>/dev/null``` puis avec pdftk, on viens extraire les pages qu'on souhaites et qui vont être inscérer dans les pdfs qu'on à renomer.  on fait une redirection pour éviter tout affichage de bug ou autre qui génerer le terminal de l'utilisateur. 

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

Puis on, vérifie si tout c'est bien dérouller. Si le fichier temporaire c'est bien créer. sinon on affiche une erreur. Voici le dernier, segment de code qui termine l'option P. 


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

Déjà, si l'option est choisi. On demande le mot clé que l'utilisateur recherche et on demande si, il veut ignorer ou non les majuscules/minucusles. 
Si, l'utilisateur choisi d'ignorer la différence de lettre. Alors on rajoutera l'arguement -i qui permettra de ne pas faire la diférence entre majuscules ou minuscules. Si c'est l'inverse, on fera la différence.

```
    for pdf_input in "${pdfs[@]}"; do
        echo "Recherche du mot-clé '$keyword' dans $pdf_input..."

        pages=$(pdfgrep -n $grep_option "$keyword" "$pdf_input" 2>/dev/null | cut -d: -f1 | sort -n | uniq)
```

```for pdf_input in "${pdfs[@]}"; do``` boucle for pour regarder dans tout les fichiers pdfs. 
```echo "Recherche du mot-clé '$keyword' dans $pdf_input..."``` on prévient ensuite l'utilisateur de quel mot clé, on cherche dans quel pdf. 
```pages=$(pdfgrep -n $grep_option "$keyword" "$pdf_input" 2>/dev/null | cut -d: -f1 | sort -n | uniq)``` puis on utilise pdfgrep, qui permet donc de chercher le mot-clé dans le fichier pdf. On affichie le numéro de page ou il apparait avec "-n". Si nous avions le grep_option avec "-i", on ignorer les majuscules et minuscules sinon, on fait la différence. on fait une redirection pour éviter les erreurs ou les messages parasite dans le terminal.
```cut -d: -f1 ``` cette option permet de garder seulement les numéros de pages. 
```sort -n``` puis avec cette option on trie les numéros de pages dans l’ordre croissant.
```uniq``` puis avec cette option on supprime les doublons.


```

        if [[ -z "$pages" ]]; then
            echo "Aucun résultat trouvé dans $pdf_input"
            continue
        fi
```
On teste la varialbe, pour savoir si elle est vide. si c'est le cas, on dit alors que nous avions rien trouver. 

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

Puis comme dans l'option P, on vient renommer les pdfs pour enfaire des pdfs temporaires ou on mettra les pages extraites. Puis si tout c'est bien dérouler, on viens prévenir l'utilisateur. 

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

```if [[ ${#pdf_creer[@]} -gt 0 ]]; then``` on regarde s'il y a au moins 1 fichier créer par rapport a l'extraction des pdfs via l'option p ou m/
```pdftk "${pdf_creer[@]}" cat output "$pdf_final" 2>/dev/null``` puis avec cette commande, on va mettre chaque pdf temporaire créer dans le pdf final dont l'utilisateur a nommer au tout début. Et pour eviter les messages parasites, on fait une redirection des erreurs. 

```
echo "Création du fichier en cours..."
echo "Fichier final créé : $pdf_final"  
```
Puis on informe l'utilisateur que sont fichier final c'est créer.
```
for f in "${pdf_creer[@]}"; do 
    [[ -f "$f" ]] && rm "$f"
```
Et si tout c'est bien dérouler, on viens supprimer les fichiers temporaire générer par l'extraction des pages. Car ces derniers prenent de la places inutilement vu qu'on les fussionnes à la fin.

```echo "Aucun fichier n’a été généré (vérifiez vos mots-clés ou pages)."``` de plus. si il na pas pu créer le ficher par manque de pdf ou autre le script le dira à l'utilisateur avec se message. 