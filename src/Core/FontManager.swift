import Cocoa
import CoreText

// MARK: - Automated Native Font Discovery & Registration Manager
public class FontManager {
    public static let shared = FontManager()

    private init() {}

    /// Automatically registers all bundled .ttf / .otf fonts in memory and synchronizes to ~/Library/Fonts
    public func ensureFontsRegistered() {
        var candidateURLs: [URL] = []

        // 1. Check Bundle resources Fonts folder
        if let resourceURL = Bundle.main.resourceURL {
            let fontsFolder = resourceURL.appendingPathComponent("Fonts")
            if FileManager.default.fileExists(atPath: fontsFolder.path),
               let urls = try? FileManager.default.contentsOfDirectory(at: fontsFolder, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) {
                candidateURLs.append(contentsOf: urls)
            }
        }

        // 2. Direct Contents/Resources/Fonts check
        let directResourcesFonts = Bundle.main.bundleURL.appendingPathComponent("Contents/Resources/Fonts")
        if FileManager.default.fileExists(atPath: directResourcesFonts.path),
           let urls = try? FileManager.default.contentsOfDirectory(at: directResourcesFonts, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) {
            candidateURLs.append(contentsOf: urls)
        }

        let validFontURLs = candidateURLs.filter { url in
            let ext = url.pathExtension.lowercased()
            return ext == "ttf" || ext == "otf"
        }

        guard !validFontURLs.isEmpty else { return }

        // In-process CoreText registration (zero admin privileges required)
        if #available(macOS 10.15, *) {
            CTFontManagerRegisterFontURLs(validFontURLs as CFArray, .process, true, nil)
        } else {
            var unmanagedError: Unmanaged<CFArray>?
            CTFontManagerRegisterFontsForURLs(validFontURLs as CFArray, .process, &unmanagedError)
        }

        // Permanent User Font Sync to ~/Library/Fonts
        let userFontsDir = ("~/Library/Fonts" as NSString).expandingTildeInPath
        try? FileManager.default.createDirectory(atPath: userFontsDir, withIntermediateDirectories: true)

        for fontURL in validFontURLs {
            let destPath = (userFontsDir as NSString).appendingPathComponent(fontURL.lastPathComponent)
            if !FileManager.default.fileExists(atPath: destPath) {
                try? FileManager.default.copyItem(atPath: fontURL.path, toPath: destPath)
            }
        }
    }

    /// Verifies font existence or gracefully steps through a prioritized fallback list
    public func resolveFont(preferredName: String?, fallbackNames: [String], size: CGFloat, defaultWeight: NSFont.Weight = .bold) -> NSFont {
        if let name = preferredName, let font = NSFont(name: name, size: size) {
            return font
        }
        for name in fallbackNames {
            if let font = NSFont(name: name, size: size) {
                return font
            }
        }
        return NSFont.systemFont(ofSize: size, weight: defaultWeight)
    }
}
