#!/bin/bash
set -e
GREEN='\033[0;32m'
NC='\033[0m'
echo -e "${GREEN}🐆 Pars Paketleme Baslatiliyor...${NC}"
if [ ! -f "build/pars" ]; then
    echo "Hata: build/pars bulunamadi. Once derleme yapin."
    exit 1
fi
if [ ! -f "PKGBUILD" ]; then
    echo "Hata: PKGBUILD bulunamadi."
    exit 1
fi
makepkg -f
echo ""
echo -e "${GREEN}✅ PAKETLEME TAMAMLANDI!${NC}"
ls -lh pars-*.pkg.tar.*
