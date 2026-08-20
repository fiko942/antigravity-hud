import Cocoa

// MARK: - Auto-Register LaunchAgent on Login
public class LaunchAgentManager {
    public static func ensureInstalled() {
        let bundlePath = Bundle.main.bundlePath
        guard bundlePath.hasSuffix(".app") else { return }

        let agentDir = ("~/Library/LaunchAgents" as NSString).expandingTildeInPath
        let plistPath = (agentDir as NSString).appendingPathComponent("com.google.antigravity.hud.plist")
        let execPath = (bundlePath as NSString).appendingPathComponent("Contents/MacOS/AntigravityHUD")

        let plistContent = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>Label</key>
            <string>com.google.antigravity.hud</string>
            <key>ProgramArguments</key>
            <array>
                <string>\(execPath)</string>
            </array>
            <key>RunAtLoad</key>
            <true/>
            <key>KeepAlive</key>
            <true/>
            <key>StandardOutPath</key>
            <string>/tmp/antigravity-hud.log</string>
            <key>StandardErrorPath</key>
            <string>/tmp/antigravity-hud.error.log</string>
        </dict>
        </plist>
        """

        try? FileManager.default.createDirectory(atPath: agentDir, withIntermediateDirectories: true)
        if !FileManager.default.fileExists(atPath: plistPath) {
            try? plistContent.write(toFile: plistPath, atomically: true, encoding: .utf8)
            let task = Process()
            task.launchPath = "/bin/launchctl"
            task.arguments = ["load", "-w", plistPath]
            try? task.run()
        }
    }
}
