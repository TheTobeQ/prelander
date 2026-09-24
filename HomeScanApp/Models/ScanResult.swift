import Foundation
import RoomPlan

struct ScanResult: Identifiable {
    let id = UUID()
    let room: CapturedRoom

    var wallCount: Int { room.walls.count }
    var doorCount: Int { room.doors.count }
    var windowCount: Int { room.windows.count }
    var openingCount: Int { room.openings.count }

    var floorArea: Double {
        let walls = room.walls
        guard walls.count >= 4 else { return 0 }

        let points = walls.map { wall -> (Double, Double) in
            let t = wall.transform.columns.3
            return (Double(t.x), Double(t.z))
        }

        var area = 0.0
        for i in points.indices {
            let j = (i + 1) % points.count
            area += points[i].0 * points[j].1 - points[j].0 * points[i].1
        }
        return abs(area) / 2
    }

    var approximateDimensions: (width: Double, length: Double) {
        let points = room.walls.map {
            let t = $0.transform.columns.3
            return (Double(t.x), Double(t.z))
        }
        guard !points.isEmpty else { return (0, 0) }

        let xs = points.map(.0)
        let zs = points.map(.1)
        return ((xs.max() ?? 0) - (xs.min() ?? 0),
                (zs.max() ?? 0) - (zs.min() ?? 0))
    }
}
