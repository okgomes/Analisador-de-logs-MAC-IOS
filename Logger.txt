import Foundation

class Logger {
    static let shared = Logger()
    private var dateFormatter: DateFormatter
    private var logCounter: Int
    private var logs: [String] = []

    private init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        logCounter = UserDefaults.standard.integer(forKey: "LogCounter")
    }

    func logUserAction(_ action: String) {
        let timestamp = dateFormatter.string(from: Date())
        let logEntry = "[\(timestamp)]: \(action)"
        logs.append(logEntry)
        print(logEntry)

        analyzeLogs()
    }

    func analyzeLogs() {
        LogAnalyzer.shared.checkForMaliciousApps(in: logs) { [weak self] alerts in
            for alert in alerts {
                print(alert)
                self?.logs.append(alert) // Adiciona alertas aos logs
            }
            self?.sendLogsToAPI() // Envia logs e alertas para a API
        }
    }

    func saveLogsAndSendToAPI() {
        saveLogsToFile()
    }

    private func saveLogsToFile() {
        let fileManager = FileManager.default
        let directoryPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "log\(logCounter).txt"
        let filePath = directoryPath.appendingPathComponent(fileName)

        let logText = logs.joined(separator: "\n")

        do {
            try logText.write(to: filePath, atomically: true, encoding: .utf8)
            print("Logs salvos em \(filePath.path)")
        } catch {
            print("Falha ao salvar logs: \(error)")
        }

        logCounter += 1
        UserDefaults.standard.set(logCounter, forKey: "LogCounter")
        logs.removeAll() // Limpa logs após salvá-los
    }

    private func sendLogsToAPI() {
        let urlString = "https://x0pmhbw9sl.execute-api.us-east-1.amazonaws.com/dev/logs"
        guard let url = URL(string: urlString) else {
            print("URL inválida")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let logData = ["logs": logs]
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
