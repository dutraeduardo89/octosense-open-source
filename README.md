# OctoSense

Flutter | C# | .NET | MongoDB

O OctoSense é um aplicativo Android que coleta e centraliza dados de saúde de dispositivos vestíveis, utilizando o Android Health Connect. Os dados são enviados para um backend próprio e utilizados para gerar resumos com um modelo de linguagem local.

O projeto foi desenvolvido como trabalho de conclusão para a feira de tecnologia EXPOTEC (Fortec), com o tema "Aparelhos Inteligentes e Impactos na Saúde".

## Arquitetura

O funcionamento do sistema segue estas etapas:

1. **Coleta:** o relógio sincroniza as métricas com o Health Connect.
2. **Leitura:** o aplicativo Flutter acessa os dados por meio do pacote `health` e realiza a deduplicação dos registros.
3. **Envio:** os dados são enviados para a API por meio de requisições HTTP autenticadas com JWT.
4. **Processamento:** o backend armazena as informações no MongoDB e envia as métricas ao Ollama.
5. **Exibição:** o aplicativo apresenta os dados em gráficos e exibe o resumo gerado pelo modelo.

## Tecnologias

| Componente | Tecnologia | Utilização |
| --- | --- | --- |
| Frontend | Flutter / Dart | Aplicativo Android |
| Gráficos | fl\_chart | Visualização das métricas |
| Injeção de dependência | get\_it | Gerenciamento de dependências |
| Backend | C# / .NET | API com ASP.NET Core e Minimal APIs |
| Arquitetura | Clean Architecture | Organização do backend |
| Banco de dados | MongoDB | Armazenamento de usuários e métricas |
| IA | Ollama | Execução local de modelos de linguagem |
| Autenticação | Google Sign-In + JWT | Autenticação e controle de acesso |
| Dados de saúde | Android Health Connect | Acesso às métricas dos dispositivos |

## Pré-requisitos

- Flutter SDK.
- Docker e Docker Compose.
- Ollama instalado.
- Um modelo compatível com o Ollama, como `llama3` ou `phi3`.
- Projeto configurado no Google Cloud Console para autenticação OAuth.

## Instalação

### 1\. Backend

Clone o repositório:

bash

```bash
git clone https://github.com/dutraeduardo89/octosense-open-source.git

cd octosense-open-source
```

Configure as variáveis de ambiente:

bash

```bash
cp .env.example .env
```

Edite o arquivo `.env` com as configurações necessárias, incluindo as credenciais do MongoDB.

Inicie os containers:

bash

```bash
docker-compose up -d
```

### 2\. Google OAuth

O aplicativo utiliza o Google Sign-In. Para executar o projeto, é necessário configurar suas próprias credenciais.

1. Acesse o [Google Cloud Console](<https://console.cloud.google.com/>).
2. Crie um projeto.
3. Acesse a configuração da tela de permissão OAuth.
4. Configure o aplicativo como externo e habilite o modo de teste.
5. Acesse a área de credenciais e crie os seguintes clientes OAuth:

**Cliente Android**

- Tipo: Android.
- Package name: `com.dutraeduardo.octosense`.
- SHA-1: impressão digital da chave de assinatura utilizada no desenvolvimento.

Para obter o SHA-1 da chave de debug:

bash

```bash
keytool -list -v \
-keystore ~/.android/debug.keystore \
-alias androiddebugkey \
-storepass android \
-keypass android
```

**Cliente Web**

Crie um cliente OAuth do tipo Aplicativo da Web e copie o Client ID gerado.

Esse identificador será utilizado na configuração `GOOGLE_SERVER_CLIENT_ID`.

Verifique também se o `applicationId` em `frontend/mobile/android/app/build.gradle.kts` corresponde ao package name cadastrado.

### 3\. Aplicativo Flutter

Entre na pasta do aplicativo:

bash

```bash
cd frontend/mobile
```

Instale as dependências:

bash

```bash
flutter pub get
```

Execute o aplicativo:

bash

```bash
flutter run \
--dart-define=API_BASE=http://localhost:5137 \
--dart-define=GOOGLE_SERVER_CLIENT_ID=SEU_CLIENT_ID_AQUI
```

Se estiver utilizando um dispositivo Android físico, substitua `localhost` pelo endereço IP local da máquina que executa o backend.

## Limitações conhecidas

- **Frequência cardíaca:** o Mi Fitness pode não disponibilizar registros contínuos de frequência cardíaca no Health Connect. Uma alternativa é utilizar o [Gadgetbridge](<https://gadgetbridge.org/>).
- **Sincronização:** atualmente, os dados são consultados quando o aplicativo é aberto. A sincronização em segundo plano ainda não está implementada.

## Licença

Este projeto está licenciado sob a MIT License. Consulte o arquivo LICENSE para mais informações.
