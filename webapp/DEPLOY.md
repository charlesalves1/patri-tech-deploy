# 🚀 Guia Completo de Deploy - PATRI-TECH

Este guia explica como fazer o deploy completo da aplicação **PATRI-TECH** em uma instância EC2 da AWS, eliminando a necessidade de rodar dois terminais separados.

## 📋 Índice

- [Visão Geral da Arquitetura](#visão-geral-da-arquitetura)
- [Pré-requisitos](#pré-requisitos)
- [Setup Inicial na EC2](#setup-inicial-na-ec2)
- [Configuração Passo a Passo](#configuração-passo-a-passo)
- [Deploy e Atualizações](#deploy-e-atualizações)
- [Gerenciamento de Serviços](#gerenciamento-de-serviços)
- [Monitoramento e Logs](#monitoramento-e-logs)
- [Troubleshooting](#troubleshooting)
- [Configuração SSL (HTTPS)](#configuração-ssl-https)

---

## 🏗️ Visão Geral da Arquitetura

### Como funciona em PRODUÇÃO:

```
┌─────────────────────────────────────────────────────────────┐
│                        USUÁRIO                              │
└─────────────────────────────────────────────────────────────┘
                            ↓
                    (Porta 80/443)
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                         NGINX                               │
│  • Serve o React (build estático)                          │
│  • Faz proxy reverso para API Django                       │
│  • Gerencia SSL/HTTPS                                       │
│  • Cache de arquivos estáticos                             │
└─────────────────────────────────────────────────────────────┘
                            ↓
                ┌───────────┴───────────┐
                ↓                       ↓
    ┌──────────────────────┐  ┌──────────────────────┐
    │   REACT (Build)      │  │  DJANGO API          │
    │   /var/www/build     │  │  Gunicorn:8000       │
    │   • index.html       │  │  • REST API          │
    │   • JS/CSS           │  │  • Admin             │
    │   • Assets           │  │  • Autenticação      │
    └──────────────────────┘  └──────────────────────┘
                                        ↓
                              ┌──────────────────────┐
                              │  SQLite/PostgreSQL   │
                              │  Banco de Dados      │
                              └──────────────────────┘
```

### Componentes:

1. **Nginx** - Servidor web que:
   - Serve os arquivos estáticos do React (build)
   - Redireciona requisições `/api/*` para o Django
   - Gerencia SSL/HTTPS
   - Funciona como load balancer

2. **Gunicorn** - Servidor WSGI que:
   - Executa a aplicação Django em produção
   - Gerencia múltiplos workers
   - Roda automaticamente via systemd

3. **Systemd** - Gerenciador de serviços que:
   - Inicia o Gunicorn automaticamente no boot
   - Reinicia em caso de falha
   - Gerencia logs

---

## 📦 Pré-requisitos

### 1. Instância EC2
- Ubuntu 22.04 LTS (recomendado)
- Tipo: t2.small ou superior
- Armazenamento: 20GB mínimo

### 2. Security Group
Configure as seguintes portas:
- **22** (SSH) - Para acesso ao servidor
- **80** (HTTP) - Para tráfego web
- **443** (HTTPS) - Para tráfego web seguro

### 3. Domínio (Opcional mas recomendado)
- Registre um domínio
- Aponte o DNS para o IP da EC2

---

## ⚙️ Setup Inicial na EC2

### 1. Conectar na EC2

```bash
ssh -i sua-chave.pem ubuntu@seu-ip-ec2
```

### 2. Executar Script de Setup Inicial

```bash
# Clonar o repositório
cd /home/ubuntu
git clone https://github.com/seu-usuario/patritech.git patritech

# Executar setup inicial
cd patritech
sudo bash deployment/setup_inicial.sh
```

Este script irá:
- ✅ Atualizar o sistema
- ✅ Instalar Python, Node.js, Nginx
- ✅ Criar estrutura de diretórios
- ✅ Configurar ambiente virtual Python
- ✅ Copiar arquivos de configuração

---

## 🔧 Configuração Passo a Passo

### 1. Configurar Variáveis de Ambiente

```bash
# Copiar exemplo e editar
cd /home/ubuntu/patritech
cp .env.example .env
nano .env
```

**Configurações importantes:**

```bash
# Gerar uma SECRET_KEY segura
python3 -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"

# Editar .env
DJANGO_SECRET_KEY=sua-chave-super-secreta-gerada-acima
DJANGO_DEBUG=False
DJANGO_ALLOWED_HOSTS=seu-dominio.com,seu-ip-ec2.compute.amazonaws.com
```

### 2. Configurar Banco de Dados

```bash
# Ativar ambiente virtual
source venv/bin/activate

# Executar migrações
python manage.py migrate

# Criar superusuário
python manage.py createsuperuser

# Coletar arquivos estáticos
python manage.py collectstatic --noinput
```

### 3. Configurar Frontend

```bash
cd frontend

# Copiar e editar .env do React
cp .env.example .env
nano .env
```

```bash
# Ajustar para produção
REACT_APP_API_URL=http://seu-dominio.com/api
```

```bash
# Instalar dependências e fazer build
npm install
npm run build
```

### 4. Configurar Nginx

```bash
# Editar configuração
sudo nano /etc/nginx/sites-available/patritech
```

**Ajustar:**
- `server_name` para seu domínio/IP
- Caminhos dos diretórios se necessário

```bash
# Ativar configuração
sudo ln -s /etc/nginx/sites-available/patritech /etc/nginx/sites-enabled/

# Remover configuração default
sudo rm -f /etc/nginx/sites-enabled/default

# Testar configuração
sudo nginx -t

# Reiniciar Nginx
sudo systemctl restart nginx
```

### 5. Configurar Serviço Systemd

```bash
# Editar serviço
sudo nano /etc/systemd/system/patritech-backend.service
```

**Ajustar:**
- Variáveis de ambiente
- Caminhos
- Usuário/Grupo

```bash
# Recarregar systemd
sudo systemctl daemon-reload

# Habilitar serviço no boot
sudo systemctl enable patritech-backend

# Iniciar serviço
sudo systemctl start patritech-backend

# Verificar status
sudo systemctl status patritech-backend
```

---

## 🚀 Deploy e Atualizações

### Deploy Automatizado

Após a primeira configuração, use o script de deploy para atualizações:

```bash
cd /home/ubuntu/patritech
bash deployment/deploy.sh
```

Este script irá:
1. ✅ Atualizar código do Git
2. ✅ Atualizar dependências Python
3. ✅ Executar migrações
4. ✅ Coletar arquivos estáticos
5. ✅ Atualizar dependências React
6. ✅ Criar novo build do React
7. ✅ Reiniciar backend
8. ✅ Recarregar Nginx

### Deploy Manual

Se preferir fazer manualmente:

```bash
# 1. Atualizar código
git pull origin main

# 2. Backend
source venv/bin/activate
pip install -r requirements.txt
python manage.py migrate
python manage.py collectstatic --noinput

# 3. Frontend
cd frontend
npm install
npm run build

# 4. Reiniciar serviços
sudo systemctl restart patritech-backend
sudo systemctl reload nginx
```

---

## 🛠️ Gerenciamento de Serviços

Use o script de gerenciamento:

```bash
cd /home/ubuntu/patritech

# Ver status
./deployment/manage_services.sh status

# Iniciar todos os serviços
./deployment/manage_services.sh start

# Parar todos os serviços
./deployment/manage_services.sh stop

# Reiniciar todos os serviços
./deployment/manage_services.sh restart

# Ver logs do backend
./deployment/manage_services.sh logs

# Ver logs do Nginx
./deployment/manage_services.sh logs-nginx

# Habilitar no boot
./deployment/manage_services.sh enable

# Desabilitar no boot
./deployment/manage_services.sh disable
```

### Comandos Systemd Manuais

```bash
# Backend
sudo systemctl status patritech-backend
sudo systemctl start patritech-backend
sudo systemctl stop patritech-backend
sudo systemctl restart patritech-backend
sudo systemctl enable patritech-backend
sudo systemctl disable patritech-backend

# Nginx
sudo systemctl status nginx
sudo systemctl start nginx
sudo systemctl stop nginx
sudo systemctl restart nginx
sudo systemctl reload nginx  # Recarrega config sem derrubar conexões
```

---

## 📊 Monitoramento e Logs

### Ver Logs em Tempo Real

```bash
# Logs do backend (Gunicorn)
sudo journalctl -u patritech-backend -f

# Logs do Nginx - Access
sudo tail -f /var/log/nginx/patritech_access.log

# Logs do Nginx - Errors
sudo tail -f /var/log/nginx/patritech_error.log

# Logs do Gunicorn
tail -f /home/ubuntu/logs/gunicorn_access.log
tail -f /home/ubuntu/logs/gunicorn_error.log
```

### Verificar Status dos Processos

```bash
# Ver processos Gunicorn rodando
ps aux | grep gunicorn

# Ver processos Nginx
ps aux | grep nginx

# Ver uso de recursos
htop  # ou top
```

### Verificar Conectividade

```bash
# Testar backend diretamente
curl http://localhost:8000/api/

# Testar Nginx
curl http://localhost/

# Testar do exterior (substitua pelo seu IP)
curl http://seu-ip-ec2/
```

---

## 🔧 Troubleshooting

### Problema: Serviço não inicia

```bash
# Ver logs detalhados
sudo journalctl -u patritech-backend -n 100 --no-pager

# Verificar configuração
sudo systemctl status patritech-backend

# Testar manualmente
cd /home/ubuntu/patritech
source venv/bin/activate
gunicorn --config gunicorn_config.py projeto.wsgi:application
```

### Problema: Nginx retorna 502 Bad Gateway

**Causas comuns:**
- Backend não está rodando
- Porta 8000 não está acessível
- Firewall bloqueando

```bash
# Verificar se backend está rodando
sudo systemctl status patritech-backend

# Verificar se porta 8000 está ouvindo
sudo netstat -tlnp | grep 8000

# Testar conexão
curl http://localhost:8000/api/
```

### Problema: Frontend não carrega

```bash
# Verificar se build existe
ls -la /home/ubuntu/patritech/frontend/build/

# Refazer build
cd /home/ubuntu/patritech/frontend
npm run build

# Verificar permissões
sudo chown -R ubuntu:ubuntu /home/ubuntu/patritech/frontend/build/
```

### Problema: Alterações não aparecem

```bash
# Limpar cache do navegador
# Ou adicionar versão aos assets no React

# Recarregar serviços
sudo systemctl restart patritech-backend
sudo systemctl reload nginx

# Verificar se código está atualizado
cd /home/ubuntu/patritech
git status
git log -1
```

### Problema: Permissões de arquivo

```bash
# Corrigir permissões
sudo chown -R ubuntu:ubuntu /home/ubuntu/patritech/
sudo chown -R ubuntu:ubuntu /home/ubuntu/logs/

# Permissões do banco de dados
chmod 664 /home/ubuntu/patritech/db.sqlite3
```

---

## 🔒 Configuração SSL (HTTPS)

### Usando Let's Encrypt (Gratuito)

```bash
# Instalar Certbot
sudo apt-get install certbot python3-certbot-nginx

# Obter certificado (ajuste o domínio)
sudo certbot --nginx -d seu-dominio.com -d www.seu-dominio.com

# Renovação automática já está configurada
# Teste a renovação:
sudo certbot renew --dry-run
```

### Configuração Manual no Nginx

Descomente as linhas SSL no arquivo `/etc/nginx/sites-available/patritech`:

```nginx
listen 443 ssl http2;
listen [::]:443 ssl http2;
ssl_certificate /etc/letsencrypt/live/seu-dominio.com/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/seu-dominio.com/privkey.pem;
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers HIGH:!aNULL:!MD5;
```

Também descomente o redirect HTTP → HTTPS:

```nginx
server {
    listen 80;
    server_name seu-dominio.com www.seu-dominio.com;
    return 301 https://$server_name$request_uri;
}
```

```bash
# Testar e recarregar
sudo nginx -t
sudo systemctl reload nginx
```

---

## 📝 Checklist Final

Antes de colocar em produção, verifique:

- [ ] `DJANGO_DEBUG=False` no `.env`
- [ ] `DJANGO_SECRET_KEY` única e segura
- [ ] `ALLOWED_HOSTS` configurado corretamente
- [ ] Migrações executadas
- [ ] Arquivos estáticos coletados
- [ ] Frontend buildado
- [ ] Nginx configurado e testado
- [ ] Serviço systemd habilitado
- [ ] Firewall configurado (portas 80, 443)
- [ ] SSL/HTTPS configurado (recomendado)
- [ ] Backups configurados
- [ ] Monitoramento configurado

---

## 🎯 Resultado Final

Após seguir todos os passos:

✅ **Backend Django** rodará automaticamente via Gunicorn/systemd  
✅ **Frontend React** será servido como arquivos estáticos pelo Nginx  
✅ **Nginx** gerenciará todas as requisições na porta 80/443  
✅ **Apenas 1 ponto de acesso** para os usuários  
✅ **Reinício automático** dos serviços em caso de falha  
✅ **Auto-start** no boot da máquina  
✅ **Logs centralizados** e fáceis de monitorar  

**Acesso:**
- Frontend: `http://seu-dominio.com` ou `http://seu-ip-ec2`
- Admin Django: `http://seu-dominio.com/admin`
- API: `http://seu-dominio.com/api/`
- Docs API: `http://seu-dominio.com/api/docs/`

---

## 📞 Suporte

Para mais informações sobre cada componente:

- Django: https://docs.djangoproject.com/
- Gunicorn: https://docs.gunicorn.org/
- Nginx: https://nginx.org/en/docs/
- Systemd: https://systemd.io/
- Let's Encrypt: https://letsencrypt.org/

---

**Desenvolvido com ❤️ pela equipe PATRI-TECH**
