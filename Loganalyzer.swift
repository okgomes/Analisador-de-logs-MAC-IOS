import Foundation
import SwiftUI

class LogAnalyzer {
    static let shared = LogAnalyzer()
    private let apiKey = "CHAVE PRIVADA"

    private init() {}

    func checkForMaliciousApps(in logs: [String], completion: @escaping ([String]) -> Void) {
        var alerts: [String] = []
        let dispatchGroup = DispatchGroup()

        for log in logs {
            if let appName = extractAppName(from: log) {
                dispatchGroup.enter()
                checkAppWithVirusTotal(appName: appName) { isMalicious in
                    if isMalicious {
                        alerts.append("Alerta: Aplicativo malicioso detectado - \(appName)")
                    }
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(alerts)
        }
    }

    private func extractAppName(from log: String) -> String? {
        if let range = log.range(of: "Opened ")?.upperBound {
            let substring = log[range...]
            if let endRange = substring.range(of: " at ")?.lowerBound {
                return String(substring[..<endRange])
            }
        }
        return nil
    }

    private func checkAppWithVirusTotal(appName: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://www.virustotal.com/api/v3/files/\(appName)") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let data = jsonResponse["data"] as? [String: Any],
                   let attributes = data["attributes"] as? [String: Any],
                   let lastAnalysisStats = attributes["last_analysis_stats"] as? [String: Int],
                   let malicious = lastAnalysisStats["malicious"], malicious > 0 {
                    completion(true)
                } else {
                    completion(false)
                }
            } catch {
                completion(false)
            }
        }
        task.resume()
    }
}
