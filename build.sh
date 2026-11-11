#!/bin/bash
# ============================================
# Compilador AUTOMÁTICO de Git para Tiny Core i686
# ============================================
# Autor: Jose Andres Mamani Mollericona
# GitHub: JOSSEL01
# ============================================

set -e

# ============================================
# CONFIGURACIÓN
# ============================================
BUILD_DIR="$HOME/git-build"
PACKAGE_DIR="/tmp/git-package"
OUTPUT_DIR="/tmp"
VERSION_FILE="$HOME/git-version.txt"

# ============================================
# COLORES
# ============================================
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Compilador AUTOMÁTICO de Git i686${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================
# [1/9] BUSCAR LA ÚLTIMA VERSIÓN
# ============================================
echo -e "\n${YELLOW}[1/9] Buscando la última versión de Git...${NC}"

LATEST_TAG=$(curl -s "https://api.github.com/repos/git/git/tags" | grep -oP '"name": "v\K[0-9]+\.[0-9]+\.[0-9]+' | tr -d '"' | head -n 1)

if [ -z "$LATEST_TAG" ]; then
    echo -e "${RED}Error: No se pudo obtener la última versión. Usando 2.56.1 por defecto.${NC}"
    GIT_VERSION="2.56.1"
else
    GIT_VERSION="$LATEST_TAG"
fi

echo -e "${GREEN}✓ Última versión detectada: $GIT_VERSION${NC}"
echo "$GIT_VERSION" > "$VERSION_FILE"
EXTENSION_NAME="git-$GIT_VERSION"

# ============================================
# [2/9] INSTALAR DEPENDENCIAS
# ============================================
echo -e "\n${YELLOW}[2/9] Instalando dependencias...${NC}"

if [ "$EUID" -eq 0 ]; then SUDO=""; else SUDO="sudo"; fi
if command -v dnf &> /dev/null; then PKG_MANAGER="dnf"; else PKG_MANAGER="yum"; fi

PACKAGES=(
    "gcc" "gcc-c++" "make" "python3" "perl" "wget" "tar" "xz"
    "autoconf" "automake" "libtool" "gettext" "gettext-devel"
    "curl-devel" "expat-devel" "openssl-devel" "zlib-devel" "perl-devel"
    "glibc-devel.i686" "libstdc++.i686" "openssl-devel.i686"
    "zlib-ng-compat-devel.i686" "libstdc++-devel.i686" "libgcc.i686"
    "libcurl-devel.i686" "expat-devel.i686" "gettext-devel.i686" "perl-devel.i686"
    "squashfs-tools"
)

$SUDO $PKG_MANAGER install -y "${PACKAGES[@]}" 2>&1 | tail -5

# ============================================
# [3/9] DESCARGAR CÓDIGO FUENTE
# ============================================
echo -e "\n${YELLOW}[3/9] Descargando Git $GIT_VERSION...${NC}"

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

if [ ! -f "git-$GIT_VERSION.tar.xz" ]; then
    wget "https://www.kernel.org/pub/software/scm/git/git-$GIT_VERSION.tar.xz"
fi

# Si la carpeta de esta versión ya existe, la borramos para empezar de cero
if [ -d "git-$GIT_VERSION" ]; then
    rm -rf "git-$GIT_VERSION"
fi
tar -xf "git-$GIT_VERSION.tar.xz"

# AQUI ES DONDE ENTRAMOS A LA CARPETA CORRECTA AUTOMÁTICAMENTE
cd "git-$GIT_VERSION"

# ============================================
# [4/9] CONFIGURAR
# ============================================
echo -e "\n${YELLOW}[4/9] Configurando para i686...${NC}"
make configure
./configure --prefix=/usr/local --host=i686-pc-linux-gnu CFLAGS="-m32 -O2" LDFLAGS="-m32"

# ============================================
# [5/9] COMPILAR (SIN RUST)
# ============================================
echo -e "\n${YELLOW}[5/9] Compilando Git (NO_RUST=YesPlease)...${NC}"

# Limpieza profunda para borrar rastros de Rust de 64 bits
rm -rf target/
make clean

# Compilar forzando la desactivación de Rust
make NO_RUST=YesPlease -j$(nproc)

echo -e "${GREEN}✓ Compilación completada${NC}"

# ============================================
# [6/9] INSTALAR EN DIRECTORIO TEMPORAL
# ============================================
echo -e "\n${YELLOW}[6/9] Instalando en $PACKAGE_DIR...${NC}"

rm -rf "$PACKAGE_DIR"
# ¡IMPORTANTE! Pasar NO_RUST también aquí
make NO_RUST=YesPlease install DESTDIR="$PACKAGE_DIR"

echo -e "${GREEN}✓ Instalación completada${NC}"

# ============================================
# [7/9] ESTRIBAR BINARIOS
# ============================================
echo -e "\n${YELLOW}[7/9] Estripando binarios...${NC}"
if [ -f "$PACKAGE_DIR/usr/local/bin/git" ]; then
    strip "$PACKAGE_DIR/usr/local/bin/git"
fi
find "$PACKAGE_DIR" -type f -exec file {} \; 2>/dev/null | grep 'ELF' | awk -F: '{print $1}' | xargs strip 2>/dev/null || true

# ============================================
# [8/9] CREAR METADATOS Y EMPAQUETAR
# ============================================
echo -e "\n${YELLOW}[8/9] Creando metadatos y empaquetando...${NC}"
PACKAGE_SIZE=$(du -sh "$PACKAGE_DIR" | cut -f1)

mkdir -p "$PACKAGE_DIR/usr/local/share"
cat > "$PACKAGE_DIR/usr/local/share/git.tcz.info" << EOF
Title:          git.tcz
Description:    Git distributed version control system (v$GIT_VERSION)
Version:        $GIT_VERSION
Author:         Git Development Community
Original-site:  https://git-scm.com
Copying-policy: GPLv2
Size:           $PACKAGE_SIZE
Extension_by:   Jose Andres Mamani Mollericona
Comments:       Compilado para i686 desde Fedora 43 (github.com/JOSSEL01)
Current:        $(date +%Y-%m-%d)
EOF

cat > "$OUTPUT_DIR/$EXTENSION_NAME.tcz.dep" << EOF
openssl.tcz
zlib.tcz
EOF

cd "$PACKAGE_DIR"
find usr -not -type d > "$OUTPUT_DIR/$EXTENSION_NAME.tcz.list"

cd /tmp
mksquashfs git-package "$EXTENSION_NAME.tcz"
md5sum "$EXTENSION_NAME.tcz" > "$EXTENSION_NAME.tcz.md5.txt"
cp "$PACKAGE_DIR/usr/local/share/git.tcz.info" "$OUTPUT_DIR/$EXTENSION_NAME.tcz.info"

# ============================================
# [9/9] RESUMEN FINAL
# ============================================
echo -e "\n${GREEN}[9/9] ¡COMPILACIÓN COMPLETADA!${NC}"
echo -e "${GREEN}========================================${NC}"
ls -lh "$OUTPUT_DIR/$EXTENSION_NAME"* 2>/dev/null || true
echo -e "${GREEN}¡Listo!${NC}"
