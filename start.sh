#!/bin/bash

# ============================================
# MC-FEEXEL-PARTY - Script de Inicio
# ============================================

set -e

echo "╔════════════════════════════════════════╗"
echo "║     MC-FEEXEL PARTY - Inicio Rápido   ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para verificar si Docker está instalado
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker no está instalado${NC}"
        echo "Instala Docker desde: https://docs.docker.com/get-docker/"
        exit 1
    fi
    echo -e "${GREEN}✅ Docker instalado${NC}"
}

# Función para verificar Docker Compose
check_docker_compose() {
    if ! docker compose version &> /dev/null; then
        echo -e "${RED}❌ Docker Compose no está disponible${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Docker Compose disponible${NC}"
}

# Función para verificar puertos
check_ports() {
    echo -e "${BLUE}Verificando puertos...${NC}"
    
    ports=(25565 25566 25567 25568)
    for port in "${ports[@]}"; do
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
            echo -e "${YELLOW}⚠️  Puerto $port ya está en uso${NC}"
        else
            echo -e "${GREEN}✅ Puerto $port disponible${NC}"
        fi
    done
}

# Menú principal
show_menu() {
    echo ""
    echo "════════════════════════════════════════"
    echo "Selecciona una opción:"
    echo "════════════════════════════════════════"
    echo "1) Iniciar Plataforma Base (Proxy + Lobby)"
    echo "2) Iniciar Ronda 1 (SquidGames)"
    echo "3) Detener Ronda 1 y preparar Ronda 2"
    echo "4) Iniciar Ronda 2 (MineGames)"
    echo "5) Ver estado de contenedores"
    echo "6) Ver logs del Proxy"
    echo "7) Ver logs del Lobby"
    echo "8) Detener todo"
    echo "9) Reiniciar todo"
    echo "0) Salir"
    echo "════════════════════════════════════════"
    read -p "Opción: " option
}

# Función para iniciar plataforma base
start_base() {
    echo -e "${BLUE}Iniciando Plataforma Base (Proxy + Lobby)...${NC}"
    sudo docker compose up -d proxy lobby
    echo -e "${GREEN}✅ Plataforma base iniciada${NC}"
    echo -e "${YELLOW}Conecta desde Minecraft a: tu_ip:25565${NC}"
}

# Función para iniciar Ronda 1
start_round1() {
    echo -e "${BLUE}Iniciando Ronda 1 (SquidGames)...${NC}"
    sudo docker compose up -d squidgames
    echo -e "${GREEN}✅ Servidor SquidGames iniciado (10G RAM)${NC}"
    echo -e "${YELLOW}Mueve a los jugadores del lobby a squidgames${NC}"
}

# Función para preparar Ronda 2
prepare_round2() {
    echo -e "${BLUE}Deteniendo SquidGames y liberando recursos...${NC}"
    sudo docker compose stop squidgames
    echo -e "${GREEN}✅ SquidGames detenido (10G RAM liberados)${NC}"
    echo -e "${YELLOW}Ahora puedes iniciar MineGames${NC}"
}

# Función para iniciar Ronda 2
start_round2() {
    echo -e "${BLUE}Iniciando Ronda 2 (MineGames)...${NC}"
    sudo docker compose up -d minegames
    echo -e "${GREEN}✅ Servidor MineGames iniciado (10G RAM)${NC}"
    echo -e "${YELLOW}Mueve a los jugadores del lobby a minegames${NC}"
}

# Función para ver estado
show_status() {
    echo -e "${BLUE}Estado de contenedores:${NC}"
    sudo docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    echo ""
    echo -e "${BLUE}Uso de recursos:${NC}"
    sudo docker stats --no-stream
}

# Función para ver logs del proxy
show_proxy_logs() {
    echo -e "${BLUE}Logs del Proxy (Ctrl+C para salir):${NC}"
    sudo docker logs mc-proxy -f
}

# Función para ver logs del lobby
show_lobby_logs() {
    echo -e "${BLUE}Logs del Lobby (Ctrl+C para salir):${NC}"
    sudo docker logs mc-lobby -f
}

# Función para detener todo
stop_all() {
    echo -e "${BLUE}Deteniendo todos los servicios...${NC}"
    sudo docker compose down
    echo -e "${GREEN}✅ Todos los servicios detenidos${NC}"
}

# Función para reiniciar todo
restart_all() {
    echo -e "${BLUE}Reiniciando todos los servicios...${NC}"
    sudo docker compose restart
    echo -e "${GREEN}✅ Todos los servicios reiniciados${NC}"
}

# Main
main() {
    clear
    check_docker
    check_docker_compose
    check_ports
    
    while true; do
        show_menu
        
        case $option in
            1)
                start_base
                ;;
            2)
                start_round1
                ;;
            3)
                prepare_round2
                ;;
            4)
                start_round2
                ;;
            5)
                show_status
                ;;
            6)
                show_proxy_logs
                ;;
            7)
                show_lobby_logs
                ;;
            8)
                stop_all
                ;;
            9)
                restart_all
                ;;
            0)
                echo -e "${GREEN}¡Hasta luego!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Opción inválida${NC}"
                ;;
        esac
        
        echo ""
        read -p "Presiona Enter para continuar..."
    done
}

# Ejecutar
main
