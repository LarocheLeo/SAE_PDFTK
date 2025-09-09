#!/bin/bash


pdfs=( *.pdf )
nbr_fichier=${#pdfs[@]}

for (( i=0; i<nbr_fichier; i++ )); do
    pdf_input="${pdfs[i]}"
    pdf_output="test_programme_$((i+1)).pdf"

    pdftk "$pdf_input" cat 1 output "$pdf_output"
    echo "Page 1 de $pdf_input extraite vers $pdf_output"
done
pdf_creer=( test_programme_*.pdf )
pdftk "${pdf_creer[@]}" cat output pdf_final.pdf
rm ${pdf_creer[@]}
