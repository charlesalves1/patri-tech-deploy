# ⚡ Quick Start - Deploy PATRI-TECH na EC2

## 🎯 Objetivo
Configurar a aplicação PATRI-TECH em uma instância EC2 para rodar automaticamente, sem precisar de terminais abertos.

---

## ⏱️ Tempo estimado: 20-30 minutos

---

## 📋 Pré-requisitos

✅ Instância EC2 Ubuntu 22.04  
✅ Security Group com portas 22, 80, 443 abertas  
✅ Acesso SSH à instância  
✅ Domínio apontado para o IP (opcional)  

---

## 🚀 Passo a Passo

### 1️⃣ Conectar na EC2 e Clonar Projeto (2 min)

```bash
# Conectar via SSH
ssh -i sua-chave.pem ubuntu@seu-ip-ec2

# Clonar repositório
cd /home/ubuntu
git clone https://github.com/seu-usuario/patritech.git patritech
cd patritech
```

---

### 2️⃣ Executar Setup Inicial (5 min)

```bash
# Rodar script de setup (instala tudo automaticamente)
sudo bash deployment/setup_inicial.sh
```

Este script instala:
- Python, Node.js, Nginx, Git
- Cria ambiente virtual Python
- Configura estrutura de diretórios

---

### 3️⃣ Configurar Variáveis de Ambiente (3 min)

```bash
# Gerar SECRET_KEY
python3 -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"

# Copiar e editar .env
cp .env.example .env
nano .env
```

**Ajustar no arquivo .env:**
```bash
DJANGO_SECRET_KEY=cole-a-chave-gerada-acima
DJANGO_DEBUG=False
DJANGO_ALLOWED_HOSTS=seu-ip-ec2.compute.amazonaws.com,seu-dominio.com
```

Salvar: `Ctrl+O`, `Enter`, `Ctrl+X`

---

### 4️⃣ Preparar Backend Django (5 min)

```bash
# Ativar ambiente virtual
source venv/bin/activate

# Instalar dependências
pip install -r requirements.txt

# Executar migrações
python manage.py migrate

# Criar superusuário
python manage.py createsuperuser

# Coletar arquivos estáticos
python manage.py collectstatic --noinput
```

---

### 5️⃣ Preparar Frontend React (5 min)

```bash
# Ir para pasta do frontend
cd frontend

# Copiar e editar .env do frontend
cp .env.example .env
nano .env
```

**Ajustar:**
```bash
REACT_APP_API_URL=http://seu-dominio.com/api
```

```bash
# Instalar dependências e fazer build
npm install
npm run build

# Voltar para raiz do projeto
cd ..
```

---

### 6️⃣ Configurar Nginx (3 min)

```bash
# Editar configuração do Nginx
sudo nano /etc/nginx/sites-available/patritech
```

**Procure e altere a linha `server_name`:**
```nginx
server_name seu-dominio.com www.seu-dominio.com;
```

Para usar apenas IP:
```nginx
server_name _;
```

Salvar: `Ctrl+O`, `Enter`, `Ctrl+X`

```bash
# Ativar site
sudo ln -s /etc/nginx/sites-available/patritech /etc/nginx/sites-enabled/

# Remover site default
sudo rm -f /etc/nginx/sites-enabled/default

# Testar configuração
sudo nginx -t

# Reiniciar Nginx
sudo systemctl restart nginx
```

---

### 7️⃣ Configurar Serviço Backend (3 min)

```bash
# Editar serviço systemd
sudo nano /etc/systemd/system/patritech-backend.service
```

**Verificar/Ajustar:**
- User=ubuntu
- WorkingDirectory=/home/ubuntu/patritech
- Variáveis de ambiente (se necessário)

Salvar: `Ctrl+O`, `Enter`, `Ctrl+X`

```bash
# Recarregar systemd
sudo systemctl daemon-reload

# Habilitar serviço
sudo systemctl enable patritech-backend

# Iniciar serviço
sudo systemctl start patritech-backend
```

---

### 8️⃣ Verificar e Testar (2 min)

```bash
# Verificar status dos serviços
./deployment/manage_services.sh status

# Ou manualmente:
sudo systemctl status patritech-backend
sudo systemctl status nginx
```

**Acessar no navegador:**
- `http://seu-ip-ec2` ou `http://seu-dominio.com`

---

## ✅ Pronto! Sua aplicação está rodando!

### O que você tem agora:

✅ **Backend Django** rodando automaticamente (Gunicorn + Systemd)  
✅ **Frontend React** servido pelo Nginx  
✅ **Um único ponto de acesso** (porta 80)  
✅ **Auto-start** no boot da máquina  
✅ **Auto-restart** em caso de falha  

### Não precisa mais:
❌ Manter terminais abertos  
❌ Rodar `npm start` e `python manage.py runserver`  
❌ Se preocupar se a conexão SSH cair  

---

## 🔄 Próximas Atualizações

Para atualizar o código após mudanças:

```bash
cd /home/ubuntu/patritech
bash deployment/deploy.sh
```

Este script faz tudo automaticamente:
1. Atualiza código do Git
2. Atualiza dependências
3. Executa migrações
4. Refaz build do React
5. Reinicia serviços

---

## 🛠️ Comandos Úteis

```bash
# Ver status
./deployment/manage_services.sh status

# Ver logs em tempo real
./deployment/manage_services.sh logs

# Reiniciar serviços
./deployment/manage_services.sh restart

# Parar serviços
./deployment/manage_services.sh stop

# Iniciar serviços
./deployment/manage_services.sh start
```

---

## 🔐 Próximo Passo: SSL/HTTPS (Opcional)

```bash
# Instalar Certbot
sudo apt-get install certbot python3-certbot-nginx

# Obter certificado SSL gratuito
sudo certbot --nginx -d seu-dominio.com -d www.seu-dominio.com

# Pronto! Agora tem HTTPS
```

---

## 📚 Documentação Completa

Para mais detalhes, consulte:

- **[DEPLOY.md](DEPLOY.md)** - Guia completo de deploy
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Explicação da arquitetura
- **[README.md](README.md)** - Documentação do projeto

---

## 🆘 Problemas?

### Serviço não inicia:
```bash
sudo journalctl -u patritech-backend -n 50
```

### Nginx com erro:
```bash
sudo nginx -t
sudo tail -f /var/log/nginx/patritech_error.log
```

### Frontend não carrega:
```bash
ls -la /home/ubuntu/patritech/frontend/build/
# Se vazio, refazer build
cd frontend && npm run build
```

---

## 💡 Dicas

1. **Sempre teste depois de mudanças:**
   ```bash
   sudo nginx -t  # Testar Nginx
   sudo systemctl status patritech-backend  # Verificar backend
   ```

2. **Monitore os logs:**
   ```bash
   tail -f /home/ubuntu/logs/gunicorn_error.log
   ```

3. **Faça backups regulares:**
   ```bash
   cp db.sqlite3 db.sqlite3.backup-$(date +%Y%m%d)
   ```

---

**🎉 Parabéns! Sua aplicação está em produção!**
