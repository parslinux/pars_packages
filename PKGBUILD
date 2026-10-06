# Maintainer: Pars Development Team
pkgname=pars
pkgver=7.1.0
pkgrel=1
pkgdesc="Pars Linux Paket Yöneticisi - Hizli, Guvenli, Asla Yolda Birakmayan"
arch=('x86_64')
url="https://parslinux.org"
license=('GPL2')
depends=('libarchive' 'curl' 'gpgme' 'bash' 'glibc')
provides=('pacman')
conflicts=('pacman')
replaces=('pacman')
backup=('etc/pars.conf' 'etc/pars.d/mirrorlist')

# Kaynak olarak az önce oluşturduğumuz arşivi göster
source=("$pkgname-$pkgver.tar.gz")

build() {
    cd "$srcdir/$pkgname-$pkgver"
    echo "Derlenmis build klasoru hazir, kontrol ediliyor..."
    ls -d build || echo "HATA: build klasoru bulunamadi!"
}

package() {
    cd "$srcdir/$pkgname-$pkgver"
    
    # 1. Meson ile kurulum
    DESTDIR="$pkgdir" meson install -C build
    
    # 2. Varsayilan Config
    install -Dm644 build/pars.conf "$pkgdir/etc/pars.conf"
    
    # 3. Mirrorlist
    install -d "$pkgdir/etc/pars.d"
    cat > "$pkgdir/etc/pars.d/mirrorlist" << 'MIRROR'
# Pars Linux Varsayilan Yansi Listesi
Server = https://mirror.veriteknik.net.tr/archlinux/\$repo/os/\$arch
Server = https://ftp.linux.org.tr/archlinux/\$repo/os/\$arch
MIRROR
    
    # 4. Btrfs Hook
    install -Dm644 hooks/pars-btrfs-snapshot.hook "$pkgdir/usr/share/libalpm/hooks/pars-btrfs-snapshot.hook"
    install -Dm755 hooks/pars-snapshot.sh "$pkgdir/usr/share/pars/hooks/pars-snapshot.sh"
}
sha256sums=('SKIP')
