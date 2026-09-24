import Foundation
import RoomPlan
import Combine

@MainActor
final class ScanManager: NSObject, ObservableObject {
    @Published var isScanning = false
    @Published var result: ScanResult?
    @Published var errorMessage: String?
    @Published var exportedURL: URL?

    private(set) var captureView: RoomCaptureView?

    func makeCaptureView() -> RoomCaptureView {
        let view = RoomCaptureView(frame: .zero)
        view.captureSession.delegate = self
        view.delegate = self
        captureView = view
        return view
    }

    func start() {
        guard let captureView else { return }
        errorMessage = nil
        result = nil
        exportedURL = nil

        let configuration = RoomCaptureSession.Configuration()
        captureView.captureSession.run(configuration: configuration)
        isScanning = true
    }

    func stop() {
        captureView?.captureSession.stop()
        isScanning = false
    }

    func exportUSDZ() {
        guard let room = result?.room else { return }

        do {
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("HomeScan-(UUID().uuidString).usdz")
            try room.export(to: url, exportOptions: [.parametric])
            exportedURL = url
        } catch {
            errorMessage = "Nie udało się wyeksportować modelu 3D: (error.localizedDescription)"
        }
    }
}

extension ScanManager: RoomCaptureViewDelegate {
    nonisolated func captureView(shouldPresent roomDataForProcessing: CapturedRoomData, error: Error?) -> Bool {
        true
    }

    nonisolated func captureView(didPresent processedResult: CapturedRoom, error: Error?) {
        Task { @MainActor in
            if let error {
                self.errorMessage = error.localizedDescription
                self.isScanning = false
                return
            }

            self.result = ScanResult(room: processedResult)
            self.isScanning = false
        }
    }
}

extension ScanManager: RoomCaptureSessionDelegate {
    nonisolated func captureSession(
        _ session: RoomCaptureSession,
        didUpdate room: CapturedRoom
    ) {
        // RoomPlan continuously updates the room model while scanning.
    }

    nonisolated func captureSession(
        _ session: RoomCaptureSession,
        didStartWith configuration: RoomCaptureSession.Configuration
    ) {}

    nonisolated func captureSession(
        _ session: RoomCaptureSession,
        didEndWith data: CapturedRoomData,
        error: Error?
    ) {}
}
