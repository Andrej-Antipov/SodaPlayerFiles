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
        // Временно возвращаем режим обычного приложения,
        // чтобы macOS разрешила перехватить фокус и показать окно поверх всех
        NSApp.setActivationPolicy(.regular)
        
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
        
        // Поднимаем окно алерта на уровень системного статус-бара.
        // Это гарантирует, что оно перекроет окна ЛЮБЫХ других запущенных программ.
        alert.window.level = .statusBar
        
        // Активируем приложение
        if #available(macOS 14.0, *) {
            NSApp.activate()
        } else {
            NSApp.activate(ignoringOtherApps: true)
        }
        
        // Создаем таймер, но НЕ запускаем его автоматически
        let timer = Timer(timeInterval: 2.5, repeats: false) { _ in
            exit(0)
        }
        
        // Принудительно добавляем таймер в режим обработки модальных окон.
        // Это позволит ему сработать, даже когда поток заблокирован методом runModal()
        RunLoop.current.add(timer, forMode: .common)
        
        // Запускаем окно в модальном режиме (теперь таймер закроет его через 2.5 сек)
        alert.runModal()
        exit(0)
    }
}

