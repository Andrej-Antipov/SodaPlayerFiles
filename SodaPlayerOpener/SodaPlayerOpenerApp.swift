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
        // Заглушка для SwiftUI, которая никогда не покажет пустое окно
        Settings {
            EmptyView()
        }
    }
    
    func executeFolderOpening() {
        // Извлекаем путь $TMPDIR
        guard let tmpDir = ProcessInfo.processInfo.environment["TMPDIR"] else {
            showSystemAlert()
            return
        }
        
        let fullPath = (tmpDir as NSString).appendingPathComponent("sodaplayer/data/torrent")
        let url = URL(fileURLWithPath: fullPath)
        
        var isDirectory: ObjCBool = false
        let fileExists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
        
        if fileExists && isDirectory.boolValue {
            // Папка есть -> Открываем в Finder и выгружаем из памяти
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
            exit(0)
        } else {
            // Папки нет -> Показываем ошибку
            showSystemAlert()
        }
    }
    
    func showSystemAlert() {
        // Локализация текстов
        let systemLanguages = Locale.preferredLanguages
        let isRussian = systemLanguages.first?.hasPrefix("ru") ?? false
        let title = isRussian ? "Ошибка" : "Error"
        let msg = isRussian ? "Папка не существует." : "Folder does not exist."
        
        // Создаем панель в компактном вертикальном формате
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
        
        // 1. ИКОНКА ПРИЛОЖЕНИЯ: Расположена сверху по центру
        let imageView = NSImageView(frame: NSRect(x: 100, y: 105, width: 40, height: 40))
        imageView.image = NSImage(named: NSImage.applicationIconName)
        imageView.imageScaling = .scaleProportionallyUpOrDown
        contentView.addSubview(imageView)
        
        // 2. ТЕКСТ: Находится строго под иконкой
        let label = NSTextField(labelWithString: msg)
        label.frame = NSRect(x: 16, y: 65, width: 208, height: 24)
        label.font = NSFont.systemFont(ofSize: 13)
        label.alignment = .center
        contentView.addSubview(label)
        
        // 3. КНОПКА ОК: Центрирована по вертикали в нижнем пространстве
        let button = NSButton(title: "OK", target: nil, action: nil)
        button.frame = NSRect(x: 80, y: 16, width: 80, height: 32)
        button.bezelStyle = .rounded
        button.target = NSApp
        button.action = #selector(NSApplication.terminate(_:))
        contentView.addSubview(button)
        
        panel.contentView = contentView
        panel.makeKeyAndOrderFront(nil)
        
        // Активация процесса с учетом версии ОС
        if #available(macOS 14.0, *) {
            NSApp.activate()
        } else {
            NSApp.activate(ignoringOtherApps: true)
        }
        
        // ЗВУК С СОВМЕСТИМОСТЬЮ С macOS 11.0 (Big Sur)
        let defaults = UserDefaults.standard
        var isDNDActive = false

        if #available(macOS 12.0, *) {
            // Для macOS 12 и новее (Monterey, Ventura, Sonoma, Sequoia...)
            let controlCenterPrefs = defaults.persistentDomain(forName: "com.apple.controlcenter")
            isDNDActive = controlCenterPrefs?["NSStatusItem Visible FocusModes"] as? Int == 1
        } else {
            // Для macOS 11 (Big Sur)
            let ncPrefs = defaults.persistentDomain(forName: "com.apple.notificationcenterui")
            isDNDActive = ncPrefs?["doNotDisturb"] as? Bool ?? false
        }

        if !isDNDActive {
            NSSound.beep()
        }
        
        // Таймер автозакрытия через 2.5 секунды
        let timer = Timer(timeInterval: 2.5, repeats: false) { _ in
            exit(0)
        }
        RunLoop.current.add(timer, forMode: .common)
        
        NSApp.run()
    }
}
