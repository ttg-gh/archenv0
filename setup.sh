#!/bin/bash

set -e

echo "🔧 Arch 개발 환경 셋업 시작..."

# ----------------------------------------
# 1. yay 설치 확인 및 설치
# ----------------------------------------

sudo pacman -Syu --noconfirm

if ! command -v yay &> /dev/null; then
    echo "📦 yay가 설치되어 있지 않습니다. 설치 중..."
    sudo pacman -S --needed --noconfirm git base-devel

    tempdir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tempdir/yay"
    (cd "$tempdir/yay" && makepkg -si --noconfirm)
    rm -rf "$tempdir"
else
    echo "✅ yay가 이미 설치되어 있습니다."
fi
yay -Syu --noconfirm
# ----------------------------------------
# 2. 패키지 목록 읽기
# ----------------------------------------
cd "$(dirname "$0")"

PACMAN_PACKAGES=()
AUR_PACKAGES=()

if [ -f ./pacman.txt ]; then
    mapfile -t PACMAN_PACKAGES < ./pacman.txt
fi

if [ -f ./aur.txt ]; then
    mapfile -t AUR_PACKAGES < ./aur.txt
fi

# ----------------------------------------
# 3. Pacman 패키지 설치
# ----------------------------------------
echo "📦 Pacman 패키지 설치 중..."
for pkg in "${PACMAN_PACKAGES[@]}"; do
    if ! pacman -Qq "$pkg" &>/dev/null; then
        sudo pacman -S --noconfirm "$pkg"
    else
        echo "✅ $pkg (이미 설치됨)"
    fi
done

# ----------------------------------------
# 4. AUR 패키지 설치
# ----------------------------------------
echo "📦 AUR 패키지 설치 중..."
for pkg in "${AUR_PACKAGES[@]}"; do
    if ! yay -Qq "$pkg" &>/dev/null; then
        yay -S --noconfirm "$pkg"
    else
        echo "✅ $pkg (이미 설치됨)"
    fi
done

# ----------------------------------------
# 5. 기존 설정 제거 (지정된 경로만)
# ----------------------------------------
echo "🧹 기존 설정 파일 제거 중..."

TARGETS=(
    "$HOME/.bashrc"
    "$HOME/.config"
)

for target in "${TARGETS[@]}"; do
    if [ -e "$target" ]; then
        echo "⚠️  삭제: $target"
        rm -rf "$target"
    fi
done
mkdir -p "$HOME/.config"
# ----------------------------------------
# 6. dotfiles 적용 (stow)
# ----------------------------------------
echo "🔗 dotfiles 심볼릭 링크 설정 중..."
cd "$(dirname "$0")/dotfiles"

for dir in */; do
    stow -v --restow "$dir"
done

echo "✅ 모든 설정 완료!"
cd
