# Git 2.56.0 para Tiny Core Linux i686

![Git](https://img.shields.io/badge/Git-v2.56.0-orange)
![Platform](https://img.shields.io/badge/Platform-i686-blue)
![Tiny Core](https://img.shields.io/badge/Tiny%20Core-17.0-green)
![License](https://img.shields.io/badge/License-GPLv2-yellow)

Extensión `.tcz` de **Git v2.56.0** compilada para **Tiny Core Linux 17.0 (i686, 32 bits)**.

---

## 📋 Tabla de contenidos

- [Características](#-características)
- [Requisitos](#-requisitos)
- [Instalación rápida](#-instalación-rápida)
- [Instalación manual](#-instalación-manual)
- [Verificación](#-verificación)
- [Detalles de compilación](#-detalles-de-compilación)
- [Solución de problemas](#-solución-de-problemas)
- [Recompilar desde cero](#-recompilar-desde-cero)
- [Licencia](#-licencia)

---

## ✨ Características

- ✅ Git **v2.56.0** (última versión estable)
- ✅ Compilado para **i686 (32 bits)**
- ✅ Incluye **Rust** compilado para i686
- ✅ Binarios **estripados** para reducir el tamaño
- ✅ Compatible con **glibc 2.42**
- ✅ Tamaño del paquete: **~20 MB**

---

## 📦 Requisitos

- **Tiny Core Linux 17.0** (o compatible)
- **Arquitectura i686** (32 bits)
- **glibc 2.42** o superior
- Al menos **50 MB de espacio libre** en disco
- Dependencias: `openssl.tcz`, `zlib.tcz`

---

## 🚀 Instalación rápida

Desde la terminal de tu Tiny Core:

```bash
wget https://github.com/JOSSEL01/tinycore-git-i686/raw/main/packages/git-2.56.0.tcz
sudo mv git-2.56.0.tcz /etc/sysconfig/tcedir/optional/
tce-load -i git-2.56.0
git --version
```

Deberías ver: `git version 2.56.0`

---

## 🔧 Instalación manual

1. Descarga `git-2.56.0.tcz` desde la carpeta `packages/`.
2. Cópialo a `/etc/sysconfig/tcedir/optional/` en tu Tiny Core.
3. Ejecuta:
   ```bash
   tce-load -i git-2.56.0
   ```
4. Verifica:
   ```bash
   git --version
   ```

---

## ✅ Verificación

```bash
git --version
# Salida esperada: git version 2.56.0

file $(which git)
# Salida esperada: ELF 32-bit LSB executable, Intel 80386...
```

---

## 🛠️ Detalles de compilación

| Parámetro | Valor |
|---|---|
| **Versión de Git** | 2.56.0 |
| **Sistema anfitrión** | Fedora 43 x86_64 |
| **Arquitectura objetivo** | i686 (32 bits) |
| **glibc** | 2.42 |
| **GCC** | 15.2.0 |
| **Rust** | Con target `i686-unknown-linux-gnu` |

---

## 🐛 Solución de problemas

### Error: `error while loading shared libraries: libcurl.so.4`

**Solución:**
```bash
tce-load -wi curl
```

### Error: `error while loading shared libraries: libexpat.so.1`

**Solución:**
```bash
tce-load -wi expat2
```

### Error: `git: error while loading shared libraries: libssl.so.3`

**Solución:**
```bash
tce-load -wi openssl
```

---

## 🔨 Recompilar desde cero

Usa el script `build.sh` incluido en este repositorio:

```bash
chmod +x build.sh
./build.sh
```

Edita la variable `GIT_VERSION` en `build.sh` para cambiar de versión.

---

## 📄 Licencia

Git es software libre bajo la [licencia GPLv2](https://github.com/git/git/blob/master/COPYING).

---

## 📞 Contacto

- **Autor:** Jose Andres Mamani Mollericona
- **GitHub:** [@JOSSEL01](https://github.com/JOSSEL01)
- **Repositorio:** [tinycore-git-i686](https://github.com/JOSSEL01/tinycore-git-i686)
