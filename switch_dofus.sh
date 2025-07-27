#!/bin/bash

# Fichier temporaire pour mémoriser la dernière fenêtre activée
STATE_FILE="/tmp/dofus_window_index"

# Récupérer toutes les fenêtres "Dofus" d'abord par leur ID, puis par leur nom "Dofus-"
WINDOWSCHECK=($(wmctrl -l | grep "Dofus" | awk '{print $1}'))
WINDOWSCHECKAPPLIED=($(wmctrl -l | grep "Dofus-" | awk '{print $4}'))

# A mettre par rapport l'ordre d'ini
WINDOWS=('Enu' 'Eni' 'Panda' 'Crâ')

# Vérifier qu’on a trouvé des fenêtres, si non on les renommes
if [[ ${#WINDOWSCHECK[@]} -ne 0 && ${#WINDOWSCHECKAPPLIED[@]} -lt 1 ]]; then
    COUNT=0

    # A mettre par rapport à l'ordre de login
    CLASS=('Crâ' 'Eni' 'Enu' 'Panda')
    
    for WinDof in ${WINDOWSCHECK[@]}
    do
	wmctrl -ir "$WinDof" -N "Dofus-${CLASS[$COUNT]}"
	COUNT=$((COUNT+1))
    done	
fi

# Lire l’index précédent ou démarrer à 0
if [ -f "$STATE_FILE" ]; then
    INDEX=$(cat "$STATE_FILE")
    INDEX=$(( (INDEX + 1) % ${#WINDOWS[@]} ))
else
    INDEX=0
fi

# Activer la fenêtre par rapport au nom de classe sur "WINDOWS"
wmctrl -a "Dofus-${WINDOWS[$INDEX]}"

# Sauvegarder l’index sur /tmp
echo "$INDEX" > "$STATE_FILE"
