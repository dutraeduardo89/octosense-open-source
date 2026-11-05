# 🐙 OctoSense

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![C#](https://img.shields.io/badge/C%23-239120?style=for-the-badge&logo=c-sharp&logoColor=white)
![.NET](https://img.shields.io/badge/.NET-512BD4?style=for-the-badge&logo=dotnet&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB-4EA94B?style=for-the-badge&logo=mongodb&logoColor=white)

O **OctoSense** é um aplicativo de monitoramento de saúde que conecta dados de relógios inteligentes (via Android Health Connect) a um backend próprio, gerando insights personalizados com Inteligência Artificial local.

Este projeto foi originalmente desenvolvido para a feira de tecnologia **EXPOTEC (Fortec)** com o tema: *"Aparelhos Inteligentes e Impactos na Saúde"*.

---

## ✨ Funcionalidades

- 📊 **Dashboard em tempo real:** Passos, calorias ativas/totais, oxigenação (SpO2) e sono.
- ❤️ **Frequência Cardíaca:** Leitura contínua com gráficos ao longo do dia.
- �� **Insights com IA:** Utiliza Ollama (modelo local) para gerar resumos semanais da sua saúde.
- 🔐 **Autenticação Segura:** Login via Google OAuth 2.0 com validação de token JWT no backend.
- ⌚ **Multi-dispositivos:** Suporte nativo ao Health Connect (com fallback para Gadgetbridge em relógios Xiaomi/Redmi).

---

## 🏗️ Arquitetura

[Relógio Inteligente] 
       │ (Bluetooth)
       ▼
[Health Connect / Gadgetbridge] 
       │ (API Nativa)
       ▼
[App Flutter] ──(HTTP/JWT)──► [Backend C# .NET] ──► [MongoDB]
                                     │
                                     ▼
                               [Ollama IA]

---

## 🚀 Como rodar o projeto localmente

### Pré-requisitos
- Flutter SDK
- Docker e Docker Compose
- .NET 8 SDK
- Ollama (rodando localmente)

### 1. Backend (Docker)
Clone o repositório:
git clone https://github.com/seu-usuario/octosense.git
cd octosense

Configure as variáveis de ambiente:
cp .env.example .env
(Edite o .env com suas credenciais)

Suba o banco e a API:
docker-compose up -d

### 2. Frontend (Flutter)
cd frontend/mobile

Baixe as dependências:
flutter pub get

Rode o app apontando para o seu backend local e seu Client ID do Google:
flutter run --dart-define=API_BASE=http://localhost:5137 --dart-define=GOOGLE_SERVER_CLIENT_ID=SEU_CLIENT_ID_AQUI

---

## 🤝 Como Contribuir

1. Faça um Fork do projeto.
2. Crie uma branch para sua feature (git checkout -b feature/MinhaNovaFeature).
3. Commit suas mudanças (git commit -m 'feat: Adiciona suporte ao Apple HealthKit').
4. Faça o push para a branch (git push origin feature/MinhaNovaFeature).
5. Abra um Pull Request.

---

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---
Feito com 💙 por [Eduardo Dutra](https://github.com/seu-usuario)
