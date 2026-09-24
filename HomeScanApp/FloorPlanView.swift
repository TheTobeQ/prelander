import SwiftUI
import RoomPlan

struct FloorPlanView: View {
    let room: CapturedRoom

    var body: some View {
        Canvas { context, size in
            let walls = room.walls
            guard !walls.isEmpty else { return }

            let segments: [(CGPoint, CGPoint)] = walls.map { wall in
                let origin = wall.transform.columns.3
                let half = wall.dimensions.x / 2
                let angle = atan2(wall.transform.columns.2.z, wall.transform.columns.2.x)

                let a = CGPoint(
                    x: CGFloat(origin.x) - CGFloat(cos(angle) * half),
                    y: CGFloat(origin.z) - CGFloat(sin(angle) * half)
                )
                let b = CGPoint(
                    x: CGFloat(origin.x) + CGFloat(cos(angle) * half),
                    y: CGFloat(origin.z) + CGFloat(sin(angle) * half)
                )
                return (a, b)
            }

            let allPoints = segments.flatMap { [$0.0, $0.1] }
            let minX = allPoints.map { $0.x }.min() ?? 0
            let maxX = allPoints.map { $0.x }.max() ?? 1
            let minY = allPoints.map { $0.y }.min() ?? 0
            let maxY = allPoints.map { $0.y }.max() ?? 1

            let padding: CGFloat = 32
            let scale = min(
                (size.width - padding * 2) / max(maxX - minX, 0.1),
                (size.height - padding * 2) / max(maxY - minY, 0.1)
            )

            func map(_ p: CGPoint) -> CGPoint {
                CGPoint(
                    x: padding + (p.x - minX) * scale,
                    y: padding + (p.y - minY) * scale
                )
            }

            for (a, b) in segments {
                var path = Path()
                path.move(to: map(a))
                path.addLine(to: map(b))
                context.stroke(path, with: .color(.primary), lineWidth: 6)
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}
