import Cocoa
import Foundation

class AppDelegate: NSObject, NSApplicationDelegate {
    var timer: Timer?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NotificationCenter.default.addObserver(self, selector: #selector(handleApplicationActivation(_:)), name: NSWorkspace.didActivateApplicationNotification, object: nil)
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(logRunningApplications), userInfo: nil, repeats: true)
        logRunningApplications()
    }

    @objc func handleApplicationActivation(_ notification: Notification) {
        guard let application = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else { return }
        let appName = application.localizedName ?? "App Desconhecido"
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .medium)
        let logMessage = "Opened \(appName) at \(timestamp)"
        
        // Salvar o log usando Logger
        Logger.shared.logUserAction(logMessage)

        // Analisar se o aplicativo é malicioso
        LogAnalyzer.shared.checkForMaliciousApps(in: [logMessage]) { alerts in
            for alert in alerts {
                Logger.shared.logUserAction(alert)
            }
        }
    }

    @objc func logRunningApplications() {
        let runningApps = NSWorkspace.shared.runningApplications
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .medium)
        var logMessage = "Aplicativos em execução em \(timestamp):\n"

        for app in runningApps {
            guard let appName = app.localizedName else { continue }
            logMessage += "\(appName)\n"
        }

        Logger.shared.logUserAction(logMessage)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
}
