#!/bin/bash

######################################
#    Fait par Vieil-Ours             #
#                                    #
#  Permet l'ajout d'icone pour le    #
#  AppImage du launcher et pour le   #
#  jeu Dofus lui même sur la barre   #
#  de tâche, et ajout des icônes     #
#  dans le menu                      #
######################################

PNG_B64_DOFUS=$(cat ./dofus.png.b64)
PNG_B64_ANKAMALAUNCHER=$(cat ./ankamalauncher.png.b64)
PNG_B64_GANYMEDE=$(cat ./ganymede.png.b64)

#Ajout des icones sur le home de l'utilisateur
mkdir -p ~/.local/share/icons/
echo "${PNG_B64_DOFUS}" | base64 --decode > ~/.local/share/icons/dofus.png
echo "${PNG_B64_ANKAMALAUNCHER}" | base64 --decode > ~/.local/share/icons/ankamalauncher.png
echo "${PNG_B64_GANYMEDE}" | base64 --decode > ~/.local/share/icons/ganymede.png

#Ajout des entrées menu pour Dofus et Ankamalauncher
echo """[Desktop Entry]
Name=Dofus
Comment=Fix icon for Dofus.x64
Exec=true
Icon=$HOME/.local/share/icons/dofus.png
Terminal=false
Type=Application
StartupWMClass=Dofus.x64
NoDisplay=true""" > $HOME/.local/share/applications/dofus-icon.desktop

echo """[Desktop Entry]
Name=AnkamaLauncher
Comment=
Exec=$HOME/Applications/AnkamaLauncher/AnkamaLauncher.AppImage --no-sandbox
Icon=$HOME/.local/share/icons/ankamalauncher.png
Terminal=false
Type=Application
StartupWMClass="Ankama Launcher"
Categories=Game;
NoDisplay=false""" > $HOME/.local/share/applications/ankamalauncher.desktop

echo """[Desktop Entry]
Name=Ganymede
Comment=
Exec=$HOME/Applications/Ganymede/Ganymede.AppImage --no-sandbox
Icon=$HOME/.local/share/icons/ganymede.png
Terminal=false
Type=Application
StartupWMClass="Ganymede"
Categories=Game;
NoDisplay=false""" > $HOME/.local/share/applications/ganymede.desktop


chmod +x $HOME/.local/share/applications/dofus-icon.desktop
chmod +x $HOME/.local/share/applications/ankamalauncher.desktop
chmod +x $HOME/.local/share/applications/ganymede.desktop

#Création du dossier Application dans les dossiers personnels
mkdir -p $HOME/Applications/AnkamaLauncher/
mkdir -p $HOME/Applications/Ganymede/

#Téléchargement du launcher
wget -q -O $HOME/Applications/AnkamaLauncher/AnkamaLauncher.AppImage https://launcher.cdn.ankama.com/installers/production/Dofus%203.0-Setup-x86_64.AppImage
wget -q -O $HOME/Applications/Ganymede/Ganymede.AppImage https://github.com/GanymedeTeam/ganymede-app/releases/latest/download/Ganymede_amd64.AppImage
#On le rend executable
chmod +x $HOME/Applications/AnkamaLauncher/AnkamaLauncher.AppImage
chmod +x $HOME/Applications/Ganymede/Ganymede.AppImage

#Installation de libfuse pour pouvoir lancer les .AppImage
sudo apt update && sudo apt install -y libfuse2

update-desktop-database ~/.local/share/applications/
