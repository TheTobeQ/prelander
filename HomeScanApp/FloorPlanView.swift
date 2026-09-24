import SwiftUI
import RoomPlan

struct FloorPlanView: View {
    let room: CapturedRoom

    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                let walls = room.walls
                guard !walls.isEmpty else { return }

                let points = walls.map { wall -> CGPoint in
                    let p = wall.transform.columns.3
                    return CGPoint(x: CGFloat(p.x), y: CGFloat(p.z))
                }

                let minX = points.map(\.x).min() ?? 0
                let maxX = points.map(\.x).max() ?? 1
                let minY = points.map(\.y).min() ?? 0
                let maxY = points.map(\.y).max() ?? 1

                let padding: CGFloat = 35
                let scaleX = (size.width - padding * 2) / max(maxX - minX, 0.1)
                let scaleY = (size.height - padding * 2) / max(maxY - minY, 0.1)
                let scale = min(scaleX, scaleY)

                func map(_ p: CGPoint) -> CGPoint {
                    CGPoint(
                        x: padding + (p.x - minX) * scale,
                        y: padding + (p.y - minY) * scale
                    )
                }

                for wall in walls {
                    let origin = wall.transform.columns.3
                    let half = wall.dimensions.x / 2
                    let angle = atan2(wall.transform.columns.2.z,
                                      wall.transform.columns.2.x)

                    let a = CGPoint(
                        x: CGFloat(origin.x) - CGFloat(cos(angle) * half),
                        y: CGFloat(origin.z) - CGFloat(sin(angle) * half)
                    )
                    let b = CGPoint(
                        x: CGFloat(origin.x) + CGFloat(cos(angle) * half),
                        y: CGFloat(origin.z) + CGFloat(sin(angle) * half)
                    )

                    var path = Path()
                    path.move(to: map(a))
                    path.addLine(to: map(b))
                    context.stroke(path, with: .color(.primary), lineWidth: 5)
                }
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}
