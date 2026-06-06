import Foundation
import AppKit
import SwiftUI

@MainActor
class AppListViewModel: ObservableObject {
    
    @Published var allApps: [MacApp] = []
    @Published var filteredApps: [MacApp] = []
    @Published var selectedCategory: AppCategory = .all
    @Published var searchText = ""
    @Published var isScanning = false
    @Published var selectedApp: MacApp?
    @Published var showUninstallConfirmation = false
    
    // Uninstall state
    @Published var isUninstalling = false
    @Published var uninstallProgress: Double = 0
    @Published var uninstallStatusText = ""
    @Published var uninstallComplete = false
    @Published var uninstalledAppName = ""
    @Published var showError = false
    @Published var errorMessage = ""
    
    // Associated files
    @Published var associatedFiles: [AssociatedFile] = []
    @Published var isScanningFiles = false
    
    private let scanner = AppScanner()
    private let uninstallService = UninstallService()
    
    var totalAppsCount: Int { allApps.count }
    var selectedCategoryCount: Int { filteredApps.count }
    
    func scanApps() async {
        isScanning = true
        defer { isScanning = false }
        
        let apps = await Task.detached {
            self.scanner.scanAllApps().sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        }.value
        
        allApps = apps
        filterApps()
    }
    
    func filterApps() {
        var apps = allApps
        
        // Filter by category
        if selectedCategory != .all {
            apps = apps.filter { $0.category == selectedCategory }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            apps = apps.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        filteredApps = apps
    }
    
    func selectApp(_ app: MacApp) {
        selectedApp = app
        associatedFiles = []
        isScanningFiles = true
        
        let service = uninstallService
        Task.detached {
            let files = service.findAssociatedFiles(for: app)
            await MainActor.run {
                self.associatedFiles = files
                self.isScanningFiles = false
            }
        }
    }
    
    func requestUninstall(for app: MacApp) {
        selectedApp = app
        showUninstallConfirmation = true
    }
    
    func confirmUninstall() async {
        guard let app = selectedApp else { return }
        
        isUninstalling = true
        uninstallProgress = 0
        uninstallStatusText = "准备卸载..."
        showUninstallConfirmation = false
        uninstalledAppName = app.name
        
        do {
            try await Task.detached {
                try self.uninstallService.uninstall(
                    app: app,
                    removeAssociatedFiles: true,
                    progressHandler: { progress, status in
                        Task { @MainActor in
                            self.uninstallProgress = progress
                            self.uninstallStatusText = status
                        }
                    }
                )
            }.value
            
            await MainActor.run {
                self.allApps.removeAll { $0.id == app.id }
                self.filterApps()
                self.uninstallComplete = true
                self.selectedApp = nil
                self.isUninstalling = false
            }
        } catch {
            await MainActor.run {
                self.isUninstalling = false
                self.uninstallComplete = false
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
    }
    
    func resetUninstallState() {
        isUninstalling = false
        uninstallProgress = 0
        uninstallStatusText = ""
        uninstallComplete = false
        uninstalledAppName = ""
    }
    
    func refresh() async {
        await scanApps()
    }
}
