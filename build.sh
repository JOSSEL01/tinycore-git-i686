#!/bin/bash
# ============================================
# Compilador de Git para Tiny Core i686
# ============================================
# Autor: Jose Andres Mamani Mollericona
# GitHub: JOSSEL01
# ============================================
# Este script hace TODO el proceso:
# 1. Instala dependencias (incluido Rust)
# 2. Configura Rust para i686
# 3. Descarga el código fuente
# 4. Configura para i686
# 5. Compila con Rust
# 6. Instala en directorio temporal
# 7. Estripa binarios
# 8. Crea metadatos (.info, .dep, .list)
# 9. Empaqueta como .tcz
# 10. Genera el .md5.txt
# ============================================

set -e

# ============================================
# CONFIGURACIÓN
# ============================================
GIT_VERSION="2.56.0"
BUILD_DIR="$HOME/git-build"
PACKAGE_DIR="/tmp/git-package"
OUTPUT_DIR="/tmp"
EXTENSION_NAME="git-$GIT_VERSION"

# ============================================
# COLORES
# ============================================
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Compilador de Git para Tiny Core i686${NC}"
echo -e "${GREEN}  Versión: $GIT_VERSION${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================
# VERIFICAR SI ES ROOT PARA INSTALAR PAQUETES
# ============================================
if [ "$EUID" -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo"
fi

# ============================================
# [1/9] INSTALAR DEPENDENCIAS
# ============================================
echo -e "\n${YELLOW}[1/9] Instalando dependencias...${NC}"

if command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
elif command -v yum &> /dev/null; then
    PKG_MANAGER="yum"
else
    echo -e "${RED}No se encontró dnf ni yum. Este script es para Fedora/RHEL.${NC}"
    exit 1
fi

PACKAGES=(
    "gcc" "gcc-c++" "make" "python3" "perl" "wget" "tar" "xz"
    "autoconf" "automake" "libtool"
    "gettext" "gettext-devel"
    "curl-devel" "expat-devel" "openssl-devel" "zlib-devel" "perl-devel"
    "rust" "cargo"
    "glibc-devel.i686" "libstdc++.i686" "openssl-devel.i686"
    "zlib-ng-compat-devel.i686" "libstdc++-devel.i686" "libgcc.i686"
    "libcurl-devel.i686" "expat-devel.i686" "gettext-devel.i686" "perl-devel.i686"
    "squashfs-tools"
)

echo -e "${YELLOW}Instalando paquetes de compilación...${NC}"
$SUDO $PKG_MANAGER install -y "${PACKAGES[@]}" 2>&1 | tail -10

if ! command -v autoconf &> /dev/null; then
    echo -e "${RED}Error: autoconf no se instaló.${NC}"
    exit 1
fi

if ! command -v cargo &> /dev/null; then
    echo -e "${RED}Error: cargo (Rust) no se instaló.${NC}"
    exit 1
fi

echo 'int main(){return 0;}' > /tmp/test-git.c
if ! gcc -m32 /tmp/test-git.c -o /tmp/test-git 2>/dev/null; then
    echo -e "${RED}Error: GCC no compila para 32 bits.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Dependencias verificadas${NC}"

# ============================================
# [2/9] CONFIGURAR RUSTUP Y TARGET i686
# ============================================
echo -e "\n${YELLOW}[2/9] Configurando Rust para i686...${NC}"

if ! command -v rustup &> /dev/null; then
    echo -e "${YELLOW}Instalando rustup...${NC}"
    $SUDO $PKG_MANAGER install -y rustup
    if [ ! -d "$HOME/.rustup" ]; then
        rustup-init -y --default-toolchain stable --profile default 2>&1 | tail -5
    fi
    source "$HOME/.cargo/env" 2>/dev/null || true
fi

if ! command -v rustup &> /dev/null; then
    echo -e "${RED}Error: rustup no disponible.${NC}"
    exit 1
fi

rustup target add i686-unknown-linux-gnu 2>&1 | tail -3

mkdir -p "$HOME/.cargo"
cat > "$HOME/.cargo/config.toml" << 'EOF'
[target.i686-unknown-linux-gnu]
linker = "gcc -m32"
EOF

echo -e "${GREEN}✓ Rust configurado para i686${NC}"

# ============================================
# [3/9] DESCARGAR CÓDIGO FUENTE
# ============================================
echo -e "\n${YELLOW}[3/9] Descargando Git $GIT_VERSION...${NC}"

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"
if [ ! -f "git-$GIT_VERSION.tar.xz" ]; then
    wget "https://www.kernel.org/pub/software/scm/git/git-$GIT_VERSION.tar.xz"
else
    echo -e "${GREEN}✓ El archivo ya existe${NC}"
fi

if [ -d "git-$GIT_VERSION" ]; then
    rm -rf "git-$GIT_VERSION"
fi
tar -xf "git-$GIT_VERSION.tar.xz"
cd "git-$GIT_VERSION"
echo -e "${GREEN}✓ Código fuente extraído${NC}"

# ============================================
# [4/9] CONFIGURAR
# ============================================
echo -e "\n${YELLOW}[4/9] Configurando para i686...${NC}"

make configure
./configure --prefix=/usr/local \
    --host=i686-pc-linux-gnu \
    CFLAGS="-m32 -O2" \
    LDFLAGS="-m32"

echo -e "${GREEN}✓ Configuración completada${NC}"

# ============================================
# [5/9] COMPILAR
# ============================================
echo -e "\n${YELLOW}[5/9] Compilando Git con $(nproc) hilos...${NC}"
echo -e "${YELLOW}Esto puede tardar 10-20 minutos...${NC}"

make CARGO_BUILD_TARGET=i686-unknown-linux-gnu -j$(nproc)

echo -e "${GREEN}✓ Compilación completada${NC}"

# ============================================
# [6/9] INSTALAR EN DIRECTORIO TEMPORAL
# ============================================
echo -e "\n${YELLOW}[6/9] Instalando en $PACKAGE_DIR...${NC}"

rm -rf "$PACKAGE_DIR"
make install DESTDIR="$PACKAGE_DIR"

echo -e "${GREEN}✓ Instalación completada${NC}"

# ============================================
# [7/9] ESTRIBAR BINARIOS
# ============================================
echo -e "\n${YELLOW}[7/9] Estripando binarios...${NC}"

if [ -f "$PACKAGE_DIR/usr/local/bin/git" ]; then
    strip "$PACKAGE_DIR/usr/local/bin/git"
fi

find "$PACKAGE_DIR" -type f -exec file {} \; 2>/dev/null | \
    grep 'ELF' | awk -F: '{print $1}' | \
    xargs strip 2>/dev/null || true

echo -e "${GREEN}✓ Binarios estripados${NC}"

# ============================================
# [8/9] CREAR METADATOS Y EMPAQUETAR
# ============================================
echo -e "\n${YELLOW}[8/9] Creando metadatos y empaquetando...${NC}"

PACKAGE_SIZE=$(du -sh "$PACKAGE_DIR" | cut -f1)

# Crear archivo .info
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
Change-log:     Compilado manualmente
Current:        $(date +%Y-%m-%d)
EOF

# Crear archivo .dep
cat > "$OUTPUT_DIR/$EXTENSION_NAME.tcz.dep" << EOF
openssl.tcz
zlib.tcz
EOF

# Crear archivo .list
cd "$PACKAGE_DIR"
find usr -not -type d > "$OUTPUT_DIR/$EXTENSION_NAME.tcz.list"

# Empaquetar como .tcz
cd /tmp
mksquashfs git-package "$EXTENSION_NAME.tcz"

# Crear .md5.txt
md5sum "$EXTENSION_NAME.tcz" > "$EXTENSION_NAME.tcz.md5.txt"

# Copiar el .info al directorio de salida con el nombre correcto
cp "$PACKAGE_DIR/usr/local/share/git.tcz.info" "$OUTPUT_DIR/$EXTENSION_NAME.tcz.info"

echo -e "${GREEN}✓ Metadatos y paquete creados${NC}"

# ============================================
# [9/9] RESUMEN FINAL
# ============================================
echo -e "\n${GREEN}[9/9] ¡COMPILACIÓN COMPLETADA!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Archivos generados en ${YELLOW}$OUTPUT_DIR${NC}:"
echo ""
ls -lh "$OUTPUT_DIR/$EXTENSION_NAME"* 2>/dev/null || true
echo ""
echo -e "${YELLOW}Para instalar en Tiny Core:${NC}"
echo "  1. Copia $EXTENSION_NAME.tcz a /etc/sysconfig/tcedir/optional/"
echo "  2. Ejecuta: tce-load -i $EXTENSION_NAME"
echo "  3. Verifica: git --version"
echo ""
echo -e "${GREEN}¡Listo!${NC}"
