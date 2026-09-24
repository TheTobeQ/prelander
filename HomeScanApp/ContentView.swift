import SwiftUI
import RoomPlan

struct ContentView: View {
    @StateObject private var manager = ScanManager()
    @State private var showScanner = false
    @State private var show3D = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.black, Color(red: 0.06, green: 0.09, blue: 0.14)],
                               startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        header

                        if manager.rooms.isEmpty {
                            startCard
                        } else {
                            projectCard
                        }

                        if let structure = manager.structure {
                            structureCard(structure)
                        }
                    }
                    .padding()
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showScanner) {
                ScannerScreen(manager: manager)
            }
            .sheet(isPresented: $show3D) {
                if let url = manager.exportedURL {
                    USDZPreview(url: url)
                }
            }
            .alert("Błąd", isPresented: Binding(
                get: { manager.errorMessage != nil },
                set: { if !$0 { manager.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(manager.errorMessage ?? "")
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("HomeScan")
                .font(.system(size: 42, weight: .bold, design: .rounded))
            Text("Skaner mieszkań 3D z LiDAR")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .foregroundStyle(.white)
    }

    private var startCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: "cube.transparent")
                .font(.system(size: 54))
                .foregroundStyle(.cyan)

            Text("Zeskanuj całe mieszkanie")
                .font(.title2.bold())

            Text("Skanuj pomieszczenie po pomieszczeniu. HomeScan połączy je w jeden model 3D.")
                .foregroundStyle(.secondary)

            Button {
                manager.newProject()
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

    private var projectCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Projekt mieszkania", systemImage: "house.fill")
                    .font(.title3.bold())
                Spacer()
                Text("\(manager.rooms.count) pok.")
                    .font(.subheadline.bold())
                    .foregroundStyle(.cyan)
            }

            Text("Zeskanowane pomieszczenia są zachowane w jednym projekcie.")
                .foregroundStyle(.secondary)

            Button {
                showScanner = true
            } label: {
                Label("Dodaj kolejne pomieszczenie", systemImage: "plus")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.cyan)
                    .foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            Button {
                manager.finishStructure()
            } label: {
                Label("Zbuduj model całego mieszkania", systemImage: "cube.fill")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.white)
                    .foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            Button("Nowy projekt") {
                manager.newProject()
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(.red)
            .padding(.top, 4)
        }
        .padding(22)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private func structureCard(_ structure: CapturedStructure) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Model 3D gotowy", systemImage: "checkmark.seal.fill")
                .font(.title2.bold())
                .foregroundStyle(.green)

            HStack(spacing: 10) {
                Metric(title: "Pomieszczenia", value: "\(structure.rooms.count)")
                Metric(title: "Ściany", value: "\(structure.walls.count)")
                Metric(title: "Drzwi", value: "\(structure.doors.count)")
            }

            if let url = manager.exportedURL {
                Button {
                    show3D = true
                } label: {
                    Label("Otwórz model 3D", systemImage: "view.3d")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.cyan)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                ShareLink(item: url) {
                    Label("Udostępnij USDZ", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 4)
            }
        }
        .padding(22)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
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
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct ScannerScreen: View {
    @ObservedObject var manager: ScanManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .bottom) {
            RoomCaptureViewRepresentable(manager: manager)
                .ignoresSafeArea()

            VStack(spacing: 10) {
                HStack {
                    Label("Pomieszczenie \(manager.rooms.count + 1)", systemImage: "viewfinder")
                        .font(.headline)
                    Spacer()
                    Text(manager.isScanning ? "SKANOWANIE" : "GOTOWE")
                        .font(.caption.bold())
                        .foregroundStyle(manager.isScanning ? .cyan : .green)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())

                if manager.isScanning {
                    Button {
                        manager.stopRoom()
                    } label: {
                        Text("Zapisz pomieszczenie")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.white)
                            .foregroundStyle(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                } else {
                    Button {
                        manager.start()
                    } label: {
                        Label("Skanuj / kontynuuj", systemImage: "camera.viewfinder")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.cyan)
                            .foregroundStyle(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }

                    Button {
                        manager.finishStructure()
                    } label: {
                        Label("Zakończ mieszkanie", systemImage: "checkmark.circle.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.white)
                            .foregroundStyle(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                }

                Button("Zamknij") {
                    manager.stop()
                    dismiss()
                }
                .foregroundStyle(.white)
                .padding(.bottom, 4)
            }
            .padding()
        }
        .onAppear {
            if !manager.isScanning && manager.rooms.isEmpty {
                manager.start()
            }
        }
    }
}
