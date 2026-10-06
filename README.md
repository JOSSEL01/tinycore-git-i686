# Git 2.56.0 para Tiny Core Linux i686

![Git](https://img.shields.io/badge/Git-v2.56.0-orange)
![Platform](https://img.shields.io/badge/Platform-i686-blue)
![Tiny Core](https://img.shields.io/badge/Tiny%20Core-17.0-green)
![License](https://img.shields.io/badge/License-GPLv2-yellow)

Extensión .tcz de Git v2.56.0 compilada para Tiny Core Linux 17.0 (i686, 32 bits).

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

- ✅ Git v2.56.0 (última versión estable)
- ✅ Compilado para i686 (32 bits)
- ✅ Incluye Rust compilado para i686
- ✅ Binarios estripados para reducir el tamaño
- ✅ Compatible con glibc 2.42
- ✅ Incluye git, git-shell, git-upload-pack, etc.

---

## 📦 Requisitos

- Tiny Core Linux 17.0 (o compatible)
- Arquitectura i686 (32 bits)
- glibc 2.42 o superior
- Al menos 50 MB de espacio libre en disco

---

## 🚀 Instalación rápida

Desde la terminal de tu Tiny Core:

`bash
wget https://github.com/JOSSEL01/tinycore-git-i686/raw/main/packages/git-2.56.0.tcz
sudo mv git-2.56.0.tcz /etc/sysconfig/tcedir/optional/
tce-load -i git-2.56.0
git --version
