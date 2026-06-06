import SwiftUI

@main
struct UninstallerApp: App {
    @State private var isLaunching = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .opacity(isLaunching ? 0 : 1)
                
                if isLaunching {
                    LaunchScreenView()
                }
            }
            .animation(.easeOut(duration: 0.5), value: isLaunching)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation {
                        isLaunching = false
                    }
                }
            }
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentMinSize)
        .defaultSize(width: 960, height: 640)
        .commands {
            CommandGroup(replacing: .newItem) {}
            
            CommandMenu("应用") {
                Button("刷新应用列表") {
                    NotificationCenter.default.post(name: .refreshApps, object: nil)
                }
                .keyboardShortcut("r", modifiers: .command)
                
                Divider()
                
                Button("退出") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q", modifiers: .command)
            }
        }
    }
}

struct LaunchScreenView: View {
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 0.8
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color(red: 0.2, green: 0.1, blue: 0.3),
                    Color(red: 0.3, green: 0.1, blue: 0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: .purple.opacity(0.4), radius: 30, x: 0, y: 15)
                        .rotationEffect(.degrees(rotation))
                    
                    Image(systemName: "trash.slash.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.white)
                        .scaleEffect(scale)
                }
                
                Text("应用卸载器")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                
                Text("轻松卸载 macOS 应用")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                rotation = 5
                scale = 1.0
            }
        }
    }
}

extension Notification.Name {
    static let refreshApps = Notification.Name("refreshApps")
}
