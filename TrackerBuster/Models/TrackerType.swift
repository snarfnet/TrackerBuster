import Foundation

enum TrackerType: String, CaseIterable, Identifiable {
    case airtag = "AirTag"
    case tile = "Tile"
    case smartTag = "SmartTag"
    case chipolo = "Chipolo"
    case unknown = "不明"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .airtag: return "airtag"
        case .tile: return "square.fill"
        case .smartTag: return "tag.fill"
        case .chipolo: return "circle.fill"
        case .unknown: return "questionmark.circle.fill"
        }
    }

    var description: String {
        switch self {
        case .airtag: return "Apple AirTag"
        case .tile: return "Tile Tracker"
        case .smartTag: return "Samsung SmartTag"
        case .chipolo: return "Chipolo"
        case .unknown: return "不明なBLEトラッカー"
        }
    }

    // Apple company ID: 0x004C
    static let appleCompanyID: UInt16 = 0x004C
    // Tile company ID: 0x01DA
    static let tileCompanyID: UInt16 = 0x01DA
    // Samsung company ID: 0x0075
    static let samsungCompanyID: UInt16 = 0x0075
    // Chipolo company ID: 0x0310
    static let chipoloCompanyID: UInt16 = 0x0310

    // AirTag detected Find My network advertisement
    // Service UUID for Find My network
    static let findMyServiceUUID = "7DFC9000-7D1C-4951-86AA-8D9728F8D66C"

    static func identify(manufacturerData: Data?, serviceUUIDs: [String]?) -> TrackerType {
        if let serviceUUIDs = serviceUUIDs {
            for uuid in serviceUUIDs {
                if uuid.uppercased().contains("7DFC") {
                    return .airtag
                }
                if uuid.uppercased().contains("FEED") || uuid.uppercased().contains("FE EC") {
                    return .tile
                }
            }
        }

        guard let data = manufacturerData, data.count >= 2 else { return .unknown }

        let companyID = UInt16(data[0]) | (UInt16(data[1]) << 8)

        switch companyID {
        case appleCompanyID:
            // Check for AirTag-specific payload (Find My accessory type 0x12)
            if data.count >= 3 && data[2] == 0x12 {
                return .airtag
            }
            // Other Apple Find My accessories
            if data.count >= 3 && (data[2] == 0x07 || data[2] == 0x05) {
                return .airtag
            }
            return .unknown
        case tileCompanyID:
            return .tile
        case samsungCompanyID:
            return .smartTag
        case chipoloCompanyID:
            return .chipolo
        default:
            return .unknown
        }
    }
}
