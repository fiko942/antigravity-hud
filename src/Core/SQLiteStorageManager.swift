import Cocoa
import SQLite3

// MARK: - Native SQLite3 Persistent Storage Engine
public class SQLiteStorageManager {
    public static let shared = SQLiteStorageManager()

    private var db: OpaquePointer?
    private let dbPath: String
    private let queue = DispatchQueue(label: "com.antigravity.hud.sqlite", qos: .utility)

    private init() {
        let configDir = ("~/.config/antigravity-hud" as NSString).expandingTildeInPath
        try? FileManager.default.createDirectory(atPath: configDir, withIntermediateDirectories: true)
        self.dbPath = (configDir as NSString).appendingPathComponent("antigravity_hud.sqlite3")

        openDatabase()
        createTable()
        migrateLegacyJSON()
    }

    deinit {
        if db != nil {
            sqlite3_close(db)
        }
    }

    private func openDatabase() {
        if sqlite3_open_v2(dbPath, &db, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FULLMUTEX, nil) != SQLITE_OK {
            print("[SQLite] Failed to open database at: \(dbPath)")
            return
        }

        // Enable Write-Ahead Logging (WAL) mode for atomic non-blocking I/O
        execute(sql: "PRAGMA journal_mode = WAL;")
        execute(sql: "PRAGMA synchronous = NORMAL;")
    }

    private func createTable() {
        let sql = """
        CREATE TABLE IF NOT EXISTS app_settings (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        """
        execute(sql: sql)
    }

    private func execute(sql: String) {
        var err: UnsafeMutablePointer<Int8>?
        if sqlite3_exec(db, sql, nil, nil, &err) != SQLITE_OK {
            if let err = err {
                let msg = String(cString: err)
                print("[SQLite] Exec error: \(msg)")
                sqlite3_free(err)
            }
        }
    }

    // MARK: - Getters
    public func getString(_ key: String, default defaultValue: String = "") -> String {
        var result = defaultValue
        queue.sync {
            let sql = "SELECT value FROM app_settings WHERE key = ? LIMIT 1;"
            var stmt: OpaquePointer?
            if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
                sqlite3_bind_text(stmt, 1, (key as NSString).utf8String, -1, nil)
                if sqlite3_step(stmt) == SQLITE_ROW {
                    if let cStr = sqlite3_column_text(stmt, 0) {
                        result = String(cString: cStr)
                    }
                }
            }
            sqlite3_finalize(stmt)
        }
        return result
    }

    public func getDouble(_ key: String, default defaultValue: Double) -> Double {
        let str = getString(key, default: "")
        return Double(str) ?? defaultValue
    }

    public func getBool(_ key: String, default defaultValue: Bool) -> Bool {
        let str = getString(key, default: "")
        if str.isEmpty { return defaultValue }
        return (str == "true" || str == "1")
    }

    public func getInt(_ key: String, default defaultValue: Int) -> Int {
        let str = getString(key, default: "")
        return Int(str) ?? defaultValue
    }

    // MARK: - Setters
    public func setString(_ key: String, value: String) {
        queue.sync {
            let sql = """
            INSERT INTO app_settings (key, value, updated_at) VALUES (?, ?, CURRENT_TIMESTAMP)
            ON CONFLICT(key) DO UPDATE SET value = excluded.value, updated_at = CURRENT_TIMESTAMP;
            """
            var stmt: OpaquePointer?
            if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
                sqlite3_bind_text(stmt, 1, (key as NSString).utf8String, -1, nil)
                sqlite3_bind_text(stmt, 2, (value as NSString).utf8String, -1, nil)
                if sqlite3_step(stmt) != SQLITE_DONE {
                    print("[SQLite] Failed to write key: \(key)")
                }
            }
            sqlite3_finalize(stmt)
        }
    }

    public func setDouble(_ key: String, value: Double) {
        setString(key, value: String(value))
    }

    public func setBool(_ key: String, value: Bool) {
        setString(key, value: value ? "true" : "false")
    }

    public func setInt(_ key: String, value: Int) {
        setString(key, value: String(value))
    }

    // MARK: - Legacy JSON Migration
    private func migrateLegacyJSON() {
        let configDir = ("~/.config/antigravity-hud" as NSString).expandingTildeInPath

        // 1. Settings JSON
        let settingsFile = (configDir as NSString).appendingPathComponent("settings.json")
        if let data = try? Data(contentsOf: URL(fileURLWithPath: settingsFile)),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let mode = json["activeTaskDisplayMode"] as? String, getString("active_task_display_mode").isEmpty {
                setString("active_task_display_mode", value: mode)
            }
            if let idleHover = json["idleHoverExpands"] as? Bool, getString("idle_hover_expands").isEmpty {
                setBool("idle_hover_expands", value: idleHover)
            }
            if let sound = json["soundEnabled"] as? Bool, getString("sound_enabled").isEmpty {
                setBool("sound_enabled", value: sound)
            }
            if let haptics = json["hapticsEnabled"] as? Bool, getString("haptics_enabled").isEmpty {
                setBool("haptics_enabled", value: haptics)
            }
            if let launch = json["launchAtLogin"] as? Bool, getString("launch_at_login").isEmpty {
                setBool("launch_at_login", value: launch)
            }
        }

        // 2. Theme JSON
        let themeFile = (configDir as NSString).appendingPathComponent("theme.json")
        if let data = try? Data(contentsOf: URL(fileURLWithPath: themeFile)),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let activeTheme = json["activeTheme"] as? String, getString("active_theme").isEmpty {
                setString("active_theme", value: activeTheme)
            }
        }
    }
}
