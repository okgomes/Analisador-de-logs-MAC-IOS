import Foundation
import Combine

class MonitoramentoArquivos: ObservableObject {
    @Published var logs: [String] = []
    private var arquivosAnteriores: [String: [FileAttributeKey: Any]] = [:]
    private var timer: AnyCancellable?
    
    func iniciar() {
        // Iniciar a verificação a cada 10 segundos
        timer = Timer.publish(every: 10, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.verificarModificacoes()
            }

        // Log de início
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .medium)
        let logMessage = "[\(timestamp)]: Monitoramento iniciado no diretório do aplicativo..."
        self.logs.append(logMessage)
        print("[Monitoramento]: \(logMessage)")

        // Enviar log inicial
        self.sendLogsToAPI([logMessage])
    }

    func parar() {
        timer?.cancel()
        timer = nil
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .medium)
        let logMessage = "[\(timestamp)]: Monitoramento parado."
        self.logs.append(logMessage)
        print("[Monitoramento]: \(logMessage)")

        // Enviar log de parada
        self.sendLogsToAPI([logMessage])
    }

    private func verificarModificacoes() {
        let fileManager = FileManager.default
        
        // Obter o diretório do próprio aplicativo
        guard let diretorioApp = Bundle.main.resourcePath else {
            print("[Monitoramento]: Não foi possível obter o diretório do aplicativo.")
            return
        }

        let caminhoDiretorioApp = URL(fileURLWithPath: diretorioApp)
        let arquivos = try? fileManager.contentsOfDirectory(at: caminhoDiretorioApp, includingPropertiesForKeys: nil, options: [])
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .medium)
        var modificacoes: [String] = []

        print("[Monitoramento]: Verificando modificações no diretório do aplicativo...")

        arquivos?.forEach { arquivo in
            if let atributos = try? fileManager.attributesOfItem(atPath: arquivo.path) {
                let nomeArquivo = arquivo.lastPathComponent
                if let atributosAnteriores = arquivosAnteriores[arquivo.path] {
                    if let dataModificacaoAtual = atributos[.modificationDate] as? Date,
                       let dataModificacaoAnterior = atributosAnteriores[.modificationDate] as? Date,
                       dataModificacaoAtual != dataModificacaoAnterior {
                        let mensagem = "O arquivo \(nomeArquivo) foi modificado."
                        modificacoes.append(mensagem)
                    }
                } else {
                    let mensagem = "Novo arquivo detectado: \(nomeArquivo)."
                    modificacoes.append(mensagem)
                }
                arquivosAnteriores[arquivo.path] = atributos
            } else {
                print("[Monitoramento]: Não foi possível obter os atributos do arquivo: \(arquivo.path)")
            }
        }

        // Exibir logs se houver modificações
        if !modificacoes.isEmpty {
            let logMessage = "Modificações em \(timestamp):\n" + modificacoes.joined(separator: "\n")
            DispatchQueue.main.async {
                self.logs.append(logMessage)
                print("[Monitoramento]: \(logMessage)")

                // Enviar apenas os novos logs para a API
                self.sendLogsToAPI([logMessage])
            }
        } else {
            print("[Monitoramento]: Nenhuma modificação detectada.")
        }
    }

    // Enviar logs para a API
    private func sendLogsToAPI(_ newLogs: [String]) {
        let urlString = "https://x0pmhbw9sl.execute-api.us-east-1.amazonaws.com/dev/logs"
        guard let url = URL(string: urlString) else {
            print("URL inválida")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let logData = ["logs": newLogs]  // Enviar apenas os novos logs
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: logData, options: [])
            request.httpBody = jsonData

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Erro ao enviar logs: \(error)")
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("Status da resposta: \(httpResponse.statusCode)")
                }

                if let data = data, let responseData = String(data: data, encoding: .utf8) {
                    print("Resposta da API: \(responseData)")
                }
            }

            task.resume()
        } catch {
            print("Erro ao serializar JSON: \(error)")
        }
    }
}
