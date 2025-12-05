
import SwiftUI
import ApplicationServices // アクセシビリティ権限確認用

@main
struct shotbarApp: App {
    @StateObject var engine = AutoCaptureEngine()

    var body: some Scene {
        // ウィンドウを持たないメニューバーアプリとして定義
        MenuBarExtra("AutoCapture", systemImage: "camera.shutter.button") {
            Button(engine.isRunning ? "停止中..." : "開始") {
                if engine.isRunning {
                    engine.stop()
                } else {
                    engine.start()
                }
            }
            .keyboardShortcut("s") // Cmd+Sでも切り替え可能に

            Divider()

            Button("終了") {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}
