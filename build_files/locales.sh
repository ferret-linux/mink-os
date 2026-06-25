#!/bin/bash
set -eoux pipefail

# Nerd Fonts
NERD_VERSION="$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | jq -r '.tag_name')"

curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_VERSION}/Hack.tar.xz" \
  -o /tmp/Hack.tar.xz
curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_VERSION}/NerdFontsSymbolsOnly.tar.xz" \
  -o /tmp/NerdFontsSymbolsOnly.tar.xz

mkdir -p /usr/share/fonts/hack-nerd-font
mkdir -p /usr/share/fonts/nerd-fonts-symbols-only

tar -xf /tmp/Hack.tar.xz -C /usr/share/fonts/hack-nerd-font
tar -xf /tmp/NerdFontsSymbolsOnly.tar.xz -C /usr/share/fonts/nerd-fonts-symbols-only

rm -f /tmp/Hack.tar.xz /tmp/NerdFontsSymbolsOnly.tar.xz
fc-cache -f /usr/share/fonts/

# Fonts & Language Packs
dnf install -y --setopt=install_weak_deps=False \
  harfbuzz \
  stix-fonts \
  langpacks-en \
  unicode-emoji \
  cracklib-dicts \
  langpacks-core-en \
  langpacks-fonts-en \
  glibc-all-langpacks \
  glibc-locale-source \
  liberation-fonts-all \
  google-noto-emoji-fonts \
  google-noto-sans-vf-fonts \
  google-noto-serif-vf-fonts \
  google-noto-sans-cjk-vf-fonts \
  google-noto-color-emoji-fonts \
  google-noto-sans-thai-vf-fonts \
  google-noto-sans-arabic-vf-fonts \
  google-noto-sans-hebrew-vf-fonts \
  google-noto-sans-devanagari-vf-fonts