#!/bin/bash

# Demander les fichiers PDF
read -p "Entrez le(s) nom(s) de fichier(s) PDF (séparés par des espaces) ou tapez 'all' pour tout prendre : " -a input_files

# Demander si on veut extraire par pages OU par mots-clés
read -p "Voulez-vous extraire par (p)ages ou par (m)ot-clé ? [p/m] : " mode

# Nom du fichier final
read -p "Comment se nommera le fichier final ? " pdf_final

# Si l'utilisateur veut tous les PDFs du dossier
if [[ "${input_files[0]}" == "all" ]]; then
    pdfs=( *.pdf )
else
    pdfs=( "${input_files[@]}" )
fi

# Vérifier l'extension du fichier final
if [[ "$pdf_final" != *.pdf ]]; then
    pdf_final="${pdf_final}.pdf"
fi

# Tableau pour stocker les PDFs temporaires
pdf_creer=()

# Mode extraction par pages
if [[ "$mode" == "p" ]]; then
    read -p "Saisissez le(s) page(s) à récupérer (ex: 1-3 5 7) : " pages

    for pdf_input in "${pdfs[@]}"; do
        pdf_output="temp_${pdf_input%.pdf}.pdf"
        pdftk "$pdf_input" cat $pages output "$pdf_output"
        echo "Pages $pages de $pdf_input extraites vers $pdf_output"
        pdf_creer+=("$pdf_output")
    done
fi

# Mode extraction par mot-clé avec pdfgrep
if [[ "$mode" == "m" ]]; then
    read -p "Entrez le mot-clé à rechercher : " keyword

    for pdf_input in "${pdfs[@]}"; do
        echo "Recherche du mot-clé '$keyword' dans $pdf_input..."
        
        # Récupérer les numéros de pages où le mot apparaît
        pages=$(pdfgrep -n "$keyword" "$pdf_input" | cut -d: -f1 | sort -n | uniq)

        if [[ -z "$pages" ]]; then
            echo "⚠ Aucun résultat trouvé dans $pdf_input"
            continue
        fi

        echo "Mot-clé trouvé aux pages : $pages"
        pdf_output="temp_${pdf_input%.pdf}.pdf"
        pdftk "$pdf_input" cat $pages output "$pdf_output"
        echo "Pages contenant '$keyword' extraites vers $pdf_output"
        pdf_creer+=("$pdf_output")
    done
fi

# Fusionner les fichiers extraits
if [[ ${#pdf_creer[@]} -gt 0 ]]; then
    pdftk "${pdf_creer[@]}" cat output "$pdf_final"
    echo "✅ Fichier final créé : $pdf_final"
    rm "${pdf_creer[@]}" # suppression des fichiers temporaires
else
    echo "❌ Aucun fichier n’a été généré (vérifiez vos mots-clés ou pages)."
fi

