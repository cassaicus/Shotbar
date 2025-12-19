import SwiftUI

struct SettingsView: View {
    @AppStorage("saveFolderPath") private var saveFolderPath: String = ""
    @AppStorage("autoCreateFolder") private var autoCreateFolder: Bool = false
    @AppStorage("filenamePrefix") private var filenamePrefix: String = "capture"
    @AppStorage("arrowKey") private var arrowKey: Int = 125 // Default Down (125)
    @AppStorage("maxCount") private var maxCount: Int = 50
    @AppStorage("initialDelay") private var initialDelay: Double = 5.0
    @AppStorage("intervalDelay") private var intervalDelay: Double = 1.0
    @AppStorage("detectDuplicate") private var detectDuplicate: Bool = false
    @AppStorage("duplicateThreshold") private var duplicateThreshold: Double = 0.05
    @AppStorage("completionSound") private var completionSound: String = "None"
    @AppStorage("countDownSound") private var countDownSound: String = "Beep"
    
    private let soundOptions = ["Beep", "Tink", "Pop", "Ping", "Morse", "None"]
    
    var body: some View {
        VStack(spacing: 20) {
            // Save settings section
            // 保存設定セクション
            GroupBox(label: Label("Save Settings", systemImage: "folder.badge.gear")) {
                Grid(alignment: .leading, verticalSpacing: 12) {
                    GridRow {
                        Label("Save Destination:", systemImage: "folder")
                            .gridColumnAlignment(.leading)
                            .help("Destination folder for screenshots")
                        
                        HStack {
                            Text(saveFolderPath.isEmpty ? "Not Selected (Desktop)" : saveFolderPath)
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .foregroundColor(saveFolderPath.isEmpty ? .secondary : .primary)
                                .help(saveFolderPath)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color(NSColor.controlBackgroundColor))
                                .cornerRadius(4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                                )
                            
                            Button("Select...") {
                                selectFolder()
                            }
                        }
                    }
                    
                    GridRow {
                        Color.clear
                            .gridColumnAlignment(.leading)
                            .frame(width: 0, height: 0)
                        
                        Toggle("Automatically create folder when saving", isOn: $autoCreateFolder)
                            .toggleStyle(.checkbox)
                            .help("Create a folder with date/time name at start and save there")
                    }
                    
                    GridRow {
                        Label("Filename Prefix:", systemImage: "pencil")
                            .help("String to be prefixed to the saved file")
                        
                        TextField("Ex: capture", text: $filenamePrefix)
                    }
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
            
            // Behavior settings section
            // 動作設定セクション
            GroupBox(label: Label("Behavior Settings", systemImage: "camera.badge.ellipsis")) {
                Grid(alignment: .leading, verticalSpacing: 12) {
                    GridRow {
                        Label("Key Direction:", systemImage: "arrowkeys")
                            .gridColumnAlignment(.leading)
                            .help("Key input sent after capture")
                        
                        Picker("", selection: $arrowKey) {
                            Text("Left").tag(123)
                            Text("Right").tag(124)
                            Text("Down").tag(125)
                            Text("Up").tag(126)
                        }
                        .labelsHidden()
                        .fixedSize()
                    }
                    
                    GridRow {
                        Label("Max Shot Count:", systemImage: "number")
                            .help("Maximum number of auto captures")
                        
                        HStack {
                            TextField("Count", value: $maxCount, formatter: NumberFormatter())
                                .frame(width: 80)
                                .multilineTextAlignment(.trailing)
                            Stepper("", value: $maxCount, in: 1...999)
                                .labelsHidden()
                            Text("times")
                        }
                        .onChange(of: maxCount) { oldValue, newValue in
                            if newValue < 1 { maxCount = 1 }
                            if newValue > 999 { maxCount = 999 }
                        }
                    }
                    
                    GridRow {
                        Label("Initial Delay:", systemImage: "timer")
                            .help("Wait time before starting capture")
                        
                        HStack {
                            TextField("sec", value: $initialDelay, format: .number)
                                .frame(width: 80)
                                .multilineTextAlignment(.trailing)
                            Text("sec (Max 10s)")
                        }
                        .onChange(of: initialDelay) { oldValue, newValue in
                            if newValue > 10.0 { initialDelay = 10.0 }
                            if newValue < 0 { initialDelay = 0 }
                        }
                    }
                    
                    GridRow {
                        Label("Countdown Sound:", systemImage: "speaker.wave.2")
                            .help("Sound played every second during initial delay")
                        
                        Picker("", selection: $countDownSound) {
                            ForEach(soundOptions, id: \.self) { sound in
                                Text(sound)
                            }
                        }
                        .labelsHidden()
                        .fixedSize()
                    }
                    
                    GridRow {
                        Label("Interval:", systemImage: "clock.arrow.circlepath")
                            .help("Wait time between captures")
                        
                        HStack {
                            TextField("sec", value: $intervalDelay, format: .number)
                                .frame(width: 80)
                                .multilineTextAlignment(.trailing)
                            Text("sec")
                        }
                    }
                    
                    GridRow {
                        Label("Stop Condition:", systemImage: "stop.circle.fill")
                            .help("Wait time between captures")
                            .gridCellAnchor(.topLeading)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Toggle("Stop capture if duplicate image is detected", isOn: $detectDuplicate)
                                .toggleStyle(.checkbox)
                                .help("Ends capture if similar to the previously captured image")
                                .fixedSize()
                            
                            if detectDuplicate {
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack {
                                        Text("Threshold:")
                                            .font(.caption)
                                        Slider(value: $duplicateThreshold, in: 0.0...0.5, step: 0.01)
                                            .frame(width: 90)
                                        Text("\(duplicateThreshold, specifier: "%.2f")")
                                            .font(.caption)
                                            .monospacedDigit()
                                    }
                                    
                                    Text("Recommended: 0.25 (0.00 stops on exact match)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.leading, 20)
                                .help("Smaller values mean stricter matching (0.00 = Exact match). Increase to ignore clock seconds etc.")
                            }
                        }
                    }
                    
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
            
            // Notification section
            // 通知セクション
            GroupBox(label: Label("Notifications", systemImage: "bell.badge")) {
                HStack {
                    Label("Completion Sound:", systemImage: "speaker.wave.2")
                    
                    Picker("", selection: $completionSound) {
                        ForEach(soundOptions, id: \.self) { sound in
                            Text(sound)
                        }
                    }
                    .labelsHidden()
                    .fixedSize()
                    
                    Spacer()
                }
                .padding(8)
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .frame(width: 480) // UI要素に合わせて少し広げる
        .fixedSize(horizontal: true, vertical: true)
    }
    
    private func selectFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Select"
        panel.message = "Please select the destination folder"
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                saveFolderPath = url.path
            }
        }
    }
}

// For preview (Valid only in macOS environment)
// プレビュー用 (macOS環境でのみ有効)
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
