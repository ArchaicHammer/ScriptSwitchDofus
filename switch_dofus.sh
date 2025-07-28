#!/bin/bash

######################################
#    Fait par Vieil-Ours             #
#                                    #
#    Paquet necéssaires :            #
#    wmctrl		 	     #
#    xprop			     #
#    pactl			     #
######################################

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

    # Permet d'exclure la fenêtre qui ne sera pas mute
    EXCLUS="Dofus-Crâ"

    # Liste toutes les fenêtres Dofus sauf celle à garder
    wmctrl -l | grep "Dofus-" | grep -v "$EXCLUS" | while read -r line; do
       win_id=$(echo "$line" | awk '{print $1}')
       pid=$(xprop -id "$win_id" | grep "_NET_WM_PID" | awk '{print $3}')

       if [[ -n "$pid" ]]; then
         # Parcours des entrées de destination et on mute
         pactl list sink-inputs | awk "/Entrée de la destination/ {entry=\$0} /application.process.id = \"$pid\"/ {print entry}" | grep "Entrée de la destination #" | while read -r entry; do
            input_id=$(echo "$entry" | grep -oE '[0-9]+')
            pactl set-sink-input-mute "$input_id" 1
        done
     fi
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
