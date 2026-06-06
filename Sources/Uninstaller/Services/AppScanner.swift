import Foundation
import AppKit

final class AppScanner: @unchecked Sendable {
    
    enum ScanError: Error {
        case noApplicationsFound
    }
    
    func scanAllApps() -> [MacApp] {
        let userApps = scanDirectory(URL(fileURLWithPath: "/Applications"))
        let utilitiesApps = scanDirectory(URL(fileURLWithPath: "/System/Applications"))
        let userDirectoryApps = scanUserDirectory()
        let systemApps = scanSystemApps()
        
        return userApps + utilitiesApps + userDirectoryApps + systemApps
    }
    
    private func scanDirectory(_ url: URL) -> [MacApp] {
        var apps: [MacApp] = []
        
        guard let enumerator = FileManager.default.enumerator(
            at: url,
            includingPropertiesForKeys: [.isApplicationKey, .localizedNameKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else { return apps }
        
        for case let fileURL as URL in enumerator {
            guard fileURL.pathExtension == "app" else { continue }
            if let app = createApp(from: fileURL, isSystem: url.path.contains("/System")) {
                apps.append(app)
            }
        }
        
        return apps
    }
    
    private func scanUserDirectory() -> [MacApp] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let appDir = home.appendingPathComponent("Applications")
        var apps: [MacApp] = []
        
        guard let enumerator = FileManager.default.enumerator(
            at: appDir,
            includingPropertiesForKeys: [.isApplicationKey, .localizedNameKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else { return apps }
        
        for case let fileURL as URL in enumerator {
            guard fileURL.pathExtension == "app" else { continue }
            if let app = createApp(from: fileURL, isSystem: false) {
                apps.append(app)
            }
        }
        
        return apps
    }
    
    private func scanSystemApps() -> [MacApp] {
        let systemDirs = [
            "/System/Library/CoreServices",
            "/System/Library/CoreServices/Applications"
        ]
        
        var apps: [MacApp] = []
        for dir in systemDirs {
            let appsFromDir = scanDirectory(URL(fileURLWithPath: dir))
            apps.append(contentsOf: appsFromDir)
        }
        return apps
    }
    
    private func createApp(from url: URL, isSystem: Bool) -> MacApp? {
        let bundle = Bundle(url: url)
        let bundleID = bundle?.bundleIdentifier ?? "unknown"
        let version = bundle?.infoDictionary?["CFBundleShortVersionString"] as? String
        let name = bundle?.infoDictionary?["CFBundleDisplayName"] as? String
            ?? bundle?.infoDictionary?["CFBundleName"] as? String
            ?? url.deletingPathExtension().lastPathComponent
        
        let icon = NSWorkspace.shared.icon(forFile: url.path)
        
        var size: Int64? = nil
        if let enumerator = FileManager.default.enumerator(
            at: url,
            includingPropertiesForKeys: [.fileSizeKey],
            options: [.skipsSubdirectoryDescendants]
        ) {
            var total: Int64 = 0
            for case let fileURL as URL in enumerator {
                if let attrs = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
                   let fileSize = attrs.fileSize {
                    total += Int64(fileSize)
                }
            }
            size = total
        }
        
        let path = url.path
        let category: AppCategory
        if path.contains("/System/Applications/Utilities/") || path.contains("/System/Library/CoreServices") {
            category = .utilities
        } else if path.contains("/System/") {
            category = .system
        } else if path.contains("/Users/") && path.contains("/Applications") {
            category = .user
        } else if path.contains("/Applications/Utilities/") {
            category = .utilities
        } else {
            category = .applications
        }
        
        return MacApp(
            name: name,
            path: url.path,
            bundleIdentifier: bundleID,
            version: version,
            icon: icon,
            sizeBytes: size,
            isSystemApp: isSystem || category == .system,
            category: category
        )
    }
}
