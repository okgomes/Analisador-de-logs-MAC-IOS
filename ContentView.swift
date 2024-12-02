import SwiftUI
import CoreLocation

struct ContentView: View {
    @ObservedObject var monitoramento = MonitoramentoArquivos()
    @ObservedObject var locationManager = LocationManager()

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            
            Text("Os logs estão sendo coletados e enviados para o OpenSearch!")
                .padding()

            // Exibe os logs do monitoramento de arquivos
            List(monitoramento.logs, id: \.self) { log in
                Text(log)
            }
            .padding()

            // Exibe as coordenadas da localização, se disponíveis
            if let location = locationManager.location {
                Text("Latitude: \(location.coordinate.latitude)")
                Text("Longitude: \(location.coordinate.longitude)")
            } else {
                Text("Obtendo localização...")
            }
        }
        .onAppear {
            monitoramento.iniciar() // Iniciar monitoramento de arquivos
            locationManager.iniciarEnvioPeriodico() // Iniciar envio periódico da localização
        }
        .onDisappear {
            monitoramento.parar() // Parar monitoramento de arquivos
            locationManager.pararEnvioPeriodico() // Parar envio periódico da localização
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
