import SwiftUI

struct icons {
    static let icon = "app.square" // ← Change to your desired symbol name
}

struct AppDetailView: View {
    let app: MacApp
    let associatedFiles: [AssociatedFile]
    let isScanningFiles: Bool
    let onUninstall: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                appHeader
                    .padding(.top, 8)
                
                Divider()
                
                // Info cards
                infoSection
                
                Divider()
                
                // Associated files
                associatedFilesSection
            }
            .padding(20)
        }
        .background(Color(.controlBackgroundColor))
    }
    
    private var appHeader: some View {
        HStack(spacing: 16) {
            Group {
                if let icon = app.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(systemName: icons.icon)  // Now resolves correctly
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 72, height: 72)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(app.name)
                    .font(.system(size: 22, weight: .bold))
                
                HStack(spacing: 8) {
                    if let version = app.version {
                        Label(version, systemImage: "tag")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                    
                    Label(app.sizeFormatted, systemImage: "externaldrive")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                    
                    Label(app.bundleIdentifier, systemImage: "barcode")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Text(app.path)
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                Button(action: onUninstall) {
                    Label("卸载应用", systemImage: "trash")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.red.gradient)
                        )
                }
                .buttonStyle(.plain)
                .disabled(app.isSystemApp)
                
                if app.isSystemApp {
                    Text("系统应用无法卸载")
                        .font(.system(size: 10))
                        .foregroundStyle(.orange)
                }
            }
        }
    }
    
    private var infoSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            InfoCard(
                title: "位置",
                value: app.path,
                icon: "folder",
                color: .blue
            )
            
            InfoCard(
                title: "包标识符",
                value: app.bundleIdentifier,
                icon: "barcode.viewfinder",
                color: .purple
            )
            
            InfoCard(
                title: "大小",
                value: app.sizeFormatted,
                icon: "externaldrive",
                color: .green
            )
            
            InfoCard(
                title: "分类",
                value: app.category.rawValue,
                icon: app.category.iconName,
                color: .orange
            )
        }
    }
    
    private var associatedFilesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("关联文件", systemImage: "doc.on.doc")
                    .font(.system(size: 14, weight: .semibold))
                
                Spacer()
                
                if isScanningFiles {
                    ProgressView()
                        .scaleEffect(0.6)
                    Text("扫描中...")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                } else {
                    Text("\(associatedFiles.count) 个文件")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            }
            
            if associatedFiles.isEmpty && !isScanningFiles {
                HStack {
                    Image(systemName: "checkmark.circle")
                        .foregroundStyle(.green)
                    Text("未发现关联文件")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.green.opacity(0.05))
                )
            } else if !associatedFiles.isEmpty {
                let grouped = Dictionary(grouping: associatedFiles) { $0.category }
                
                ForEach(FileCategory.allCases) { category in
                    let files = grouped[category] ?? []
                    if !files.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: category.iconName)
                                    .foregroundStyle(.secondary)
                                    .font(.system(size: 11))
                                Text(category.rawValue)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(.secondary)
                                Text("(\(files.count))")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.tertiary)
                            }
                            
                            ForEach(files) { file in
                                HStack(spacing: 6) {
                                    Image(systemName: "doc")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.tertiary)
                                    
                                    Text(file.name)
                                        .font(.system(size: 11, weight: .regular))
                                        .lineLimit(1)
                                    
                                    Spacer()
                                    
                                    Text(file.sizeFormatted)
                                        .font(.system(size: 10))
                                        .foregroundStyle(.tertiary)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(.quaternary.opacity(0.3))
                                )
                            }
                        }
                    }
                }
            } else {
                // Scanning
                ForEach(0..<3) { i in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.quaternary.opacity(0.3))
                        .frame(height: 24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.quaternary.opacity(0.3))
                                .frame(width: 120, height: 8)
                        )
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.background)
        )
    }
}

struct InfoCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
                
                Text(value)
                    .font(.system(size: 11, weight: .regular))
                    .lineLimit(2)
                    .truncationMode(.middle)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.background)
        )
    }
}
