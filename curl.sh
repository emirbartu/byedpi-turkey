#!/bin/bash

set -e

if [[ ! -f /bin/git ]]; then
    echo "sisteminizde 'git' bulunamadi."
    echo "otomatik olarak kuruluyor... lutfen sudo sifresi isterse girin."
    if [[ -f /bin/pacman ]]; then
        sudo pacman -S git
    fi

    if [[ -f /bin/dnf ]]; then
        sudo dnf install git
    fi

    if [[ -f /bin/apt ]]; then
        sudo apt install git
    fi
fi

if [[ -d /home/$USER/.local/share/byedpi-turkey ]]; then
    rm -r /home/$USER/.local/share/byedpi-turkey
fi

git clone https://github.com/elrondforwin/byedpi-turkey.git ~/.local/share/byedpi-turkey
