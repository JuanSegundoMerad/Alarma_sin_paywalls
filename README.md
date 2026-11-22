# AlarmaMy (iPhone 15 / iOS 26)

Aplicación personal de alarma nativa para **iPhone 15 (iOS 26+)** con misiones encadenadas ilimitadas (Matemática, Código QR/Barras y Escribir Frase), **sin paywalls** y **sin bloquear el teléfono**.

---

## Estado actual: Fase 1 — Prueba de `AlarmKit`

Esta primera versión sirve para validar toda la cadena completa antes de construir las pantallas y misiones:
1. Compilación automática desde Windows usando **GitHub Actions (`macos-26` / Xcode 26)**.
2. Instalación en tu **iPhone 15** con cuenta Apple gratuita.
3. Disparo real de **AlarmKit** atravesando **Modo Silencio + No Molestar** y apertura directa de la app mediante `LiveActivityIntent`.

---

## Paso 1: Subir el proyecto a GitHub y compilar el `.ipa`

1. Entrá a [github.com/new](https://github.com/new) y creá un repositorio vacío llamado `AlarmaMy` (sin README ni `.gitignore`, porque ya están creados acá).
   * *Tip:* En repositorios **públicos** los minutos de GitHub Actions en macOS son gratuitos. En repositorios **privados**, el plan gratuito incluye ~200 minutos reales de macOS al mes (alcanza para ~40–60 builds mensuales).
2. Desde una terminal en `d:\Documentos\Alarma_my`, conectá tu repo y hacé push:
   ```powershell
   git remote add origin https://github.com/TU_USUARIO/AlarmaMy.git
   git push -u origin main
   ```
3. En GitHub, abrí la pestaña **Actions** → workflow **Build AlarmaMy (iOS 26 Unsigned IPA)**.
4. Cuando termine en verde, bajá hasta **Artifacts** y descargá **`AlarmaMy-Unsigned-IPA`** (descomprimí el `.zip` para obtener `AlarmaMy-Unsigned.ipa`).

---

## Paso 2: Instalar `AlarmaMy-Unsigned.ipa` en tu iPhone 15

Primero activá el **Modo Desarrollador** en tu iPhone 15 (una sola vez):
* `Ajustes` → `Privacidad y seguridad` → `Modo de desarrollador` → Activar y reiniciar.

Luego elegí una de estas dos opciones con tu **cuenta Apple gratuita**:

### Opción A — SideStore (recomendada para uso diario, sin cable después del setup)
1. Instalá **SideStore** siguiendo su guía oficial en [sidestore.io](https://sidestore.io) junto con **LocalDevVPN** (desde la App Store).
2. Pasá `AlarmaMy-Unsigned.ipa` a tu iPhone (por iCloud Drive, Telegram, Google Drive o descargándolo directo desde Safari en GitHub Actions).
3. Abrí **SideStore** → tocá **`+`** → elegí `AlarmaMy-Unsigned.ipa`.
4. SideStore la firma e instala en tu iPhone y te permite renovarla inalámbricamente cada 7 días sin volver a enchufar a la PC.

### Opción B — Sideloadly (más rápida para probar por USB-C desde Windows)
1. Descargá **Sideloadly** en Windows desde [sideloadly.io](https://sideloadly.io).
2. Conectá el iPhone 15 por USB-C a tu PC y confiá en la computadora.
3. Arrastrá `AlarmaMy-Unsigned.ipa` a Sideloadly, ingresá tu Apple ID y tocá **Start**.
4. En el iPhone: `Ajustes` → `General` → `VPN y gestión de dispositivos` → confiá en tu Apple ID.

---

## Paso 3: Qué probar en Fase 1

1. Abrí **AlarmaMy** y tocá **Autorizar** para otorgar permiso de `AlarmKit`.
2. Tocá **Probar alarma en 15 segundos**.
3. Activá **Modo Silencio** (y opcionalmente **No Molestar**) y **bloqueá la pantalla** del iPhone 15.
4. A los 15 segundos debería sonar la alarma nativa de `AlarmKit`.
5. Tocá **Abrir misiones** y verificá que **AlarmaMy** se abra al frente mostrando el cartel verde de confirmación.
