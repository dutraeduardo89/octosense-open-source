OctoSense
OctoSense é um aplicativo Android (Flutter) focado em agregação de dados de saúde. Ele lê métricas de wearables via Android Health Connect, envia os dados para um backend próprio (C# .NET) e gera insights personalizados usando um modelo de linguagem local (Ollama).

O projeto foi originalmente construído como trabalho de conclusão para a feira de tecnologia EXPOTEC (Fortec), sob o tema "Aparelhos Inteligentes e Impactos na Saúde".

Arquitetura do Sistema
O fluxo de dados funciona da seguinte forma:

Coleta (Mobile): O relógio (ex: Redmi Watch 5 Active) sincroniza com o Health Connect do Android.

Leitura (Flutter): O app lê esses dados usando o pacote health e lida com a deduplicação de fontes (evitando contagem dupla do sono, por exemplo).

Envio (HTTP): O app envia um resumo diário para a API, autenticando via JWT.

Processamento (Backend): A API (C#) salva os dados no MongoDB e, quando solicitada, envia as métricas para o Ollama gerar um resumo em texto natural.

Exibição: O app renderiza os gráficos e o insight gerado.

Ficha Técnica
Frontend: Flutter / Dart

Backend: C# / .NET / ASP.NET Core

Banco de Dados: MongoDB

IA: Ollama (Rodando localmente, modelo padrão configurável)

Autenticação: Google Sign-In + JWT (Bearer Tokens)

Integração de Saúde: Android Health Connect API

Pré-requisitos para Rodar Localmente
Para testar o projeto completo na sua máquina, você precisará de:

Flutter SDK instalado.

Docker e Docker Compose para o banco e a API.

Ollama rodando localmente (recomendado modelo llama3 ou phi3).

Um projeto no Google Cloud Console para gerar suas próprias credenciais OAuth.

Como Rodar o Projeto
Passo 1: Configurar o Backend
bash
# Clone o repositório
git clone https://github.com/dutraeduardo89/octosense-open-source.git
cd octosense-open-source

# Configure as variáveis de ambiente
cp .env.example .env
# Edite o .env com as credenciais do MongoDB

# Suba os containers (API + MongoDB)
docker-compose up -d
Passo 2: Configurar o Google OAuth (Obrigatório)
O aplicativo usa o Google Sign-In. Como as chaves originais do desenvolvedor são secretas, você precisa gerar as suas próprias no Google Cloud Console para testar o login.

Acesse o Google Cloud Console.

Crie um projeto novo.

Vá em "APIs e Serviços" -> "Tela de permissão OAuth" e configure como "Externo" em modo de teste.

Vá em "Credenciais" e crie dois IDs de cliente OAuth:

Um do tipo "Android": Insira o package name com.dutraeduardo.octosense e o SHA-1 da sua máquina (descubra com o comando keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android).

Um do tipo "Aplicativo da Web": Este você usará no backend e no app (o GOOGLE_SERVER_CLIENT_ID).

No arquivo frontend/mobile/android/app/build.gradle.kts, certifique-se de que o applicationId está batendo com o que você cadastrou.

Passo 3: Rodar o App Flutter
bash
cd frontend/mobile

# Baixe as dependências
flutter pub get

# Rode o app passando sua URL de backend e seu Client ID do Google (Web)
flutter run --dart-define=API_BASE=http://localhost:5137 --dart-define=GOOGLE_SERVER_CLIENT_ID=SEU_CLIENT_ID_AQUI
Limitações Conhecidas
Frequência Cardíaca em alguns dispositivos: O app oficial da Xiaomi (Mi Fitness) não exporta a frequência cardíaca contínua para o Health Connect. Para contornar isso, recomenda-se o uso do app open-source Gadgetbridge.

Sincronização: O app faz a leitura do Health Connect no momento em que é aberto. Não há sincronização em background no momento.

Licença
Este projeto está licenciado sob a MIT License. Veja o arquivo LICENSE para mais detalhes.

