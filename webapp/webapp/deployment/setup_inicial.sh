#!/bin/bash

# ========================================
# SCRIPT DE SETUP INICIAL - PATRI-TECH
# ========================================
# Execute este script na primeira vez, na sua instância EC2
# Execute com: sudo bash setup_inicial.sh

set -e  # Para em caso de erro

echo "========================================="
echo "⚙️  SETUP INICIAL DO PATRI-TECH NA EC2"
echo "========================================="

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Verificar se está rodando como root
if [ "$EUID" -ne 0 ]; then 
    print_error "Execute este script como root (sudo bash setup_inicial.sh)"
    exit 1
fi

# Variáveis
PROJECT_DIR="/home/ubuntu/patritech"
LOGS_DIR="/home/ubuntu/logs"

# 1. Atualizar sistema
echo ""
echo "📦 1. Atualizando sistema..."
apt-get update -y
apt-get upgrade -y
print_success "Sistema atualizado"

# 2. Instalar dependências
echo ""
echo "🔧 2. Instalando dependências..."
apt-get install -y python3 python3-pip python3-venv nginx git curl
print_success "Dependências instaladas"

# 3. Instalar Node.js (versão LTS)
echo ""
echo "📗 3. Instalando Node.js..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
    apt-get install -y nodejs
    print_success "Node.js instalado: $(node --version)"
else
    print_warning "Node.js já está instalado: $(node --version)"
fi

# 4. Criar diretórios necessários
echo ""
echo "📁 4. Criando estrutura de diretórios..."
mkdir -p "$LOGS_DIR"
chown ubuntu:ubuntu "$LOGS_DIR"
print_success "Diretórios criados"

# 5. Clonar repositório (se ainda não existe)
echo ""
echo "📥 5. Configurando repositório..."
if [ ! -d "$PROJECT_DIR" ]; then
    print_warning "Clone o repositório manualmente:"
    echo "   cd /home/ubuntu"
    echo "   git clone <url-do-repositorio> patritech"
    echo "   cd patritech"
else
    print_success "Diretório do projeto já existe"
fi

# 6. Criar ambiente virtual Python
echo ""
echo "🐍 6. Configurando ambiente virtual Python..."
if [ -d "$PROJECT_DIR" ]; then
    cd "$PROJECT_DIR"
    if [ ! -d "venv" ]; then
        sudo -u ubuntu python3 -m venv venv
        sudo -u ubuntu bash -c "source venv/bin/activate && pip install --upgrade pip"
        sudo -u ubuntu bash -c "source venv/bin/activate && pip install -r requirements.txt"
        print_success "Ambiente virtual criado e dependências instaladas"
    else
        print_warning "Ambiente virtual já existe"
    fi
else
    print_warning "Pulando criação do venv - clone o repositório primeiro"
fi

# 7. Configurar arquivo .env
echo ""
echo "🔐 7. Configurando variáveis de ambiente..."
if [ -f "$PROJECT_DIR/.env.example" ] && [ ! -f "$PROJECT_DIR/.env" ]; then
    cp "$PROJECT_DIR/.env.example" "$PROJECT_DIR/.env"
    chown ubuntu:ubuntu "$PROJECT_DIR/.env"
    print_warning "Arquivo .env criado - EDITE-O com suas configurações!"
    echo "   nano $PROJECT_DIR/.env"
else
    print_warning "Configure manualmente o arquivo .env"
fi

# 8. Configurar serviço systemd
echo ""
echo "🔧 8. Configurando serviço systemd..."
if [ -f "$PROJECT_DIR/deployment/patritech-backend.service" ]; then
    cp "$PROJECT_DIR/deployment/patritech-backend.service" /etc/systemd/system/
    print_warning "EDITE o arquivo do serviço antes de habilitar:"
    echo "   nano /etc/systemd/system/patritech-backend.service"
    echo "   Ajuste os caminhos e variáveis de ambiente"
    print_success "Arquivo de serviço copiado"
else
    print_warning "Arquivo de serviço não encontrado"
fi

# 9. Configurar Nginx
echo ""
echo "🌐 9. Configurando Nginx..."
if [ -f "$PROJECT_DIR/deployment/nginx-patritech.conf" ]; then
    cp "$PROJECT_DIR/deployment/nginx-patritech.conf" /etc/nginx/sites-available/patritech
    
    print_warning "EDITE a configuração do Nginx:"
    echo "   nano /etc/nginx/sites-available/patritech"
    echo "   Ajuste o server_name para seu domínio/IP"
    
    # Remover configuração default
    if [ -f "/etc/nginx/sites-enabled/default" ]; then
        rm -f /etc/nginx/sites-enabled/default
        print_success "Configuração default do Nginx removida"
    fi
    
    print_success "Arquivo de configuração Nginx copiado"
else
    print_warning "Arquivo de configuração Nginx não encontrado"
fi

# 10. Configurar firewall (UFW)
echo ""
echo "🔥 10. Configurando firewall..."
if command -v ufw &> /dev/null; then
    ufw allow 22/tcp      # SSH
    ufw allow 80/tcp      # HTTP
    ufw allow 443/tcp     # HTTPS
    print_success "Regras de firewall configuradas"
    print_warning "Habilite o firewall com: sudo ufw enable"
else
    print_warning "UFW não instalado"
fi

echo ""
echo "========================================="
echo "✅ SETUP INICIAL CONCLUÍDO!"
echo "========================================="
echo ""
echo "📋 PRÓXIMOS PASSOS:"
echo ""
echo "1. Clone o repositório (se ainda não fez):"
echo "   cd /home/ubuntu"
echo "   git clone <url-do-repositorio> patritech"
echo ""
echo "2. Configure as variáveis de ambiente:"
echo "   nano $PROJECT_DIR/.env"
echo ""
echo "3. Gere uma SECRET_KEY segura:"
echo "   python3 -c \"from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())\""
echo ""
echo "4. Execute as migrações do banco:"
echo "   cd $PROJECT_DIR"
echo "   source venv/bin/activate"
echo "   python manage.py migrate"
echo "   python manage.py createsuperuser"
echo ""
echo "5. Colete arquivos estáticos:"
echo "   python manage.py collectstatic"
echo ""
echo "6. Faça build do frontend:"
echo "   cd frontend"
echo "   npm install"
echo "   npm run build"
echo ""
echo "7. Ajuste a configuração do Nginx:"
echo "   sudo nano /etc/nginx/sites-available/patritech"
echo ""
echo "8. Ative a configuração do Nginx:"
echo "   sudo ln -s /etc/nginx/sites-available/patritech /etc/nginx/sites-enabled/"
echo "   sudo nginx -t"
echo "   sudo systemctl restart nginx"
echo ""
echo "9. Ajuste e habilite o serviço do backend:"
echo "   sudo nano /etc/systemd/system/patritech-backend.service"
echo "   sudo systemctl daemon-reload"
echo "   sudo systemctl enable patritech-backend"
echo "   sudo systemctl start patritech-backend"
echo ""
echo "10. Verifique os serviços:"
echo "   sudo systemctl status patritech-backend"
echo "   sudo systemctl status nginx"
echo ""
