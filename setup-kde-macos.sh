#!/bin/bash

set -e

### Thong tin
# KDE macOS-style config script by ChatGPT
# Yeu cau: KDE Plasma, mang internet, phan quyen sudo

### Kiem tra phien ban Plasma
version=$(plasmashell --version | grep -oP '\d+\.\d+')
min_version=5.20
if (( $(echo "$version < $min_version" | bc -l) )); then
    echo "⚠️ Plasma version $version is too old. Need at least $min_version!"
    exit 1
fi

### Cai cac goi can thiet
echo ">>> Dang cai goi can thiet..."
sudo apt update
sudo apt install -y latte-dock kdeconnect git curl wget unzip \
    fonts-noto fonts-noto-cjk fonts-noto-color-emoji \
    kde-style-breeze \
    qt5-style-kvantum qt5-style-kvantum-themes \
    plasma-widgets-addons

### Tai theme tu KDE Store
mkdir -p ~/.local/share/plasma/look-and-feel
mkdir -p ~/.local/share/icons
mkdir -p ~/.local/share/aurorae/themes
mkdir -p ~/.local/share/plasma/desktoptheme
mkdir -p ~/.local/share/cursors
mkdir -p ~/.config
mkdir -p ~/.local/share/latte
mkdir -p ~/.kvantum

cd /tmp

# 1. Layan Dark theme
echo ">>> Tai Layan Dark..."
wget -qO layan.zip https://github.com/vinceliuice/Layan-kde/archive/refs/heads/master.zip
unzip -o layan.zip
cp -r Layan-kde-master/* ~/.local/share/plasma/desktoptheme/ || true

# 2. Tela icon
echo ">>> Tai Tela icon..."
rm -rf Tela-icon-theme
git clone https://github.com/vinceliuice/Tela-icon-theme.git || true
cd Tela-icon-theme
[ -f install.sh ] && bash install.sh -d ~/.local/share/icons || echo "⚠️ Không tìm thấy install.sh trong Tela-icon-theme"
cd ..

# 3. Bibata cursor
echo ">>> Tai Bibata cursor..."
rm -rf Bibata_Cursor
git clone https://github.com/ful1e5/Bibata_Cursor.git || true
cd Bibata_Cursor
[ -f install.sh ] && bash install.sh -d ~/.local/share/icons || echo "⚠️ Không tìm thấy install.sh trong Bibata_Cursor"
cd ..

# 4. Sweet Kvantum
echo ">>> Tai Sweet Kvantum..."
rm -rf Sweet
git clone https://github.com/EliverLara/Sweet.git || true
if [ -d Sweet/Kvantum ]; then
    cp -r Sweet/Kvantum/* ~/.kvantum/ || true
else
    echo "⚠️ Không tìm thấy Sweet/Kvantum, bỏ qua"
fi

### Reset theme mac dinh (neu can)
lookandfeeltool -a org.kde.breeze.desktop || true

### Cau hinh fonts va theme
lookandfeeltool -a Layan-Dark || echo "⚠️ Không tìm thấy theme Layan-Dark, bỏ qua"
plasma-apply-desktoptheme Layan-Dark || true
plasma-apply-cursortheme Bibata-Modern-Classic || true
gsettings set org.gnome.desktop.interface icon-theme "Tela-dark"
gsettings set org.gnome.desktop.interface gtk-theme "Sweet-Dark"

### Font
kwriteconfig5 --file kdeglobals --group General --key fixed "Noto Sans,10"
kwriteconfig5 --file kdeglobals --group General --key font "Noto Sans,10"

### Tu dong khoi dong Latte Dock
mkdir -p ~/.config/autostart
cp /usr/share/applications/org.kde.latte-dock.desktop ~/.config/autostart/ || true

### Lay cau hinh Latte Dock macOS-style
if [ ! -f ~/.local/share/latte/macOS.layout.latte ]; then
    echo ">>> Tai layout Latte Dock..."
    wget -O ~/.local/share/latte/macOS.layout.latte "https://raw.githubusercontent.com/psifidotos/Latte-Dock/master/layouts/macOS.layout.latte" || echo "⚠️ Không tải được layout Latte Dock"
    latte-dock --import-layout ~/.local/share/latte/macOS.layout.latte || true
fi
latte-dock &

### Thong bao hoan tat
echo -e "\n✅ Hoan tat setup KDE macOS style!"
echo "➡️ Hay logout hoac reboot de thay doi hieu luc."
echo "➡️ Latte Dock se tu dong chay. Neu khong, mo bang lenh: latte-dock &"