# 🎮 MC-FEEXEL-PARTY

Red de servidores de Minecraft para torneos estilo "Squid Game" usando Docker, Velocity y Paper.

## 📋 Descripción

Plataforma de Minecraft multiplayer con arquitectura proxy-backend diseñada para eventos masivos. Implementa la **Estrategia de Contenedores Secuenciales** para optimizar recursos durante torneos con múltiples rondas.

## 🏗️ Arquitectura

```
[Jugadores] → [Proxy Velocity] → [Lobby Paper]
                                 ↓
                           [SquidGames Paper] (Ronda 1)
                           [MineGames Paper] (Ronda 2+)
```

### Servicios

| Servicio | Imagen | Puerto | RAM | Función |
|----------|--------|--------|-----|---------|
| **proxy** | itzg/mc-proxy:latest | 25565 | 1G | Punto de entrada Velocity |
| **lobby** | itzg/minecraft-server:latest | 25566 | 4G | Zona de espera Paper 1.21 |
| **squidgames** | itzg/minecraft-server:latest | 25567 | 10G | Servidor de Ronda 1 |
| **minegames** | itzg/minecraft-server:latest | 25568 | 10G | Servidor de Ronda 2+ |

## ⚙️ Características

- ✅ **Modo NO PREMIUM**: Acepta clientes premium y no premium
- ✅ **Estrategia Secuencial**: Solo un servidor de minijuegos activo a la vez (máximo uso de RAM)
- ✅ **Aikar Flags**: Optimización de JVM en todos los servidores Paper
- ✅ **RCON Habilitado**: Administración remota de servidores
- ✅ **Auto-restart**: Recuperación automática en caso de fallos
- ✅ **Console Access**: Interacción directa con consola del servidor

## 🚀 Inicio Rápido

### Requisitos Previos

- Docker Engine instalado
- Docker Compose v2+
- Mínimo 16GB RAM (recomendado para modo secuencial)
- Puertos disponibles: 25565, 25566, 25567, 25568

### Instalación

1. **Clonar el repositorio**
   ```bash
   git clone <tu-repo>
   cd mc-feexel-party
   ```

2. **Iniciar los servicios base (Proxy + Lobby)**
   ```bash
   sudo docker compose up -d proxy lobby
   ```

3. **Verificar estado**
   ```bash
   sudo docker ps
   sudo docker logs mc-proxy -f
   sudo docker logs mc-lobby -f
   ```

4. **Conectarse desde Minecraft**
   ```
   IP: tu_servidor:25565
   Modo: NO PREMIUM (acepta cualquier cliente)
   ```

## 🎯 Estrategia de Contenedores Secuenciales

Esta estrategia permite ejecutar torneos con múltiples rondas usando recursos óptimos:

### Fase 1: Lobby (100 jugadores)
```bash
# Solo proxy + lobby corriendo
sudo docker compose up -d proxy lobby
```
**RAM Usada**: ~5G (proxy 1G + lobby 4G)

### Fase 2: Ronda 1 - SquidGames
```bash
# Iniciar servidor de SquidGames
sudo docker compose up -d squidgames

# Los jugadores se mueven del lobby a squidgames
# Fin de la ronda: 30 eliminados, 70 sobreviven
```
**RAM Usada**: ~15G (proxy 1G + lobby 4G + squidgames 10G)

### Fase 3: Limpieza y Preparación
```bash
# Mover ganadores de vuelta al lobby
# Detener SquidGames para liberar 10G
sudo docker compose stop squidgames
```
**RAM Liberada**: 10G ahora disponible

### Fase 4: Ronda 2 - MineGames
```bash
# Iniciar servidor de MineGames
sudo docker compose up -d minegames

# Mover a los 70 ganadores a minegames
```
**RAM Usada**: ~15G (proxy 1G + lobby 4G + minegames 10G)

## 📝 Comandos Útiles

### Gestión de Servicios

```bash
# Iniciar servicios específicos
sudo docker compose up -d proxy lobby

# Detener servicios
sudo docker compose stop squidgames
sudo docker compose stop minegames

# Reiniciar todo
sudo docker compose restart

# Detener todo
sudo docker compose down

# Reconstruir contenedores
sudo docker compose up -d --force-recreate
```

### Logs y Monitoreo

```bash
# Ver logs en tiempo real
sudo docker logs mc-proxy -f
sudo docker logs mc-lobby -f
sudo docker logs mc-squidgames -f

# Ver últimas líneas
sudo docker logs mc-lobby --tail 50

# Estado de contenedores
sudo docker ps
sudo docker stats
```

### RCON (Administración Remota)

```bash
# Conectar via RCON al lobby
docker exec -i mc-lobby rcon-cli

# Comandos útiles
/list
/tp jugador x y z
/gamemode creative jugador
/give jugador minecraft:diamond 64
```

### Backup

```bash
# Backup de mundos y configs
sudo tar -czf backup-$(date +%Y%m%d).tar.gz \
  lobby-data/world \
  lobby-data/config \
  squidgames-data/world \
  minegames-data/world

# Backup de configuraciones solo
sudo tar -czf config-backup.tar.gz \
  proxy-data/velocity.toml \
  */config/
```

## 🔧 Configuración

### Cambiar Memoria Asignada

Edita `docker-compose.yml`:

```yaml
environment:
  MEMORY: "8G"  # Cambiar según necesites
```

### Cambiar Versión de Minecraft

```yaml
environment:
  VERSION: "1.21"  # Cambiar a la versión deseada
```

### Configurar Whitelist

```bash
# Acceder al contenedor
sudo docker exec -it mc-lobby bash

# Habilitar whitelist
echo "whitelist=true" >> /data/server.properties

# Agregar jugadores
whitelist add jugador1
whitelist add jugador2
```

## 🛡️ Seguridad

### Modo Actual: NO PREMIUM

- ⚠️ El servidor acepta cualquier cliente (premium o no premium)
- ⚠️ Sin verificación de cuentas de Mojang
- ✅ Ideal para torneos inclusivos
- ✅ Más estable, menos problemas de autenticación

### Contraseñas RCON

Cambiar en `docker-compose.yml`:

```yaml
environment:
  RCON_PASSWORD: "tu_contraseña_segura"
```

## 📊 Monitoreo de Recursos

```bash
# Ver uso de CPU/RAM en tiempo real
sudo docker stats

# Ver puertos abiertos
sudo netstat -tulpn | grep docker

# Espacio en disco usado
du -sh *-data/
```

## 🐛 Troubleshooting

### Problema: No puedo conectarme

1. Verificar que los contenedores estén corriendo:
   ```bash
   sudo docker ps
   ```

2. Revisar logs del proxy:
   ```bash
   sudo docker logs mc-proxy --tail 50
   ```

3. Verificar firewall:
   ```bash
   sudo ufw status
   sudo ufw allow 25565/tcp
   ```

### Problema: Servidor lag/lento

1. Verificar memoria disponible:
   ```bash
   free -h
   ```

2. Aumentar RAM en docker-compose.yml

3. Reiniciar el servidor:
   ```bash
   sudo docker compose restart lobby
   ```

### Problema: "Can't keep up!" en logs

Es normal con muchos jugadores. Considera:
- Aumentar RAM
- Reducir render-distance en `server.properties`
- Usar menos entidades/mobs

## 📁 Estructura del Proyecto

```
mc-feexel-party/
├── docker-compose.yml          # Configuración principal
├── .gitignore                 # Archivos ignorados por git
├── README.md                  # Esta documentación
├── proxy-data/
│   ├── velocity.toml          # Config del proxy
│   └── forwarding.secret      # Secret key (no versionar)
├── lobby-data/
│   ├── world/                 # Mundo del lobby (no versionar)
│   ├── config/                # Configuraciones Paper
│   └── plugins/               # Plugins (no versionar)
├── squidgames-data/
│   ├── world/                 # Mundo Ronda 1
│   └── config/                # Configuraciones
└── minegames-data/
    ├── world/                 # Mundo Ronda 2
    └── config/                # Configuraciones
```

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -am 'Agrega nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

## 📜 Licencia

Este proyecto está bajo licencia MIT. Ver archivo `LICENSE` para más detalles.

## 🙏 Créditos

- [itzg/docker-minecraft-server](https://github.com/itzg/docker-minecraft-server) - Imagen Docker de Minecraft
- [PaperMC](https://papermc.io/) - Servidor optimizado
- [Velocity](https://velocitypowered.com/) - Proxy moderno

## 📞 Soporte

Para reportar bugs o solicitar features:
- Abre un issue en GitHub
- Contacta al equipo de desarrollo

---

**Creado con ❤️ para la comunidad de Minecraft**
