import Foundation
import CoreLocation

struct TrackerDevice: Identifiable, Hashable {
    let id: UUID
    let peripheralIdentifier: UUID
    var name: String?
    var type: TrackerType
    var rssi: Int
    var firstSeen: Date
    var lastSeen: Date
    var seenCount: Int
    var locations: [CLLocationCoordinate2D]
    var isSuspicious: Bool

    var durationNearby: TimeInterval {
        lastSeen.timeIntervalSince(firstSeen)
    }

    var durationText: String {
        let minutes = Int(durationNearby / 60)
        if minutes < 1 { return "1分未満" }
        if minutes < 60 { return "\(minutes)分" }
        let hours = minutes / 60
        let remainMinutes = minutes % 60
        return "\(hours)時間\(remainMinutes)分"
    }

    var threatLevel: ThreatLevel {
        let minutes = durationNearby / 60
        if minutes >= 30 && seenCount >= 10 { return .high }
        if minutes >= 10 && seenCount >= 5 { return .medium }
        return .low
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(peripheralIdentifier)
    }

    static func == (lhs: TrackerDevice, rhs: TrackerDevice) -> Bool {
        lhs.peripheralIdentifier == rhs.peripheralIdentifier
    }
}

enum ThreatLevel: String, CaseIterable {
    case low = "低"
    case medium = "中"
    case high = "高"

    var color: String {
        switch self {
        case .low: return "threatLow"
        case .medium: return "threatMedium"
        case .high: return "threatHigh"
        }
    }
}
