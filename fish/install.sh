#!/bin/sh
#
# Installs a simple file in ~/.config/fish/config.fish that sources the
# ~/.fishrc

type fish >/dev/null 2>&1 || { echo "fish not installed"; exit; }

file=".fishrc"
target="$HOME/.config/fish/config.fish"

if [ -e "$target" ] || [ -h "$target" ]; then
    overwrite=false
    backup=false

    while true; do
        echo "$target already exists"
        read -p "[s]kip, [o]verwrite, [b]ackup " answer
        case $answer in
            "s" ) exit;;
            "o" ) overwrite=true; break;;
            "b" ) backup=true; break;;
            *   ) continue ;;
        esac
    done

    if $overwrite; then
        rm $target
    fi

    if $backup; then
        mv $target "$HOME/.config/fish/config.backup"
    fi
fi

echo "Installing $target"
mkdir -p $(dirname $target)
ln -s "$PWD/fish/$file" "$target"
