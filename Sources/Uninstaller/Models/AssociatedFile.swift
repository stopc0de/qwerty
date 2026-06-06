import Foundation

struct AssociatedFile: Identifiable {
    let id = UUID()
    let url: URL
    let sizeBytes: Int64?
    
    var path: String { url.path }
    var name: String { url.lastPathComponent }
    
    var sizeFormatted: String {
        guard let size = sizeBytes else { return "未知大小" }
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
    
    var category: FileCategory {
        let path = url.path.lowercased()
        if path.contains("/Preferences/") || path.hasSuffix(".plist") {
            return .preferences
        } else if path.contains("/Caches/") {
            return .cache
        } else if path.contains("/Application Support/") {
            return .support
        } else if path.contains("/Saved Application State/") {
            return .savedState
        } else if path.contains("/Logs/") {
            return .logs
        } else if path.contains("/Containers/") {
            return .container
        } else {
            return .other
        }
    }
}

enum FileCategory: String, CaseIterable, Identifiable {
    case preferences = "偏好设置"
    case cache = "缓存"
    case support = "应用支持"
    case savedState = "保存状态"
    case logs = "日志"
    case container = "容器"
    case other = "其他"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .preferences: return "gearshape"
        case .cache: return "clock.arrow.circlepath"
        case .support: return "folder"
        case .savedState: return "memorychip"
        case .logs: return "doc.text"
        case .container: return "shippingbox"
        case .other: return "questionmark.folder"
        }
    }
}
