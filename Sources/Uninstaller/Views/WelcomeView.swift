import SwiftUI

struct WelcomeView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: .blue.opacity(0.3), radius: 20, x: 0, y: 10)
                
                Image(systemName: "trash.slash.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.white)
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
            }
            
            Text("应用卸载器")
                .font(.system(size: 28, weight: .bold))
            
            Text("从左侧选择一个应用，或点击刷新按钮扫描应用")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.controlBackgroundColor))
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}
