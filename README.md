# OctoSense

OctoSense é um aplicativo Android (Flutter) focado em agregação de dados de saúde. Ele lê métricas de wearables via Android Health Connect, envia os dados para um backend próprio (C# .NET) e gera insights personalizados usando um modelo de linguagem local (Ollama).

O projeto foi originalmente construído como trabalho de conclusão para a feira de tecnologia EXPOTEC (Fortec), sob o tema "Aparelhos Inteligentes e Impactos na Saúde".

## Arquitetura do Sistema

O fluxo de dados funciona da seguinte forma:

1. **Coleta (Mobile):** O relógio (ex: Redmi Watch 5 Active) sincroniza com o Health Connect do Android.
2. **Leitura (Flutter):** O app lê esses dados usando o pacote `health` e lida com a deduplicação de fontes (evitando contagem dupla do sono, por exemplo).
3. **Envio (HTTP):** O app envia um resumo diário para a API, autenticando via JWT.
4. **Processamento (Backend):** A API (C#) salva os dados no MongoDB e, quando solicitada, envia as métricas para o Ollama gerar um resumo em texto natural.
5. **Exibição:** O app renderiza os gráficos e o insight gerado.

## Ficha Técnica

- **Frontend:** Flutter / Dart
- **Backend:** C# / .NET / ASP.NET Core
- **Banco de Dados:** MongoDB
- **IA:** Ollama (Rodando localmente, modelo padrão configurável)
- **Autenticação:** Google Sign-In + JWT (Bearer Tokens)
- **Integração de Saúde:** Android Health Connect API

## Pré-requisitos para Rodar Localmente

Para testar o projeto completo na sua máquina, você precisará de:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) instalado.
- [Docker e Docker Compose](https://docs.docker.com/get-docker/) para o banco e a API.
- [Ollama](https://ollama.com/) rodando localmente (recomendado modelo `llama3` ou `phi3`).
- Um projeto no **Google Cloud Console** para gerar suas próprias credenciais OAuth.

## Como Rodar o Projeto

### Passo 1: Configurar o Backend
```bash
# Clone o repositório
git clone https://github.com/dutraeduardo89/octosense-open-source.git
cd octosense-open-source

# Configure as variáveis de ambiente
cp .env.example .env
# Edite o .env com as credenciais do MongoDB

# Suba os containers (API + MongoDB)
docker-compose up -d
