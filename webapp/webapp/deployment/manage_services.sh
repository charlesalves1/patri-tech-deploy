#!/bin/bash

# ========================================
# SCRIPT DE GERENCIAMENTO - PATRI-TECH
# ========================================
# Script para facilitar o gerenciamento dos serviços

set -e

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

SERVICE_NAME="patritech-backend"

print_header() {
    echo ""
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}=========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

show_help() {
    print_header "🛠️  GERENCIADOR DE SERVIÇOS PATRI-TECH"
    echo ""
    echo "Uso: ./manage_services.sh [comando]"
    echo ""
    echo "Comandos disponíveis:"
    echo ""
    echo "  status      - Ver status de todos os serviços"
    echo "  start       - Iniciar todos os serviços"
    echo "  stop        - Parar todos os serviços"
    echo "  restart     - Reiniciar todos os serviços"
    echo "  logs        - Ver logs do backend"
    echo "  logs-nginx  - Ver logs do Nginx"
    echo "  enable      - Habilitar serviços no boot"
    echo "  disable     - Desabilitar serviços no boot"
    echo ""
}

check_service() {
    if sudo systemctl is-active --quiet "$1"; then
        print_success "$1 está rodando"
        return 0
    else
        print_error "$1 não está rodando"
        return 1
    fi
}

# Processar comando
case "$1" in
    status)
        print_header "📊 STATUS DOS SERVIÇOS"
        echo ""
        echo "Backend (Django/Gunicorn):"
        check_service "$SERVICE_NAME"
        sudo systemctl status "$SERVICE_NAME" --no-pager -l | head -20
        echo ""
        echo "Nginx:"
        check_service nginx
        sudo systemctl status nginx --no-pager -l | head -20
        ;;
        
    start)
        print_header "▶️  INICIANDO SERVIÇOS"
        echo ""
        echo "Iniciando backend..."
        sudo systemctl start "$SERVICE_NAME"
        check_service "$SERVICE_NAME"
        echo ""
        echo "Iniciando Nginx..."
        sudo systemctl start nginx
        check_service nginx
        print_success "Todos os serviços iniciados!"
        ;;
        
    stop)
        print_header "⏹️  PARANDO SERVIÇOS"
        echo ""
        echo "Parando backend..."
        sudo systemctl stop "$SERVICE_NAME"
        print_success "Backend parado"
        echo ""
        echo "Parando Nginx..."
        sudo systemctl stop nginx
        print_success "Nginx parado"
        ;;
        
    restart)
        print_header "🔄 REINICIANDO SERVIÇOS"
        echo ""
        echo "Reiniciando backend..."
        sudo systemctl restart "$SERVICE_NAME"
        sleep 2
        check_service "$SERVICE_NAME"
        echo ""
        echo "Recarregando Nginx..."
        sudo nginx -t && sudo systemctl reload nginx
        check_service nginx
        print_success "Todos os serviços reiniciados!"
        ;;
        
    logs)
        print_header "📋 LOGS DO BACKEND"
        echo ""
        echo "Pressione Ctrl+C para sair"
        echo ""
        sudo journalctl -u "$SERVICE_NAME" -f
        ;;
        
    logs-nginx)
        print_header "📋 LOGS DO NGINX"
        echo ""
        echo "Access Log:"
        echo "==========="
        sudo tail -n 50 /var/log/nginx/patritech_access.log
        echo ""
        echo "Error Log:"
        echo "=========="
        sudo tail -n 50 /var/log/nginx/patritech_error.log
        ;;
        
    enable)
        print_header "✅ HABILITANDO SERVIÇOS NO BOOT"
        echo ""
        sudo systemctl enable "$SERVICE_NAME"
        print_success "Backend habilitado"
        sudo systemctl enable nginx
        print_success "Nginx habilitado"
        ;;
        
    disable)
        print_header "❌ DESABILITANDO SERVIÇOS NO BOOT"
        echo ""
        sudo systemctl disable "$SERVICE_NAME"
        print_success "Backend desabilitado"
        sudo systemctl disable nginx
        print_success "Nginx desabilitado"
        ;;
        
    *)
        show_help
        exit 1
        ;;
esac

echo ""
