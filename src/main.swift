import Cocoa

// MARK: - Antigravity HUD Native Application Entry Point
guard ensureSingleInstance() else {
    exit(0)
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
