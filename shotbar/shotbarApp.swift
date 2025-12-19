
import SwiftUI
import ApplicationServices
// For checking accessibility permissions
// アクセシビリティ権限確認用

@main
struct shotbarApp: App {
    @StateObject var engine = AutoCaptureEngine()

    var body: some Scene {
        // Settings window
        // 設定ウィンドウ
        Window("Settings", id: "settings") {
            SettingsView()
        }

        // Menu bar
        // メニューバー
        MenuBarExtra("AutoCapture", systemImage: "camera.shutter.button") {
            MenuBarContent(engine: engine)
        }
    }
}

struct MenuBarContent: View {
    @ObservedObject var engine: AutoCaptureEngine
    @Environment(\.openWindow) var openWindow

    var body: some View {
        Button("Take Single Shot") {
            engine.takeSingleShot()
        }

        Divider()

        Button(engine.isRunning ? "Stop" : "Start Auto Capture") {
            if engine.isRunning {
                engine.stop()
            } else {
                engine.start()
            }
        }
        .keyboardShortcut("s")
        // Can also toggle with Cmd+S
        // Cmd+Sでも切り替え可能に

        Divider()

        Button("Settings...") {
            openWindow(id: "settings")
            NSApp.activate(ignoringOtherApps: true)
        }

        Divider()

        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
    }
}
