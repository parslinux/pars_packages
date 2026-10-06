#!/bin/bash
# ==========================================================
#  PACMAN -> PARS REBRANDING SCRIPT (v3 - Basitleştirilmiş)
# ==========================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🐆 Pars Rebranding Script v3 Başlatılıyor...${NC}"

# 1. Dosya İÇERİKLERİNİ değiştir (en güvenli yöntem)
echo -e "${YELLOW}📝 Dosya içerikleri değiştiriliyor...${NC}"

# C, H, conf, txt, md, meson, in dosyalarında değiştir (libalpm hariç)
find . -type f \( -name "*.c" -o -name "*.h" -o -name "*.conf" -o -name "*.txt" -o -name "*.md" -o -name "meson.build" -o -name "*.in" \) -not -path "*/libalpm/*" -not -path "*/backup-*" -exec sed -i \
    -e 's/\bpacman\b/pars/g' \
    -e 's/\bPacman\b/Pars/g' \
    -e 's/\bPACMAN\b/PARS/g' \
    -e 's|/etc/pacman\.conf|/etc/pars.conf|g' \
    -e 's|/var/lib/pacman|/var/lib/pars|g' \
    -e 's|/var/cache/pacman|/var/cache/pars|g' \
    -e 's|/usr/share/pacman|/usr/share/pars|g' \
    {} +

echo -e "${GREEN}  ✓ Dosya içerikleri güncellendi${NC}"

# 2. ÖNCE DİZİN İSİMLERİNİ değiştir (en derinden başla)
echo -e "${YELLOW}📂 Dizin isimleri değiştiriliyor...${NC}"

find . -type d -name "*pacman*" -not -path "*/libalpm*" -not -path "*/backup-*" | sort -r | while read -r dir; do
    newname=$(echo "$dir" | sed 's/pacman/pars/g')
    mv "$dir" "$newname"
    echo "  📂 $dir -> $newname"
done

# 3. SONRA DOSYA İSİMLERİNİ değiştir
echo -e "${YELLOW}📁 Dosya isimleri değiştiriliyor...${NC}"

find . -type f -name "*pacman*" -not -path "*/libalpm/*" -not -path "*/backup-*" | while read -r file; do
    newname=$(echo "$file" | sed 's/pacman/pars/g')
    mv "$file" "$newname"
    echo "  ✓ $file -> $newname"
done

# 4. Özet
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}✅ Dönüşüm Tamamlandı!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo "🔨 Şimdi derlemek için:"
echo "   meson setup build"
echo "   meson compile -C build"
