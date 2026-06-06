import SwiftUI

struct AppListView: View {
    @ObservedObject var viewModel: AppListViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isScanning {
                scanningView
            } else if viewModel.filteredApps.isEmpty {
                emptyView
            } else {
                appList
            }
        }
        .background(Color(.controlBackgroundColor))
    }
    
    private var scanningView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(0.8)
                .controlSize(.large)
            
            Text("正在扫描应用...")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
            
            ProgressView()
                .progressViewStyle(.linear)
                .frame(width: 200)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: viewModel.searchText.isEmpty ? "tray" : "magnifyingglass")
                .font(.system(size: 36))
                .foregroundStyle(.tertiary)
            
            Text(viewModel.searchText.isEmpty ? "没有找到应用" : "没有找到匹配的应用")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
            
            if !viewModel.searchText.isEmpty {
                Button("清除搜索") {
                    viewModel.searchText = ""
                    viewModel.filterApps()
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.accentColor)
                .font(.system(size: 12))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var appList: some View {
        ScrollView {
            LazyVStack(spacing: 6) {
                ForEach(viewModel.filteredApps) { app in
                    AppCardView(
                        app: app,
                        isSelected: viewModel.selectedApp?.id == app.id,
                        onSelect: { viewModel.selectApp(app) },
                        onUninstall: { viewModel.requestUninstall(for: app) }
                    )
                    .padding(.horizontal, 12)
                }
            }
            .padding(.vertical, 12)
        }
    }
}

struct AppCardView: View {
    let app: MacApp
    let isSelected: Bool
    let onSelect: () -> Void
    let onUninstall: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 12) {
            // App Icon
            Group {
                if let icon = app.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(systemName: "app.square")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            
            // App Info
            VStack(alignment: .leading, spacing: 3) {
                Text(app.name)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    if let version = app.version {
                        Text("v\(version)")
                            .font(.system(size: 11))
                            .foregroundStyle(.tertiary)
                    }
                    
                    Text(app.sizeFormatted)
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                    
                    if app.isSystemApp {
                        Text("系统")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.orange)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(.orange.opacity(0.15))
                            )
                    }
                }
            }
            
            Spacer()
            
            // Category badge
            Text(app.category.rawValue)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.quaternary.opacity(0.5))
                )
            
            // Uninstall button
            Button(action: onUninstall) {
                Text("卸载")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(app.isSystemApp ? Color.gray.opacity(0.4) : Color.red.opacity(0.85))
                    )
            }
            .buttonStyle(.plain)
            .disabled(app.isSystemApp)
            .help(app.isSystemApp ? "系统应用无法卸载" : "卸载此应用")
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isSelected ? Color.accentColor.opacity(0.08) : (isHovered ? Color.gray.opacity(0.05) : Color.clear))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.accentColor.opacity(0.3) : (isHovered ? Color.gray.opacity(0.15) : Color.clear), lineWidth: 1)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .onTapGesture { onSelect() }
        .contentShape(Rectangle())
    }
}
