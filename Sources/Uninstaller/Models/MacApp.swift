import Foundation
import AppKit

struct MacApp: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let path: String
    let bundleIdentifier: String
    let version: String?
    let icon: NSImage?
    let sizeBytes: Int64?
    let isSystemApp: Bool
    let category: AppCategory
    
    var sizeFormatted: String {
        guard let size = sizeBytes else { return "未知" }
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
    
    var bundleName: String {
        (path as NSString).lastPathComponent
    }
    
    static func == (lhs: MacApp, rhs: MacApp) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum AppCategory: String, CaseIterable, Identifiable {
    case all = "全部"
    case applications = "应用"
    case utilities = "工具"
    case user = "用户"
    case system = "系统"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .applications: return "app.fill"
        case .utilities: return "wrench.and.screwdriver"
        case .user: return "person.fill"
        case .system: return "gear"
        }
    }
}
