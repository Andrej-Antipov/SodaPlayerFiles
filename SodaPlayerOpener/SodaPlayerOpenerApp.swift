import SwiftUI
import Cocoa


@main
struct SodaPlayerOpenerApp: App {
    
    init() {
        // 1. Делаем приложение фоновым агентом, чтобы Терминал и Dock не открывались
        NSApplication.shared.setActivationPolicy(.accessory)
        
        // 2. Запускаем проверку папки
        executeFolderOpening()
    }
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
    
    
    
    func executeFolderOpening() {
        guard let tmpDir = ProcessInfo.processInfo.environment["TMPDIR"] else {
            showSystemAlert()
            return
        }
        
        let fullPath = (tmpDir as NSString).appendingPathComponent("sodaplayer/data/torrent")
        let url = URL(fileURLWithPath: fullPath)
        
        var isDirectory: ObjCBool = false
        let fileExists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
        
        if fileExists && isDirectory.boolValue {
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
            exit(0)
        } else {
            showSystemAlert()
        }
    }
    
    func showSystemAlert() {
        let systemLanguages = Locale.preferredLanguages
        let isRussian = systemLanguages.first?.hasPrefix("ru") ?? false
        let title = isRussian ? "Ошибка" : "Error"
        let msg = isRussian ? "Папка не существует." : "Folder does not exist."
        
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 240, height: 160),
            styleMask: [.titled, .closable, .nonactivatingPanel, .utilityWindow],
            backing: .buffered,
            defer: false
        )
        
        panel.level = .screenSaver
        panel.title = title
        panel.center()
        
        let viewBounds = NSRect(x: 0, y: 0, width: panel.frame.width, height: panel.frame.height)
        let contentView = NSView(frame: viewBounds)
        
        let imageView = NSImageView(frame: NSRect(x: 100, y: 105, width: 40, height: 40))
        imageView.image = NSImage(named: NSImage.applicationIconName)
        imageView.imageScaling = .scaleProportionallyUpOrDown
        contentView.addSubview(imageView)
        
        let label = NSTextField(labelWithString: msg)
        label.frame = NSRect(x: 16, y: 65, width: 208, height: 24)
        label.font = NSFont.systemFont(ofSize: 13)
        label.alignment = .center
        contentView.addSubview(label)
        
        let button = NSButton(title: "OK", target: nil, action: nil)
        button.frame = NSRect(x: 80, y: 16, width: 80, height: 32)
        button.bezelStyle = .rounded
        button.target = NSApp
        button.action = #selector(NSApplication.terminate(_:))
        contentView.addSubview(button)
        
        panel.contentView = contentView
        panel.makeKeyAndOrderFront(nil)
        
        if #available(macOS 14.0, *) {
            NSApp.activate()
        } else {
            NSApp.activate(ignoringOtherApps: true)
        }
        
        // --- ТОЧНАЯ КОСВЕННАЯ ПРОВЕРКА DND ПО НАЙДЕННОМУ МАРКЕРУ ---
        var isDNDActive = false
        dprint("🔍 Проверка маркера 'VisibleCC FocusModes'...")
        
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/plutil")
        
        // Извлекаем подтвержденный вами ключ напрямую из plist-файла
        process.arguments = [
            "-extract", "NSStatusItem VisibleCC FocusModes", "raw",
            "-o", "-", "--",
            "\(NSHomeDirectory())/Library/Preferences/com.apple.controlcenter.plist"
        ]
        process.standardOutput = pipe
        process.standardError = Pipe() // Игнорируем ошибку, если ключа нет в файле (когда DND выключен)
        
        try? process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
            dprint("📊 Значение маркера в системе: \(output)")
            if output.lowercased() == "true" || output == "1" {
                isDNDActive = true
            }
        }
        
        // Принятие окончательного решения о выводе звука
        if !isDNDActive {
            dprint("🔊 Режим Сон/DND выключен. Воспроизведение звука Funk.aiff...")
            let soundProcess = Process()
            soundProcess.executableURL = URL(fileURLWithPath: "/usr/bin/afplay")
            soundProcess.arguments = ["/System/Library/Sounds/Funk.aiff"]
            soundProcess.standardOutput = Pipe()
            soundProcess.standardError = Pipe()
            try? soundProcess.run()
        } else {
            dprint("🤫 Результат: Звук приглушен. Найден активный маркер VisibleCC FocusModes.")
        }
        // -----------------------------------------------------------
        
        let timer = Timer(timeInterval: 2.5, repeats: false) { _ in
            exit(0)
        }
        RunLoop.current.add(timer, forMode: .common)
        
        NSApp.run()
    }
}

