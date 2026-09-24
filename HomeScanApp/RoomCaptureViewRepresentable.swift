import SwiftUI
import RoomPlan

struct RoomCaptureViewRepresentable: UIViewRepresentable {
    @ObservedObject var manager: ScanManager

    func makeUIView(context: Context) -> RoomCaptureView {
        manager.makeCaptureView()
    }

    func updateUIView(_ uiView: RoomCaptureView, context: Context) {}
}
