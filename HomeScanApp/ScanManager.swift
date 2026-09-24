import Foundation
import RoomPlan
import Combine
import UIKit

@MainActor
final class ScanManager: NSObject, ObservableObject {
    @Published var isScanning = false
    @Published var rooms: [CapturedRoom] = []
    @Published var structure: CapturedStructure?
    @Published var errorMessage: String?
    @Published var exportedURL: URL?

    private(set) var captureView: RoomCaptureView?
    private var shouldFinishStructure = false

    func makeCaptureView() -> RoomCaptureView {
        if let captureView { return captureView }

        let view = RoomCaptureView(frame: .zero)
        view.captureSession.delegate = self
        view.delegate = self
        captureView = view
        return view
    }

    func newProject() {
        stop()
        rooms.removeAll()
        structure = nil
        exportedURL = nil
        errorMessage = nil
        shouldFinishStructure = false
    }

    func start() {
        let view = makeCaptureView()
        errorMessage = nil
        shouldFinishStructure = false
        view.captureSession.run(configuration: RoomCaptureSession.Configuration())
        isScanning = true
    }

    func stop() {
        captureView?.captureSession.stop()
        isScanning = false
    }

    func stopRoom() {
        guard isScanning else { return }
        shouldFinishStructure = false
        captureView?.captureSession.stop(pauseARSession: false)
        isScanning = false
    }

    func finishStructure() {
        guard !rooms.isEmpty else {
            errorMessage = "Najpierw zeskanuj przynajmniej jedno pomieszczenie."
            return
        }

        if isScanning {
            shouldFinishStructure = true
            captureView?.captureSession.stop(pauseARSession: false)
            isScanning = false
        } else {
            buildStructure()
        }
    }

    private func buildStructure() {
        guard !rooms.isEmpty else { return }

        Task {
            do {
                let builder = StructureBuilder(options: [.beautifyObjects])
                let merged = try await builder.capturedStructure(from: rooms)
                self.structure = merged
                try self.exportStructure(merged)
            } catch {
                self.errorMessage = "Nie udało się połączyć pomieszczeń: \(error.localizedDescription)"
            }
        }
    }

    private func exportStructure(_ structure: CapturedStructure) throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("HomeScan-\(UUID().uuidString).usdz")
        try structure.export(to: url, exportOptions: .mesh)
        exportedURL = url
    }
}

extension ScanManager: RoomCaptureViewDelegate {
    nonisolated func captureView(shouldPresent roomDataForProcessing: CapturedRoomData, error: Error?) -> Bool {
        false
    }

    nonisolated func captureView(didPresent processedResult: CapturedRoom, error: Error?) {
        Task { @MainActor in
            if let error {
                self.errorMessage = error.localizedDescription
                self.isScanning = false
                return
            }

            self.rooms.append(processedResult)
            self.isScanning = false

            if self.shouldFinishStructure {
                self.shouldFinishStructure = false
                self.buildStructure()
            }
        }
    }
}

extension ScanManager: RoomCaptureSessionDelegate {
    nonisolated func captureSession(
        _ session: RoomCaptureSession,
        didUpdate room: CapturedRoom
    ) {}

    nonisolated func captureSession(
        _ session: RoomCaptureSession,
        didStartWith configuration: RoomCaptureSession.Configuration
    ) {}

    nonisolated func captureSession(
        _ session: RoomCaptureSession,
        didEndWith data: CapturedRoomData,
        error: Error?
    ) {
        if let error {
            Task { @MainActor in
                self.errorMessage = error.localizedDescription
                self.isScanning = false
            }
            return
        }

        Task {
            do {
                let builder = RoomBuilder(options: [.beautifyObjects])
                let room = try await builder.capturedRoom(from: data)

                await MainActor.run {
                    self.rooms.append(room)
                    self.isScanning = false

                    if self.shouldFinishStructure {
                        self.shouldFinishStructure = false
                        self.buildStructure()
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Nie udało się przetworzyć skanu: \(error.localizedDescription)"
                    self.isScanning = false
                }
            }
        }
    }
}
