/**
 * Configuração da API para o PATRI-TECH
 * 
 * Este arquivo centraliza a URL da API para facilitar o deploy
 * em diferentes ambientes (desenvolvimento, staging, produção)
 */

// Detecta automaticamente o ambiente baseado no hostname
const getApiUrl = () => {
  // Em desenvolvimento
  if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
    return 'http://localhost:8000';
  }
  
  // Em produção - a API estará no mesmo domínio, apenas na porta 8000
  // ou use /api se configurado proxy no Nginx
  return window.location.origin.replace(/:\d+$/, '') + ':8000';
  
  // Alternativa: se usar Nginx proxy (recomendado)
  // return window.location.origin + '/api';
};

export const API_BASE_URL = process.env.REACT_APP_API_URL || getApiUrl();

// Configurações adicionais
export const API_CONFIG = {
  timeout: 30000, // 30 segundos
  headers: {
    'Content-Type': 'application/json',
  },
};

// Helper para construir URLs completas
export const buildApiUrl = (endpoint) => {
  // Remove barra inicial se houver para evitar duplicação
  const cleanEndpoint = endpoint.startsWith('/') ? endpoint.slice(1) : endpoint;
  return `${API_BASE_URL}/${cleanEndpoint}`;
};

// Exporta também a URL base como default
export default API_BASE_URL;
