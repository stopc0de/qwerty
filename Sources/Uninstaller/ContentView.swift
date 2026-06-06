import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AppListViewModel()
    @State private var isShowingConfirm = false
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView(selectedCategory: $viewModel.selectedCategory, viewModel: viewModel)
        } content: {
            appContent
                .navigationTitle(viewModel.selectedCategory.rawValue)
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        refreshButton
                    }
                    
                    ToolbarItem(placement: .primaryAction) {
                        searchField
                    }
                }
        } detail: {
            detailContent
                .navigationTitle("")
        }
        .navigationSplitViewStyle(.automatic)
        .task {
            await viewModel.scanApps()
        }
        .overlay {
            // Uninstall confirmation overlay
            if viewModel.showUninstallConfirmation, let app = viewModel.selectedApp {
                uninstallConfirmationOverlay(for: app)
            }
            
            // Uninstall progress overlay
            if viewModel.isUninstalling || viewModel.uninstallComplete {
                uninstallProgressOverlay
            }
        }
        .alert("卸载失败", isPresented: $viewModel.showError) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    // MARK: - Sidebar Content
    
    @ViewBuilder
    private var appContent: some View {
        AppListView(viewModel: viewModel)
    }
    
    // MARK: - Detail Content
    
    @ViewBuilder
    private var detailContent: some View {
        if let app = viewModel.selectedApp {
            AppDetailView(
                app: app,
                associatedFiles: viewModel.associatedFiles,
                isScanningFiles: viewModel.isScanningFiles,
                onUninstall: { viewModel.requestUninstall(for: app) }
            )
        } else {
            WelcomeView()
        }
    }
    
    // MARK: - Toolbar
    
    private var refreshButton: some View {
        Button(action: {
            Task { await viewModel.refresh() }
        }) {
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 12, weight: .semibold))
        }
        .help("刷新应用列表")
        .disabled(viewModel.isScanning)
    }
    
    private var searchField: some View {
        HStack(spacing: 4) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
            
            TextField("搜索应用...", text: $viewModel.searchText)
                .textFieldStyle(.plain)
                .font(.system(size: 12))
                .frame(width: 150)
                .onChange(of: viewModel.searchText) { _ in
                    viewModel.filterApps()
                }
            
            if !viewModel.searchText.isEmpty {
                Button(action: {
                    viewModel.searchText = ""
                    viewModel.filterApps()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(.quaternary.opacity(0.3))
        )
    }
    
    // MARK: - Overlays
    
    private func uninstallConfirmationOverlay(for app: MacApp) -> some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .transition(.opacity)
            
            UninstallConfirmationView(
                app: app,
                associatedFiles: viewModel.associatedFiles,
                onConfirm: {
                    Task { await viewModel.confirmUninstall() }
                },
                onCancel: {
                    viewModel.showUninstallConfirmation = false
                }
            )
            .transition(.scale(scale: 0.95).combined(with: .opacity))
        }
    }
    
    private var uninstallProgressOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .transition(.opacity)
            
            UninstallProgressView(
                progress: viewModel.uninstallProgress,
                statusText: viewModel.uninstallStatusText,
                appName: viewModel.uninstalledAppName,
                isComplete: viewModel.uninstallComplete,
                onDismiss: { viewModel.resetUninstallState() }
            )
            .transition(.scale(scale: 0.95).combined(with: .opacity))
        }
    }
}
