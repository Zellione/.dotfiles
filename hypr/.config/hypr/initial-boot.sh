#!/bin/bash

# Variables
scriptsDir="$HOME/.config/hypr/scripts"
wallpaper="$HOME/wallpapers/CyberpunkLucy.jpg"

swww="swww img"
effect="--transition-bezier .43,1.19,1,.4 --transition-fps 30 --transition-type grow --transition-pos 0.925,0.977 --transition-duration 2"

# check if a marker file exists
if [ ! -f ~/.config/hypr/.initial_startup_done ]; then
    # Initialize pywal and wallpaper
	if [ -f "$wallpaper" ]; then
		wal -i $wallpaper -s -t > /dev/null
		swww init && $swww $wallpaper $effect
	    "$scriptsDir/pywal_swww.sh" > /dev/null 2>&1 &
	fi

    # Initial symlink for Pywal Dark and Light for Rofi Themes
    ln -sf "$HOME/.cache/wal/colors-rofi-dark.rasi" "$HOME/.config/rofi/pywal-color/pywal-theme.rasi" > /dev/null 2>&1 &

    # initiate GTK dark mode and apply icon and cursor theme
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark > /dev/null 2>&1 &
    gsettings set org.gnome.desktop.interface gtk-theme Tokyonight-Dark-BL-LB > /dev/null 2>&1 &
    gsettings set org.gnome.desktop.interface icon-theme Tokyonight-Dark > /dev/null 2>&1 &
    gsettings set org.gnome.desktop.interface cursor-theme Bibata-Modern-Ice > /dev/null 2>&1 &
    gsettings set org.gnome.desktop.interface cursor-size 24 > /dev/null 2>&1 &

    "scriptsDir/switch_keyboard_layout.sh" > /dev/null 2>&1 &

    exit
fi
