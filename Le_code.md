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
Cette partie fait exactement, comme ce qui est présenter dans le point Setup.sh. Cependant au lieu 

```
# Demander les fichiers PDF
read -p "Entrez le(s) nom(s) de fichier(s) PDF (séparés par des espaces) ou tapez 'all' pour tout prendre : " -a input_files

# Demander si on veut extraire par pages OU par mots-clés
read -p "Voulez-vous extraire par (p)ages ou par (m)ot-clé ? [p/m] : " mode

# Nom du fichier final
read -p "Comment se nommera le fichier final ? " pdf_final
```
```
# Si l'utilisateur veut tous les PDFs du dossier
if [[ "${input_files[0]}" == "all" ]]; then
    pdfs=( *.pdf )
else
    pdfs=( "${input_files[@]}" )
fi
```
```
# Vérifier l'extension du fichier final
if [[ "$pdf_final" != *.pdf ]]; then
    pdf_final="${pdf_final}.pdf"
fi
```
```
# Tableau pour stocker les PDFs temporaires
pdf_creer=()
```
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

        if [[ -z "$adjusted_pages" ]]; then
            echo "Aucune page valide à extraire dans $pdf_input"
            continue
        fi

        pdf_output="temp_${pdf_input%.pdf}.pdf"
        pdftk "$pdf_input" cat $adjusted_pages output "$pdf_output" 2>/dev/null
        if [[ -f "$pdf_output" ]]; then
            echo "Pages $adjusted_pages de $pdf_input extraites vers $pdf_output"
            pdf_creer+=("$pdf_output")
        else
            echo "Erreur : impossible d’extraire depuis $pdf_input"
        fi
    done
fi
```
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

    for pdf_input in "${pdfs[@]}"; do
        echo "Recherche du mot-clé '$keyword' dans $pdf_input..."

        pages=$(pdfgrep -n $grep_option "$keyword" "$pdf_input" 2>/dev/null | cut -d: -f1 | sort -n | uniq)

        if [[ -z "$pages" ]]; then
            echo "Aucun résultat trouvé dans $pdf_input"
            continue
        fi

        pdf_output="temp_${pdf_input%.pdf}.pdf"
        pdftk "$pdf_input" cat $pages output "$pdf_output" 2>/dev/null
        if [[ -f "$pdf_output" ]]; then
            echo "Pages $pages de $pdf_input extraites vers $pdf_output"
            pdf_creer+=("$pdf_output")
        fi
    done
fi
```
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

