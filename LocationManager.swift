import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    @Published var location: CLLocation? = nil
    private var timer: AnyCancellable? // Temporizador para enviar localização a cada 20 segundos

    override init() {
        super.init()
        locationManager.delegate = self
        
        // Solicita autorização de localização
        checkAuthorization()
    }
    
    private func checkAuthorization() {
        let status = CLLocationManager.authorizationStatus() // Corrigido para uso da propriedade estática
        switch status {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization() // ou requestWhenInUseAuthorization() se preferir
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            iniciarEnvioPeriodico() // Inicia o envio periódico se autorizado
        case .denied, .restricted:
            print("Acesso à localização negado ou restrito.")
        @unknown default:
            print("Status de autorização desconhecido.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        self.location = newLocation
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Erro ao tentar obter a localização: \(error.localizedDescription)")
    }
    
    // Função para iniciar o envio periódico da localização
    func iniciarEnvioPeriodico() {
        timer = Timer.publish(every: 20, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.enviarLocalizacaoParaAPI()
            }
    }
    
    // Função para parar o envio periódico
    func pararEnvioPeriodico() {
        timer?.cancel()
        timer = nil
    }
    
    // Função para enviar a localização para a API da AWS
    private func enviarLocalizacaoParaAPI() {
        guard let location = self.location else {
            print("Nenhuma localização disponível para enviar.")
            return
        }

        let urlString = "LINK SITE PRIVADO AWS"
        guard let url = URL(string: urlString) else {
            print("URL inválida")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let logData = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "timestamp": Date().timeIntervalSince1970
        ] as [String : Any]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: logData, options: [])
            request.httpBody = jsonData

            let task = URLSession.shared.dacataTask(with: request) { data, response, error in
                if let error = error {
                    print("Erro ao enviar localização: \(error)")
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

        // Adiciona mensagem no terminal informando que a localização está sendo coletada
        print("Localização coletada e enviada: Latitude \(location.coordinate.latitude), Longitude \(location.coordinate.longitude)")
    }
}
