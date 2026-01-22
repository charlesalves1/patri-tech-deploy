"""
Configuração do Gunicorn para o PATRI-TECH
Este arquivo define como o Gunicorn irá executar a aplicação Django em produção
"""

import multiprocessing
import os

# Caminho para o arquivo WSGI do Django
wsgi_app = "projeto.wsgi:application"

# Bind - onde o Gunicorn irá escutar
# 0.0.0.0:8000 permite acesso de qualquer IP na porta 8000
bind = "0.0.0.0:8000"

# Workers - número de processos workers
# Recomendação: (2 x CPU cores) + 1
workers = multiprocessing.cpu_count() * 2 + 1

# Threads por worker
threads = 2

# Tipo de worker
# sync = para aplicações tradicionais (recomendado para Django)
# gevent ou eventlet = para aplicações assíncronas
worker_class = "sync"

# Timeout em segundos
# Tempo máximo que um worker pode levar para processar uma requisição
timeout = 120

# Keep alive
# Tempo que a conexão fica aberta aguardando próxima requisição
keepalive = 5

# Logs
accesslog = "/home/ubuntu/logs/gunicorn_access.log"
errorlog = "/home/ubuntu/logs/gunicorn_error.log"
loglevel = "info"

# Recarregar automaticamente quando o código mudar (apenas em desenvolvimento)
reload = os.environ.get('DJANGO_DEBUG', 'False') == 'True'

# Daemon mode - NÃO usar True quando gerenciado por systemd
daemon = False

# PID file
pidfile = "/home/ubuntu/logs/gunicorn.pid"

# User e Group (descomente e ajuste conforme necessário)
# user = "ubuntu"
# group = "ubuntu"

# Preload app - carrega a aplicação antes de fazer fork dos workers
# Economiza memória RAM mas pode causar problemas em algumas configurações
preload_app = True

# Max requests - número de requisições que um worker processa antes de reiniciar
# Previne memory leaks
max_requests = 1000
max_requests_jitter = 50

# Graceful timeout
graceful_timeout = 30

# Configurações de segurança
limit_request_line = 4096
limit_request_fields = 100
limit_request_field_size = 8190
