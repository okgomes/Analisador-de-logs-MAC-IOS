import Foundation

class LoggerWrapper: ObservableObject {
    @Published var logs: [String] = []

    func logUserAction(_ action: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .medium)
        let logEntry = "[\(timestamp)]: \(action)"
        logs.append(logEntry)
        print(logEntry) // Para depuração
    }

    func saveLogsAndSendToAPI() {
        // Implemente a lógica para salvar logs e enviar para a API
        print("Salvando logs e enviando para a API...")
    }
}
