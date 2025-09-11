#!/bin/bash

echo "=== Vérification des dépendances pour le programme PDF ==="

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
        echo "La commande '$cmd' est manquante."
    fi
done

# Installer les paquets manquants si nécessaire
if [ ${#missing[@]} -eq 0 ]; then
    echo "Toutes les dépendances sont déjà installées."
else
    echo "Les paquets suivants vont être installés : ${missing[*]}"
    
    # Demander confirmation
    read -p "Voulez-vous continuer avec l'installation ? [o/N] : " choice
    if [[ "$choice" =~ ^[oO]$ ]]; then
        sudo apt update
        sudo apt install -y "${missing[@]}"
        echo "Installation terminée."
    else
        echo "Installation annulée. Le programme ne fonctionnera pas sans ces paquets."
        exit 1
    fi
fi

