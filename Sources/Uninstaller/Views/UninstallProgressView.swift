import SwiftUI

struct UninstallProgressView: View {
    let progress: Double
    let statusText: String
    let appName: String
    let isComplete: Bool
    let onDismiss: (() -> Void)?
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 24) {
            if isComplete {
                completionView
            } else {
                progressView
            }
        }
        .padding(32)
        .frame(width: 400)
        .background(
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        .onAppear {
            if isComplete {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    isAnimating = true
                }
            }
        }
        .onChange(of: isComplete) { newValue in
            if newValue {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    isAnimating = true
                }
            }
        }
    }
    
    private var completionView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.green)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
            }
            
            VStack(spacing: 6) {
                Text("卸载完成")
                    .font(.system(size: 18, weight: .bold))
                
                Text("「\(appName)」及其关联文件已成功移除")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: { onDismiss?() }) {
                Text("好的")
                    .font(.system(size: 13, weight: .medium))
                    .frame(width: 80)
            }
            .controlSize(.large)
            .keyboardShortcut(.return)
        }
    }
    
    private var progressView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 6)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: progress)
                
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.secondary)
            }
            
            VStack(spacing: 6) {
                Text("正在卸载...")
                    .font(.system(size: 16, weight: .semibold))
                
                Text(statusText)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            
            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .tint(
                    LinearGradient(
                        colors: [.blue, .purple, .red],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 280)
        }
    }
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
