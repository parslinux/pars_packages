#!/bin/bash
# ==========================================================
#  PARS BTRFS SNAPSHOT HOOK - TEK DOSYA KURULUM SCRIPT'İ
#  Çalıştır: sudo ./install-pars-snapshot.sh
# ==========================================================

set -e

# Renkler
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}🐆 Pars Btrfs Snapshot Hook Kurulumu Başlatılıyor...${NC}"
echo ""

# Root kontrolü
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Hata: Bu scripti sudo ile çalıştırmalısın!${NC}"
    exit 1
fi

# ==========================================================
# 1. HOOK DOSYASINI OLUŞTUR
# ==========================================================
echo -e "${YELLOW}📝 Hook dosyası oluşturuluyor...${NC}"

mkdir -p /usr/share/libalpm/hooks

cat > /usr/share/libalpm/hooks/pars-btrfs-snapshot.hook << 'EOF'
[Trigger]
Operation = Install
Operation = Upgrade
Operation = Remove
Type = Package
Target = *

[Action]
Description = 🛡️ Pars: Güncelleme öncesi Btrfs snapshot alınıyor...
When = PreTransaction
Exec = /usr/share/pars/hooks/pars-snapshot.sh
AbortOnFail
EOF

echo -e "${GREEN}  ✓ Hook dosyası oluşturuldu: /usr/share/libalpm/hooks/pars-btrfs-snapshot.hook${NC}"

# ==========================================================
# 2. SNAPSHOT SCRIPT'İNİ OLUŞTUR
# ==========================================================
echo -e "${YELLOW}📝 Snapshot script'i oluşturuluyor...${NC}"

mkdir -p /usr/share/pars/hooks

cat > /usr/share/pars/hooks/pars-snapshot.sh << 'EOF'
#!/bin/bash
# ==========================================================
#  PARS BTRFS SNAPSHOT HOOK SCRIPT
#  Güncelleme öncesi otomatik yedekleme
# ==========================================================

set -e

# Yapılandırma
SNAPSHOT_DIR="/.snapshots"
MAX_SNAPSHOTS=10
LOG_FILE="/var/log/pars-snapshot.log"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
SNAPSHOT_NAME="pars-pre-update-$TIMESTAMP"

# Log fonksiyonu
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Btrfs mi kontrol et
if ! command -v btrfs &> /dev/null; then
    log "⚠️  Btrfs yüklü değil, snapshot alınamadı"
    exit 0
fi

# Kök dizin Btrfs mi kontrol et
ROOT_FS=$(df -T / | tail -1 | awk '{print $2}')
if [ "$ROOT_FS" != "btrfs" ]; then
    log "⚠️  Kök dizin Btrfs değil ($ROOT_FS), snapshot alınamadı"
    exit 0
fi

# Snapshot dizinini oluştur
if [ ! -d "$SNAPSHOT_DIR" ]; then
    log "📁 Snapshot dizini oluşturuluyor: $SNAPSHOT_DIR"
    mkdir -p "$SNAPSHOT_DIR"
fi

# Snapshot al
log "📸 Snapshot alınıyor: $SNAPSHOT_NAME"
if btrfs subvolume snapshot -r / "$SNAPSHOT_DIR/$SNAPSHOT_NAME" > /dev/null 2>&1; then
    log "✅ Snapshot başarıyla alındı: $SNAPSHOT_DIR/$SNAPSHOT_NAME"
else
    log "❌ HATA: Snapshot alınamadı!"
    exit 1
fi

# Eski snapshot'ları temizle
SNAPSHOT_COUNT=$(ls -1 "$SNAPSHOT_DIR" 2>/dev/null | grep "pars-pre-update" | wc -l)
if [ "$SNAPSHOT_COUNT" -gt "$MAX_SNAPSHOTS" ]; then
    log "🧹 Eski snapshot'lar temizleniyor (Son $MAX_SNAPSHOTS tutulacak)"
    ls -1t "$SNAPSHOT_DIR" | grep "pars-pre-update" | tail -n +$((MAX_SNAPSHOTS + 1)) | while read -r old_snapshot; do
        log "  🗑️  Siliniyor: $old_snapshot"
        btrfs subvolume delete "$SNAPSHOT_DIR/$old_snapshot" > /dev/null 2>&1
    done
fi

log "🎉 Snapshot işlemi tamamlandı"
exit 0
EOF

chmod +x /usr/share/pars/hooks/pars-snapshot.sh
echo -e "${GREEN}  ✓ Snapshot script'i oluşturuldu: /usr/share/pars/hooks/pars-snapshot.sh${NC}"

# ==========================================================
# 3. LOG DOSYASINI OLUŞTUR
# ==========================================================
echo -e "${YELLOW}📝 Log dosyası oluşturuluyor...${NC}"

touch /var/log/pars-snapshot.log
chmod 644 /var/log/pars-snapshot.log
echo -e "${GREEN}  ✓ Log dosyası oluşturuldu: /var/log/pars-snapshot.log${NC}"

# ==========================================================
# 4. KURULUM ÖZETİ
# ==========================================================
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}✅ Kurulum Tamamlandı!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "${BLUE}📌 Oluşturulan Dosyalar:${NC}"
echo "   • /usr/share/libalpm/hooks/pars-btrfs-snapshot.hook"
echo "   • /usr/share/pars/hooks/pars-snapshot.sh"
echo "   • /var/log/pars-snapshot.log"
echo ""
echo -e "${BLUE}🧪 Test Etmek İçin:${NC}"
echo -e "   ${YELLOW}1. Manuel test:${NC}"
echo "      sudo /usr/share/pars/hooks/pars-snapshot.sh"
echo ""
echo -e "   ${YELLOW}2. Log'u kontrol et:${NC}"
echo "      cat /var/log/pars-snapshot.log"
echo ""
echo -e "   ${YELLOW}3. Snapshot'ları listele:${NC}"
echo "      sudo btrfs subvolume list /.snapshots"
echo ""
echo -e "   ${YELLOW}4. Gerçek güncelleme testi:${NC}"
echo "      sudo pars -Syu"
echo ""
echo -e "${BLUE}🔄 Geri Alma (Rollback) İçin:${NC}"
echo "   1. Bilgisayarı yeniden başlat"
echo "   2. GRUB menüsünden 'Pars - Rollback' seç"
echo "   3. Veya Live USB ile boot et ve:"
echo "      sudo btrfs subvolume delete /"
echo "      sudo btrfs subvolume snapshot /.snapshots/pars-pre-update-TIMESTAMP /"
echo "      sudo reboot"
echo ""
echo -e "${GREEN}🎉 Pars artık 'yolda bırakmayan' bir sistem!${NC}"