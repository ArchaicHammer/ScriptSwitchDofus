#!/bin/bash

######################################
#    Fait par Vieil-Ours             #
#                                    #
#  Permet l'installation et l'       #
#  utilisation de dofusguide sous    #
#  linux à travers wine (avec bottle)#
######################################


DEPS_DOFUSGUIDE_WINE=(
  'd3dx9'
  'msis31'
  'arial32'
  'times32'
  'courie32'
  'd3dcompiler_43'
  'd3dcompiler_47'
  'mono'
  'gecko'
  'dotnet40'
  'dotnet48'
  'dotnetcoredesktop6'
  'vcredist2019'
  'webview2'
  'winttp'
  'dotnetcoredesktop8'
  'ie8_kb2936068'
  'mediafoundation'
  'msxml6'
  'wsh57'
  'amstream'
  'd3dcompiler_46'
  'd3dx11'
  'dmband'
  'dmcompos'
  'dmime'
  'dmloader'
  'dmscript'
  'dmstyle'
  'dmsynth'
  'dmusic'
  'dmusic32'
  'dsound'
  'dswave'
  'directmusic'
  'directplay'
  'qasf'
  'qcap'
  'qdvd'
  'qedit'
  'quartz'
  'directshow'
  'l3codecx'
  'mfc42'
  'powershell_core'
  'powershell'
  )

# Installation de flatpack qui permettra d'installer bottles (environnement wine simplifié)
sudo apt update
sudo apt install -y flatpak
sudo apt install -y gnome-software-plugin-flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y bottles

# Création de l'environnement wine DofusGuide
flatpak run --command=bottles-cli com.usebottles.bottles new -n DofusGuide -t gaming

# Installation de toutes les dépendances
for ENV_DEPS in "${DEPS_DOFUSGUIDE_WINE[@]}"; do
    flatpak run --command=bottles-cli install-deps -b DofusGuide -d "$ENV_DEPS"
done

# Désactivation de la carte graphique dédiée dans l'env wine, de vkd3d et dxvk
flatpak run --command=bottles-cli com.usebottles.bottles settings -b DofusGuide -s vkd3d -v false
flatpak run --command=bottles-cli com.usebottles.bottles settings -b DofusGuide -s discrete_gpu -v false
flatpak run --command=bottles-cli com.usebottles.bottles settings -b DofusGuide -s dxvk -v false

# Téléchargement de DofusGuide
wget -q -O $HOME/setupDofusGuide.exe https://dofusguide.fr/uploads/windows/setup.exe

# On lance l'installation du launcher officiel de DofusGuide
flatpak run --command=bottles-cli com.usebottles.bottles run -b DofusGuide -e $HOME/setupDofusGuide.exe
