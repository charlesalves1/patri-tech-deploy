#!/bin/bash

# ========================================
# SCRIPT DE DEPLOY - PATRI-TECH
# ========================================
# Este script automatiza o deploy completo da aplicação
# Execute com: bash deploy.sh

set -e  # Para em caso de erro

echo "========================================="
echo "🚀 INICIANDO DEPLOY DO PATRI-TECH"
echo "========================================="

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Variáveis de configuração
PROJECT_DIR="/home/ubuntu/patritech"
VENV_DIR="$PROJECT_DIR/venv"
FRONTEND_DIR="$PROJECT_DIR/frontend"
SERVICE_NAME="patritech-backend"

# Função para print colorido
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# 1. Atualizar código do repositório
echo ""
echo "📥 1. Atualizando código do Git..."
cd "$PROJECT_DIR"
git fetch origin
git pull origin main
print_success "Código atualizado"

# 2. Ativar ambiente virtual e atualizar dependências do backend
echo ""
echo "🐍 2. Atualizando dependências do Python..."
source "$VENV_DIR/bin/activate"
pip install -r requirements.txt --upgrade
print_success "Dependências do Python atualizadas"

# 3. Executar migrações do banco de dados
echo ""
echo "🗄️  3. Executando migrações do banco de dados..."
python manage.py migrate --noinput
print_success "Migrações aplicadas"

# 4. Coletar arquivos estáticos do Django
echo ""
echo "📦 4. Coletando arquivos estáticos do Django..."
python manage.py collectstatic --noinput --clear
print_success "Arquivos estáticos coletados"

# 5. Atualizar dependências do frontend
echo ""
echo "⚛️  5. Atualizando dependências do React..."
cd "$FRONTEND_DIR"
npm install
print_success "Dependências do React atualizadas"

# 6. Build do frontend
echo ""
echo "🏗️  6. Criando build de produção do React..."
npm run build
print_success "Build do React concluído"

# 7. Reiniciar serviço do backend
echo ""
echo "🔄 7. Reiniciando serviço do backend..."
sudo systemctl restart "$SERVICE_NAME"
sleep 3

# Verificar se o serviço está rodando
if sudo systemctl is-active --quiet "$SERVICE_NAME"; then
    print_success "Serviço backend reiniciado com sucesso"
else
    print_error "Falha ao reiniciar o serviço backend"
    sudo systemctl status "$SERVICE_NAME"
    exit 1
fi

# 8. Recarregar Nginx
echo ""
echo "🌐 8. Recarregando Nginx..."
sudo nginx -t && sudo systemctl reload nginx
print_success "Nginx recarregado"

echo ""
echo "========================================="
echo "✅ DEPLOY CONCLUÍDO COM SUCESSO!"
echo "========================================="
echo ""
echo "📊 Status dos serviços:"
echo ""
sudo systemctl status "$SERVICE_NAME" --no-pager -l
echo ""
echo "🌐 Aplicação disponível em: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
echo ""
