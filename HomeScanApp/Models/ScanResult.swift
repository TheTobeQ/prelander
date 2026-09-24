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
        let points = room.walls.flatMap { wall -> [(Double, Double)] in
            let origin = wall.transform.columns.3
            let half = wall.dimensions.x / 2
            let angle = atan2(wall.transform.columns.2.z, wall.transform.columns.2.x)
            let a = (Double(origin.x) - cos(Double(angle)) * Double(half),
                     Double(origin.z) - sin(Double(angle)) * Double(half))
            let b = (Double(origin.x) + cos(Double(angle)) * Double(half),
                     Double(origin.z) + sin(Double(angle)) * Double(half))
            return [a, b]
        }

        guard points.count >= 3 else { return 0 }

        let centerX = points.map { $0.0 }.reduce(0, +) / Double(points.count)
        let centerZ = points.map { $0.1 }.reduce(0, +) / Double(points.count)
        let ordered = points.sorted {
            atan2($0.1 - centerZ, $0.0 - centerX) < atan2($1.1 - centerZ, $1.0 - centerX)
        }

        var area = 0.0
        for i in ordered.indices {
            let j = (i + 1) % ordered.count
            area += ordered[i].0 * ordered[j].1 - ordered[j].0 * ordered[i].1
        }
        return abs(area) / 2
    }

    var approximateDimensions: (width: Double, length: Double) {
        let points = room.walls.flatMap { wall -> [(Double, Double)] in
            let origin = wall.transform.columns.3
            return [(Double(origin.x), Double(origin.z))]
        }
        guard !points.isEmpty else { return (0, 0) }

        let xs = points.map { $0.0 }
        let zs = points.map { $0.1 }
        return ((xs.max() ?? 0) - (xs.min() ?? 0),
                (zs.max() ?? 0) - (zs.min() ?? 0))
    }
}
