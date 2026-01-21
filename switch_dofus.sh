#!/bin/bash

######################################
#    Fait par Vieil-Ours             #
#                                    #
#    Paquet necéssaires :            #
#    wmctrl		 	     #
#    xprop			     #
#    pactl			     #
######################################

# STATE_FILE type string : Fichier temporaire pour mémoriser la dernière fenêtre activée
# WINDOWS_CHECK type array de string: Récupère les fenêtres Dofus par leur ID
# WINDOWS_CHECK_APPLIED type array de string: Récupère les fenêtres Dofus par leur nom (Dofus-)
# CLASS_INI type array de string : Liste des classes par rapport à leur initiative
# CLASS_LOGIN type array de string : Liste des classes par rapport à l'ordre de connexion
# WIN_EXCLUS type string : Nom de la fenêtre à exclure pour le mute du son
# COUNT type number : Compteur pour la boucle de renom des fenêtres
#
STATE_FILE="/tmp/dofus_window_index"
WINDOWS_CHECK=($(wmctrl -l | grep "Dofus" | awk '{print $1}'))
WINDOWS_CHECK_APPLIED=($(wmctrl -l | grep "Dofus-" | awk '{print $4}'))
CLASS_INI=('Enu' 'Eni' 'Panda' 'Crâ')
CLASS_LOGIN=('Crâ' 'Eni' 'Enu' 'Panda')
WIN_EXCLUS="Dofus-Crâ"
COUNT=0

# Vérifier qu’on a trouvé des fenêtres, si non on les renommes
if [[ ${#WINDOWS_CHECK[@]} -ne 0 && ${#WINDOWS_CHECK_APPLIED[@]} -lt 1 ]]
then
    # A mettre par rapport à l'ordre de login
    for WIN_DOF in "${WINDOWS_CHECK[@]}"
    do
      wmctrl -ir "${WIN_DOF}" -N "Dofus-${CLASS_LOGIN[$COUNT]}"
      COUNT=$((COUNT+1))
    done

    # Liste toutes les fenêtres Dofus sauf celle à garder (pour le son)
    wmctrl -l | \
    grep "Dofus-" | \
    grep -v "${WIN_EXCLUS}" | \
    while read -r LINE
    do
       #
       # LINE type string : Sortie complète par ligne de la lecture de read
       # WIN_ID type string : ID de la fenêtre
       # PID type string : Numéro du processus (PID) par rapport à la fenêtre
       #
       WIN_ID=$(echo "${LINE}" | awk '{print $1}')
       PID=$(xprop -id "${WIN_ID}" | grep "_NET_WM_PID" | awk '{print $3}')

       if [[ -n "${PID}" ]]
       then
         # Parcours des entrées de destination et on mute
         pactl list sink-inputs | \
         awk "/Entrée de la destination/ {entry=\$0} /application.process.id = \"${PID}\"/ {print entry}" | \
         grep "Entrée de la destination #" | \
         while read -r ENTRY
         do
            #
            # ENTRY type string : Sortie complète par ligne de la lecture de read
            # INPUT_ID type string : Numéro de la fenêtre par rapport à sa sortie audio
            #
            INPUT_ID=$(echo "${ENTRY}" | grep -oE '[0-9]+')
            pactl set-sink-input-mute "${INPUT_ID}" 1
        done
     fi
   done
fi

# Lire l’index précédent ou démarrer à 0 (Donc le compte principal, ici Dofus-Crâ)
if [ -f "${STATE_FILE}" ]
then
    #
    # INDEX type string : Index dans le fichier tmp de la dernière fenêtre activée
    #
    INDEX=$(cat "${STATE_FILE}")
    INDEX=$(( (INDEX + 1) % ${#CLASS_INI[@]} ))
else
    INDEX=0
fi

# Activer la fenêtre par rapport au nom de classe sur "CLASS_INI"
wmctrl -a "Dofus-${CLASS_INI[$INDEX]}"

# Sauvegarder l’index sur /tmp
echo "${INDEX}" > "${STATE_FILE}"
