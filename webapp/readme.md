# PATRI-TECH 🏢
**Sistema de Gestão de Patrimônio e Ativos**

O **PATRI-TECH** é uma aplicação Full-Stack desenvolvida para o controle eficiente de bens patrimoniais, unidades, categorias e gestão de usuários com permissões específicas.

---

## 🛠 Tecnologias Utilizadas

Este projeto foi construído utilizando uma arquitetura moderna separada em **Backend (API)** e **Frontend (Interface)**.

### 🐍 Backend (Servidor & API)
O núcleo do sistema, responsável pela lógica de negócios, banco de dados e segurança.

* **Linguagem:** Python 3.12+
* **Framework Principal:** Django 5.x
* **API:** Django REST Framework (DRF)
* **Banco de Dados:** SQLite (Desenvolvimento)
* **Autenticação:** JWT (JSON Web Tokens) via `djangorestframework-simplejwt`
* **Segurança de API:** `django-cors-headers` (Controle de acesso CORS)
* **Interface Administrativa:** Customizada com **Jazzmin**
* **Documentação da API:** `drf-spectacular` (Swagger/OpenAPI)

### ⚛️ Frontend (Interface do Usuário)
A interface visual onde o usuário interage com o sistema.

* **Biblioteca Principal:** React.js
* **Gerenciador de Pacotes:** NPM
* **Comunicação HTTP:** Axios (Para consumir a API do Django)
* **Roteamento:** React Router Dom
* **Ícones:** FontAwesome
* **Estilização:** CSS3 Customizado

---

## ⚙️ Funcionalidades Principais

* **Dashboard Interativo:** Visualização rápida do total de bens, unidades, categorias e valor total do patrimônio.
* **Gestão de Unidades:** Cadastro e controle de locais (escolas, prédios, departamentos).
* **Gestão de Bens:** Controle completo de ativos com valores e categorias.
* **Controle de Acesso (Gestores):**
    * Sistema de permissões granulares (checkboxes).
    * Permissões configuráveis: *Pode Cadastrar*, *Pode Editar*, *Pode Dar Baixa*.
* **Segurança:** Proteção contra cadastro duplicado (CPF Único) e rotas protegidas por Token.

---

## 🚀 Como Rodar o Projeto

### 🖥️ Desenvolvimento Local

Para rodar o sistema em **desenvolvimento**, é necessário iniciar o servidor Backend e o servidor Frontend em terminais separados.

#### 1. Rodando o Backend (Django)
```bash
# Entre na pasta raiz e ative o ambiente virtual
source venv/bin/activate  # Linux/Mac
# ou
venv\Scripts\activate     # Windows

# Instale as dependências (se necessário)
pip install -r requirements.txt

# Execute as migrações do banco
python manage.py migrate

# Crie um superusuário (primeira vez)
python manage.py createsuperuser

# Inicie o servidor
python manage.py runserver
```

#### 2. Rodando o Frontend (React)
Em **outro terminal**:

```bash
# Entre na pasta do frontend
cd frontend

# Instale as dependências (primeira vez)
npm install

# Inicie o servidor de desenvolvimento
npm start
```

O frontend estará disponível em `http://localhost:3000` e o backend em `http://localhost:8000`.

---

### 🚀 Deploy em Produção (EC2)

Para colocar a aplicação em **produção** sem precisar rodar dois terminais, consulte o guia completo de deploy:

**📖 [GUIA DE DEPLOY COMPLETO](DEPLOY.md)**

O guia inclui:
- ✅ Configuração automática com scripts prontos
- ✅ Nginx como servidor web único
- ✅ Gunicorn para o Django
- ✅ Systemd para gerenciamento automático de serviços
- ✅ SSL/HTTPS com Let's Encrypt
- ✅ Scripts de deploy e gerenciamento
- ✅ Troubleshooting completo

**Resumo rápido:**

```bash
# 1. Setup inicial (primeira vez)
sudo bash deployment/setup_inicial.sh

# 2. Deploy/Atualizações
bash deployment/deploy.sh

# 3. Gerenciar serviços
./deployment/manage_services.sh status|start|stop|restart|logs
```

---

## 📁 Estrutura do Projeto

```
patritech/
├── projeto/                 # Configurações do Django
│   ├── settings.py         # Configurações principais
│   ├── urls.py            # Rotas principais
│   └── wsgi.py            # WSGI para produção
├── core/                   # App principal do Django
│   ├── models.py          # Modelos de dados
│   ├── views.py           # Views da API
│   ├── serializers.py     # Serializers DRF
│   └── urls.py            # Rotas da API
├── frontend/              # Aplicação React
│   ├── src/               # Código-fonte
│   ├── public/            # Arquivos públicos
│   └── build/             # Build de produção
├── deployment/            # Arquivos de deploy
│   ├── setup_inicial.sh   # Setup inicial da EC2
│   ├── deploy.sh          # Script de deploy
│   ├── manage_services.sh # Gerenciamento de serviços
│   ├── nginx-patritech.conf  # Config Nginx
│   └── patritech-backend.service  # Service systemd
├── gunicorn_config.py     # Configuração do Gunicorn
├── requirements.txt       # Dependências Python
├── .env.example          # Exemplo de variáveis de ambiente
├── DEPLOY.md             # Guia completo de deploy
└── README.md             # Este arquivo