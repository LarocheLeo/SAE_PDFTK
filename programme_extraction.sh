#!/bin/bash



read -p "Entrez le(s) nom(s) de fichier(s) PDF (séparés par des espaces) ou tapez 'all' pour tout prendre : " -a input_files
read -p "saissez le(s) page(s) à récupérer :" pages #on récupérer les pages que l'utilisateur veux 
read -p "comment se nommera le fichier final ?" pdf_final #demander le nom que l'user veut pour le fichier

if [[ "${input_files[0]}" == "all" ]] #un if pour voir si, nous devons sélection tout les pdfs ou seulement certains.
then
    pdfs=( *.pdf )
else
    pdfs=( "${input_files[@]}" )
fi


nbr_fichier=${#pdfs[@]} #on compte le nombre de pdf qu'on récupère


for (( i=0; i<nbr_fichier; i++ )) #fonction qui permet de récupéré les pages voulus 
do 
    pdf_input="${pdfs[i]}"
    pdf_output="test_programme_$((i+1)).pdf"

    pdftk "$pdf_input" cat $pages output "$pdf_output"
    echo "Page $pages de $pdf_input extraite vers $pdf_output"
done


pdf_creer=( test_programme_*.pdf )


if [[ "$pdf_final" != *.pdf ]] # une fonction pour voir s'il y a l'extension pdf sinon le rajouter
then
    pdf_final="${pdf_final}.pdf"
fi

pdftk "${pdf_creer[@]}" cat output $pdf_final #fusion des fichiers en un 

rm ${pdf_creer[@]} #supprision des fichiers temporaire
