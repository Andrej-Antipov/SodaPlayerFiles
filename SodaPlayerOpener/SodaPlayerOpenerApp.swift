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
        let alert = NSAlert()
        alert.alertStyle = .critical
        
        let systemLanguages = Locale.preferredLanguages
        let isRussian = systemLanguages.first?.hasPrefix("ru") ?? false
        
        if isRussian {
            alert.messageText = "Ошибка"
            alert.informativeText = "Папка не существует."
            alert.addButton(withTitle: "ОК")
        } else {
            alert.messageText = "Error"
            alert.informativeText = "Folder does not exist."
            alert.addButton(withTitle: "OK")
        }
        
        let dummyWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1, height: 1),
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        dummyWindow.center()
        
        alert.beginSheetModal(for: dummyWindow) { _ in
            exit(0)
        }
        
        NSApp.activate(ignoringOtherApps: true)
        
        // Автозакрытие через 4 секунды с полной выгрузкой из ОЗУ
        Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { _ in
            exit(0)
        }
    }
}

