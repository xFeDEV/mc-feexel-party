# 🎮 Guía de Configuración del Lobby - Mapa Personalizado

## 📋 Objetivo
Configurar el servidor `mc-lobby` para que solo cargue el **Overworld** (sin Nether ni End) y pueda usar un **mapa personalizado** de lobby.

---

## ✅ PASO 1: Deshabilitar el Nether (COMPLETADO)

**Estado**: ✅ Ya configurado en `docker-compose.yml`

Se agregó la variable `ALLOW_NETHER: "FALSE"` que automáticamente configurará:
```properties
# En server.properties
allow-nether=false
```

---

## 🔧 PASO 2: Deshabilitar el End

### 2.1. Detener el servidor lobby
```bash
cd /home/feexel_root/mc-feexel-party
sudo docker compose stop lobby
```

### 2.2. Editar el archivo bukkit.yml
```bash
nano ./lobby-data/bukkit.yml
```

O si prefieres usar otro editor:
```bash
vim ./lobby-data/bukkit.yml
# o
code ./lobby-data/bukkit.yml  # Si usas VSCode
```

### 2.3. Buscar y modificar la sección worlds
Busca esta sección:
```yaml
worlds:
  world:
    generator: default
  world_nether:
    generator: default
  world_the_end:
    generator: default
```

Y agrega debajo la configuración:
```yaml
settings:
  allow-end: false
```

El archivo debería verse así:
```yaml
worlds:
  world:
    generator: default
  world_nether:
    generator: default
  world_the_end:
    generator: default

settings:
  allow-end: false
```

### 2.4. Guardar y cerrar
- **Nano**: Presiona `Ctrl+X`, luego `Y`, luego `Enter`
- **Vim**: Presiona `Esc`, escribe `:wq`, presiona `Enter`

---

## 🗺️ PASO 3: Cargar tu Mapa Personalizado de Lobby

### 3.1. IMPORTANTE: Hacer backup del mundo actual (opcional pero recomendado)
```bash
cd /home/feexel_root/mc-feexel-party

# Crear backup del mundo actual
sudo tar -czf backup-lobby-world-$(date +%Y%m%d-%H%M).tar.gz \
  lobby-data/world \
  lobby-data/world_nether \
  lobby-data/world_the_end

# El backup se guardará como: backup-lobby-world-20251109-2245.tar.gz
```

### 3.2. Eliminar el mundo actual
```bash
cd /home/feexel_root/mc-feexel-party

# Eliminar las carpetas de mundos
sudo rm -rf lobby-data/world
sudo rm -rf lobby-data/world_nether
sudo rm -rf lobby-data/world_the_end
```

⚠️ **IMPORTANTE**: Asegúrate de haber hecho el backup antes de este paso.

### 3.3. Copiar tu mapa personalizado

**Opción A: Si tu mapa está en tu PC local**

Usa SCP o SFTP para copiar tu carpeta `world` al servidor:

```bash
# Desde tu PC local (no en el servidor)
scp -r /ruta/a/tu/world usuario@tu_servidor:/home/feexel_root/mc-feexel-party/lobby-data/

# Ejemplo:
scp -r ~/Desktop/lobby-world-custom usuario@123.45.67.89:/home/feexel_root/mc-feexel-party/lobby-data/world
```

**Opción B: Si el mapa ya está en el servidor**

```bash
cd /home/feexel_root/mc-feexel-party

# Copiar desde otra ubicación en el servidor
sudo cp -r /ruta/al/mapa/world ./lobby-data/world

# Ejemplo:
sudo cp -r ~/mi-mapa-lobby/world ./lobby-data/world
```

**Opción C: Usar FileZilla u otro cliente FTP**

1. Conecta a tu servidor via SFTP
2. Navega a `/home/feexel_root/mc-feexel-party/lobby-data/`
3. Arrastra y suelta tu carpeta `world` desde tu PC

### 3.4. Verificar que la carpeta se llame correctamente
```bash
ls -la ./lobby-data/

# Deberías ver:
# drwxr-xr-x  world/
```

### 3.5. Ajustar permisos (importante)
```bash
cd /home/feexel_root/mc-feexel-party

# Dar permisos al usuario que ejecuta Docker
sudo chown -R 1000:1000 lobby-data/world
sudo chmod -R 755 lobby-data/world
```

---

## 🚀 PASO 4: Reiniciar el Servidor

### 4.1. Reiniciar el lobby con la nueva configuración
```bash
cd /home/feexel_root/mc-feexel-party

# Reiniciar el lobby
sudo docker compose up -d --force-recreate lobby
```

### 4.2. Verificar que inició correctamente
```bash
# Ver logs en tiempo real (Ctrl+C para salir)
sudo docker logs mc-lobby -f

# Espera a ver este mensaje:
# [INFO]: Done (XX.XXXs)! For help, type "help"
```

### 4.3. Verificar que solo carga el Overworld
En los logs deberías ver **SOLO** esto:
```
[INFO]: Preparing level "world"
[INFO]: Preparing start region for dimension minecraft:overworld
[INFO]: Time elapsed: XXXX ms
```

**NO deberías ver**:
- ❌ `Preparing start region for dimension minecraft:the_nether`
- ❌ `Preparing start region for dimension minecraft:the_end`

---

## ✅ PASO 5: Verificación Final

### 5.1. Conectarte al servidor
```
IP: tu_servidor:25565
```

### 5.2. Verificar el spawn
El jugador debería aparecer en el **spawn de tu mapa personalizado**.

### 5.3. Comandos útiles para ajustar el spawn (si es necesario)
```bash
# Conectar a la consola RCON
sudo docker exec -i mc-lobby rcon-cli

# Dentro de RCON:
# Establecer el spawn del mundo
/setworldspawn <x> <y> <z>

# Ejemplo:
/setworldspawn 0 64 0

# Teletransportarte para probar
/tp TuUsuario 0 64 0
```

---

## 📊 Estructura Final Esperada

```
lobby-data/
├── world/                    # ✅ Tu mapa personalizado (SOLO Overworld)
│   ├── region/
│   ├── data/
│   ├── level.dat
│   └── ...
├── config/
│   ├── paper-global.yml
│   └── ...
├── bukkit.yml               # ✅ Modificado (allow-end: false)
├── server.properties        # ✅ Modificado automáticamente (allow-nether=false)
└── plugins/
```

**NO deberías tener**:
- ❌ `world_nether/`
- ❌ `world_the_end/`

---

## 🐛 Troubleshooting

### Problema: El servidor sigue generando Nether/End

**Solución 1**: Verificar server.properties
```bash
grep "allow-nether" ./lobby-data/server.properties
# Debería mostrar: allow-nether=false
```

**Solución 2**: Verificar bukkit.yml
```bash
grep "allow-end" ./lobby-data/bukkit.yml
# Debería mostrar: allow-end: false
```

**Solución 3**: Forzar recreación
```bash
sudo docker compose down
sudo rm -rf lobby-data/world_nether lobby-data/world_the_end
sudo docker compose up -d --force-recreate lobby
```

### Problema: No carga mi mapa personalizado

**Verificar permisos**:
```bash
ls -la ./lobby-data/world
# Debería mostrar: drwxr-xr-x 1000 1000
```

**Corregir permisos**:
```bash
sudo chown -R 1000:1000 lobby-data/world
```

### Problema: El spawn está en un lugar raro

**Ajustar spawn**:
```bash
sudo docker exec -i mc-lobby rcon-cli

# Dentro de RCON:
/setworldspawn 0 64 0
/spawnpoint @a 0 64 0
```

---

## 📝 Checklist Final

Antes de continuar, verifica:

- [ ] `docker-compose.yml` tiene `ALLOW_NETHER: "FALSE"`
- [ ] `bukkit.yml` tiene `allow-end: false`
- [ ] Carpeta `world/` original eliminada (con backup)
- [ ] Tu mapa personalizado copiado y se llama `world`
- [ ] Permisos correctos (`1000:1000`)
- [ ] Servidor reiniciado con `--force-recreate`
- [ ] Logs muestran solo carga del Overworld
- [ ] Conectado y spawn funciona correctamente

---

## 🎯 Beneficios de Esta Configuración

✅ **Ahorro de RAM**: No carga Nether ni End (~30-40% menos uso de memoria)  
✅ **Carga más rápida**: Solo genera/carga un mundo  
✅ **Mejor rendimiento**: Menos chunks que mantener en memoria  
✅ **Mapa personalizado**: Tu diseño único de lobby  
✅ **Sin distracciones**: Los jugadores no pueden escapar del lobby  

---

## 📞 Soporte

Si tienes problemas:
1. Revisa los logs: `sudo docker logs mc-lobby -f`
2. Verifica permisos: `ls -la lobby-data/world`
3. Revisa configuración: `cat lobby-data/bukkit.yml`

---

**¡Tu lobby personalizado está listo!** 🎉
