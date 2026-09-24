import SwiftUI
import RoomPlan

struct ContentView: View {
    @StateObject private var manager = ScanManager()
    @State private var showScanner = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.black, Color(red: 0.08, green: 0.10, blue: 0.14)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        header

                        if let result = manager.result {
                            resultView(result)
                        } else {
                            startCard
                        }
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showScanner) {
                ScannerScreen(manager: manager)
            }
            .alert(
                "Błąd",
                isPresented: Binding(
                    get: { manager.errorMessage != nil },
                    set: { if !$0 { manager.errorMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(manager.errorMessage ?? "")
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("HomeScan")
                .font(.system(size: 42, weight: .bold, design: .rounded))
            Text("Zamień swoje mieszkanie w cyfrowy model 3D.")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .foregroundStyle(.white)
    }

    private var startCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            Image(systemName: "cube.transparent")
                .font(.system(size: 54))
                .foregroundStyle(.cyan)

            Text("Skanowanie LiDAR")
                .font(.title2.bold())

            Text("Obchodź pomieszczenie z iPhonem. HomeScan wykryje ściany, drzwi, okna i przygotuje model pomieszczenia.")
                .foregroundStyle(.secondary)

            Button {
                showScanner = true
            } label: {
                Label("Rozpocznij skan", systemImage: "camera.viewfinder")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.cyan)
                    .foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(24)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 28))
    }

    private func resultView(_ result: ScanResult) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Gotowe")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)

            FloorPlanView(room: result.room)
                .frame(height: 360)

            let dimensions = result.approximateDimensions

            HStack(spacing: 12) {
                Metric(title: "Szerokość", value: meters(dimensions.width))
                Metric(title: "Długość", value: meters(dimensions.length))
            }

            HStack(spacing: 12) {
                Metric(title: "Ściany", value: "(result.wallCount)")
                Metric(title: "Drzwi", value: "(result.doorCount)")
                Metric(title: "Okna", value: "(result.windowCount)")
            }

            Button {
                manager.exportUSDZ()
            } label: {
                Label("Eksportuj model 3D", systemImage: "cube")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.white)
                    .foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            if let url = manager.exportedURL {
                ShareLink(item: url) {
                    Label("Udostępnij plik USDZ", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .padding()
            }

            Button("Zeskanuj ponownie") {
                manager.result = nil
                showScanner = true
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(.cyan)
        }
    }

    private func meters(_ value: Double) -> String {
        String(format: "%.2f m", value)
    }
}

struct Metric: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct ScannerScreen: View {
    @ObservedObject var manager: ScanManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .bottom) {
            RoomCaptureViewRepresentable(manager: manager)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Text("Skanuj powoli całe pomieszczenie")
                    .font(.headline)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())

                Button {
                    manager.stop()
                    dismiss()
                } label: {
                    Text("Zakończ skan")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.white)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
            }
            .padding()
        }
        .onAppear {
            manager.start()
        }
    }
}
