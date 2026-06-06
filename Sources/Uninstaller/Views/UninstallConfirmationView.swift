import SwiftUI

struct UninstallConfirmationView: View {
    let app: MacApp
    let associatedFiles: [AssociatedFile]
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    @State private var isAnimating = false
    
    private var totalAssociatedSize: String {
        let total = associatedFiles.reduce(0) { $0 + ($1.sizeBytes ?? 0) }
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: total)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "trash.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(.red)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
            }
            
            VStack(spacing: 6) {
                Text("确认卸载")
                    .font(.system(size: 18, weight: .bold))
                
                Text("将卸载「\(app.name)」及其关联文件")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // App info
            HStack(spacing: 12) {
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
                .frame(width: 36, height: 36)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(app.name)
                        .font(.system(size: 13, weight: .semibold))
                    Text(app.sizeFormatted)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.quaternary.opacity(0.3))
            )
            
            if !associatedFiles.isEmpty {
                associatedFilesSection
            }
            
            HStack(spacing: 12) {
                Button(action: onCancel) {
                    Text("取消")
                        .font(.system(size: 13, weight: .medium))
                        .frame(width: 80)
                }
                .controlSize(.large)
                .keyboardShortcut(.escape)
                
                Button(action: onConfirm) {
                    Label("确认卸载", systemImage: "trash")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.red.gradient)
                        )
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.return)
            }
        }
        .padding(24)
        .frame(width: 420)
        .background(Color(.windowBackgroundColor))
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
    
    private var associatedFilesSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("将同时清理以下关联文件：", systemImage: "doc.on.doc")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
            
            ForEach(associatedFiles.prefix(5)) { file in
                HStack(spacing: 6) {
                    Image(systemName: "doc")
                        .font(.system(size: 9))
                        .foregroundStyle(.tertiary)
                    Text(file.name)
                        .font(.system(size: 11))
                        .lineLimit(1)
                    Spacer()
                    Text(file.sizeFormatted)
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 6)
            }
            
            if associatedFiles.count > 5 {
                Text("及其他 \(associatedFiles.count - 5) 个文件...")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
                    .padding(.leading, 6)
            }
            
            if totalAssociatedSize != "0 bytes" {
                Text("共计 \(totalAssociatedSize)")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
                    .padding(.leading, 6)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.orange.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.orange.opacity(0.15), lineWidth: 1)
                )
        )
    }
}
