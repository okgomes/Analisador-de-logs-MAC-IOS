# Analisador-de-logs-MAC-IOS

Sobre o Projeto

Ele é um aplicativo desenvolvido em Swift para macOS e iOS que monitora atividades de aplicativos em execução e realiza análise de logs para identificar possíveis agentes maliciosos. Ele integra recursos como monitoramento de arquivos, coleta de localização, e análise de segurança utilizando APIs externas.
O objetivo principal do projeto é fornecer uma ferramenta automatizada para identificar atividades suspeitas ou maliciosas em tempo real, enviando os dados coletados para análise centralizada na nuvem da AWS.

Recursos Principais

- Monitoramento de Aplicativos: Detecta e registra quando um aplicativo é iniciado ou ativado.
- Análise de Logs: Analisa registros coletados para identificar atividades maliciosas com integração à API do VirusTotal.
- Monitoramento de Arquivos: Detecta alterações em arquivos no diretório do aplicativo.
- Coleta de Localização: Coleta coordenadas geográficas periodicamente (no iOS).
- Envio de Logs: Envia logs para uma API REST para armazenamento e análise centralizada.


Estrutura do Projeto

1. Coleta_log_userApp.swift
Descrição: Arquivo principal que gerencia o ciclo de vida do aplicativo.
Integrações Principais:
LoggerWrapper: Gerencia e salva logs de eventos.
MonitoramentoArquivos: Monitora mudanças em arquivos no diretório do aplicativo.
Ciclo de vida da aplicação: Registra eventos como ativação e finalização do app.

2. ContentView.swift
Descrição: Interface gráfica desenvolvida com SwiftUI.
Funcionalidades:
Exibição de logs coletados.
Visualização da localização atual do usuário no iOS.
Monitoramento em tempo real.

3. LogAnalyzer.swift
Descrição: Classe responsável por análise de logs.
Principais Funções:
Extrai nomes de aplicativos dos registros coletados.
Integração com a API do VirusTotal para verificar a reputação de arquivos ou aplicativos.
Gera alertas de segurança para atividades suspeitas.

4. AppDelegate.swift
Descrição: Classe que monitora notificações do sistema.
Funções Implementadas:
Registra aplicativos em execução ou ativados.
Verifica periodicamente todos os processos ativos no sistema.

5. MonitoramentoArquivos.swift
Descrição: Classe que monitora alterações no diretório local do aplicativo.
Recursos:
Detecta novos arquivos ou modificações.
Envia logs dessas alterações para uma API centralizada.

6. Logger.swift
Descrição: Gerenciador central de logs.
Funções:
Registra eventos com timestamps.
Realiza análise contínua para identificar comportamentos maliciosos ou anômalos.
Integra logs com outros módulos do projeto.

7. LocationManager.swift
Descrição: Classe que gerencia a localização do dispositivo (iOS).
Principais Recursos:
Coleta de latitude e longitude periodicamente.
Envio dos dados para uma API REST configurada.
Integração com temporizador para atualizações a cada 20 segundos.

8. LoggerWrapper.swift
Descrição: Classe auxiliar para gerenciar ações do usuário.
Funcionalidades:
Registra eventos do usuário com data e hora.
Salva logs localmente e prepara dados para envio à API.
