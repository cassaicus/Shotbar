
import SwiftUI
import ApplicationServices // アクセシビリティ権限確認用

@main
struct shotbarApp: App {
    @StateObject var engine = AutoCaptureEngine()

    var body: some Scene {
        // 設定ウィンドウ
        Window("設定", id: "settings") {
            SettingsView()
        }

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
        Button("1回だけ撮影") {
            engine.takeSingleShot()
        }

        Divider()

        Button(engine.isRunning ? "停止" : "自動撮影開始") {
            if engine.isRunning {
                engine.stop()
            } else {
                engine.start()
            }
        }
        .keyboardShortcut("s") // Cmd+Sでも切り替え可能に

        Divider()

        Button("設定...") {
            openWindow(id: "settings")
            NSApp.activate(ignoringOtherApps: true)
        }

        Divider()

        Button("終了") {
            NSApplication.shared.terminate(nil)
        }
    }
}
