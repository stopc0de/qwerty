import Foundation
import AppKit

final class UninstallService: @unchecked Sendable {
    
    enum UninstallError: LocalizedError {
        case appNotFound
        case trashFailed(String)
        case fileRemovalFailed(String)
        case operationCancelled
        
        var errorDescription: String? {
            switch self {
            case .appNotFound: return "未找到应用"
            case .trashFailed(let msg): return "移入废纸篓失败: \(msg)"
            case .fileRemovalFailed(let msg): return "文件删除失败: \(msg)"
            case .operationCancelled: return "操作已取消"
            }
        }
    }
    
    func findAssociatedFiles(for app: MacApp) -> [AssociatedFile] {
        let bundleID = app.bundleIdentifier
        var files: [AssociatedFile] = []
        let home = FileManager.default.homeDirectoryForCurrentUser
        
        let searchPaths: [URL] = [
            home.appendingPathComponent("Library/Preferences"),
            home.appendingPathComponent("Library/Caches"),
            home.appendingPathComponent("Library/Application Support"),
            home.appendingPathComponent("Library/Saved Application State"),
            home.appendingPathComponent("Library/Logs"),
            home.appendingPathComponent("Library/Containers"),
            home.appendingPathComponent("Library/HTTPStorages"),
            home.appendingPathComponent("Library/WebKit/Databases"),
            home.appendingPathComponent("Library/Group Containers"),
        ]
        
        let patterns = [bundleID, bundleID.replacingOccurrences(of: ".", with: "_"), app.name]
        
        for baseURL in searchPaths {
            guard FileManager.default.fileExists(atPath: baseURL.path) else { continue }
            guard let enumerator = FileManager.default.enumerator(
                at: baseURL,
                includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey],
                options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
            ) else { continue }
            
            for case let fileURL as URL in enumerator {
                let fileName = fileURL.lastPathComponent.lowercased()
                let shouldInclude = patterns.contains { pattern in
                    fileName.contains(pattern.lowercased())
                }
                
                if shouldInclude {
                    var size: Int64? = nil
                    if let attrs = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
                       let fileSize = attrs.fileSize {
                        size = Int64(fileSize)
                    } else if let dict = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
                              let fileSize = dict[.size] as? UInt64 {
                        size = Int64(fileSize)
                    }
                    files.append(AssociatedFile(url: fileURL, sizeBytes: size))
                }
            }
        }
        
        let librarySearchPaths = [
            URL(fileURLWithPath: "/Library/Preferences"),
            URL(fileURLWithPath: "/Library/Caches"),
            URL(fileURLWithPath: "/Library/Application Support"),
            URL(fileURLWithPath: "/Library/Logs"),
        ]
        
        for baseURL in librarySearchPaths {
            guard FileManager.default.fileExists(atPath: baseURL.path) else { continue }
            guard let enumerator = FileManager.default.enumerator(
                at: baseURL,
                includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey],
                options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
            ) else { continue }
            
            for case let fileURL as URL in enumerator {
                let fileName = fileURL.lastPathComponent.lowercased()
                let shouldInclude = patterns.contains { pattern in
                    fileName.contains(pattern.lowercased())
                }
                
                if shouldInclude {
                    var size: Int64? = nil
                    if let dict = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
                       let fileSize = dict[.size] as? UInt64 {
                        size = Int64(fileSize)
                    }
                    files.append(AssociatedFile(url: fileURL, sizeBytes: size))
                }
            }
        }
        
        return files
    }
    
    func totalSize(of files: [AssociatedFile]) -> Int64 {
        files.reduce(0) { $0 + ($1.sizeBytes ?? 0) }
    }
    
    func uninstall(app: MacApp, removeAssociatedFiles: Bool = true, progressHandler: ((Double, String) -> Void)? = nil) throws {
        progressHandler?(0.1, "正在将应用移入废纸篓...")
        try moveAppToTrash(app)
        
        guard removeAssociatedFiles else {
            progressHandler?(1.0, "卸载完成！")
            return
        }
        
        progressHandler?(0.3, "正在扫描关联文件...")
        let associatedFiles = findAssociatedFiles(for: app)
        
        guard !associatedFiles.isEmpty else {
            progressHandler?(1.0, "清理完成")
            return
        }
        
        let total = Double(associatedFiles.count)
        var lastError: Error? = nil
        
        for (index, file) in associatedFiles.enumerated() {
            let progress = 0.3 + (Double(index + 1) / total) * 0.65
            progressHandler?(progress, "正在清理: \(file.name)")
            
            do {
                try FileManager.default.trashItem(at: file.url, resultingItemURL: nil)
            } catch {
                do {
                    try FileManager.default.removeItem(at: file.url)
                } catch {
                    lastError = error
                }
            }
        }
        
        progressHandler?(0.95, "正在最终清理...")
        progressHandler?(1.0, "卸载完成！")
        
        if let lastError = lastError {
            throw UninstallError.fileRemovalFailed(lastError.localizedDescription)
        }
    }
    
    private func moveAppToTrash(_ app: MacApp) throws {
        let appURL = URL(fileURLWithPath: app.path)
        guard FileManager.default.fileExists(atPath: app.path) else {
            throw UninstallError.appNotFound
        }
        
        do {
            try FileManager.default.trashItem(at: appURL, resultingItemURL: nil)
        } catch {
            throw UninstallError.trashFailed(error.localizedDescription)
        }
    }
}
