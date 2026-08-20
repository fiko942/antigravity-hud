import Foundation

// MARK: - Global Brain Transcript & Status Watcher
public class BrainWatcher {
    public var onActivityChanged: ((AgentActivity) -> Void)?

    private let brainPath = ("~/.gemini/antigravity-ide/brain" as NSString).expandingTildeInPath
    private let directStatusPath = "/tmp/antigravity-status.json"
    private var currentTrackedFile: String? = nil
    private var currentFileHandle: FileHandle? = nil
    private var currentFileOffset: UInt64 = 0
    private var idleTimer: Timer? = nil

    private var currentActivity = AgentActivity(
        state: "idle",
        header: "ANTIGRAVITY • READY",
        detail: "Standby for prompt",
        activePath: nil,
        isAnimated: false
    )

    public init() {}

    public func poll() {
        // Priority 1: Direct status file for manual/fast injection
        if let data = try? Data(contentsOf: URL(fileURLWithPath: directStatusPath)),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let state = json["state"] as? String {
            let event = json["event"] as? String ?? "Standby"
            let step = json["step"] as? Int
            let targetFile = json["targetFile"] as? String
            let stepPrefix = step != nil ? "STEP #\(step!) • " : ""

            let header = "ANTIGRAVITY • \(stepPrefix)\(state.uppercased())"
            let detail = targetFile ?? formatEventName(event)
            let isAnimated = (state == "working" || state == "thinking")

            updateActivity(
                state: state,
                header: header,
                detail: detail,
                activePath: targetFile,
                isAnimated: isAnimated
            )
            return
        }

        // Priority 2: Direct transcript JSONL tailing
        scanLatestTranscriptDirectly()
    }

    private func updateActivity(state: String, header: String, detail: String, activePath: String?, isAnimated: Bool) {
        currentActivity = AgentActivity(
            state: state,
            header: header,
            detail: detail,
            activePath: activePath,
            isAnimated: isAnimated
        )
        onActivityChanged?(currentActivity)
    }

    private func scanLatestTranscriptDirectly() {
        let fileManager = FileManager.default
        guard let entries = try? fileManager.contentsOfDirectory(atPath: brainPath) else { return }

        var latestFile: String? = nil
        var latestDate: Date = Date.distantPast

        for entry in entries where !entry.hasPrefix(".") && entry != "tempmediaStorage" {
            let logPath = (brainPath as NSString).appendingPathComponent("\(entry)/.system_generated/logs/transcript.jsonl")
            if let attrs = try? fileManager.attributesOfItem(atPath: logPath),
               let modDate = attrs[.modificationDate] as? Date,
               modDate > latestDate {
                latestDate = modDate
                latestFile = logPath
            }
        }

        guard let logFile = latestFile else { return }

        if logFile != currentTrackedFile {
            try? currentFileHandle?.close()
            currentTrackedFile = logFile
            if let handle = try? FileHandle(forReadingFrom: URL(fileURLWithPath: logFile)),
               let attrs = try? fileManager.attributesOfItem(atPath: logFile),
               let size = attrs[.size] as? UInt64 {
                currentFileHandle = handle
                currentFileOffset = size
            }
            return
        }

        guard let handle = currentFileHandle,
              let attrs = try? fileManager.attributesOfItem(atPath: logFile),
              let currentSize = attrs[.size] as? UInt64,
              currentSize > currentFileOffset else { return }

        handle.seek(toFileOffset: currentFileOffset)
        let data = handle.readDataToEndOfFile()
        currentFileOffset = currentSize

        if let content = String(data: data, encoding: .utf8) {
            let lines = content.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            for line in lines {
                if let lineData = line.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: lineData) as? [String: Any],
                   let type = json["type"] as? String {

                    let stepIndex = json["step_index"] as? Int
                    let stepPrefix = stepIndex != nil ? "STEP #\(stepIndex!) • " : ""

                    if type == "USER_INPUT" {
                        idleTimer?.invalidate()
                        updateActivity(
                            state: "thinking",
                            header: "ANTIGRAVITY • \(stepPrefix)THINKING",
                            detail: "Reasoning & planning actions...",
                            activePath: nil,
                            isAnimated: true
                        )
                    } else if type == "PLANNER_RESPONSE" {
                        if let toolCalls = json["tool_calls"] as? [[String: Any]],
                           let first = toolCalls.first,
                           let name = first["name"] as? String {
                            idleTimer?.invalidate()
                            let args = first["args"] as? [String: Any] ?? (first["parameters"] as? [String: Any] ?? [:])
                            let (actionTitle, actionDetail, activePath) = parseToolDetails(toolName: name, args: args)

                            updateActivity(
                                state: "working",
                                header: "ANTIGRAVITY • \(stepPrefix)\(actionTitle)",
                                detail: actionDetail,
                                activePath: activePath,
                                isAnimated: true
                            )
                        } else {
                            updateActivity(
                                state: "done",
                                header: "ANTIGRAVITY • \(stepPrefix)COMPLETED",
                                detail: "Task response generated",
                                activePath: nil,
                                isAnimated: false
                            )
                            idleTimer?.invalidate()
                            idleTimer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: false) { [weak self] _ in
                                self?.updateActivity(
                                    state: "idle",
                                    header: "ANTIGRAVITY • READY",
                                    detail: "Standby for prompt",
                                    activePath: nil,
                                    isAnimated: false
                                )
                            }
                        }
                    } else if type == "RUN_COMMAND" || type.contains("FILE") || type.contains("DIR") {
                        idleTimer?.invalidate()
                        updateActivity(
                            state: "working",
                            header: "ANTIGRAVITY • \(stepPrefix)EXECUTING",
                            detail: formatEventName(type),
                            activePath: nil,
                            isAnimated: true
                        )
                    }
                }
            }
        }
    }

    private func parseToolDetails(toolName: String, args: [String: Any]) -> (String, String, String?) {
        var activePath: String? = nil

        switch toolName {
        case "replace_file_content", "multi_replace_file_content", "write_to_file":
            let path = args["TargetFile"] as? String ?? (args["target_file"] as? String ?? "")
            activePath = path.isEmpty ? nil : path
            let filename = (path as NSString).lastPathComponent
            let display = filename.isEmpty ? "Editing code..." : "Editing \(filename)"
            return ("EDITING FILE", display, activePath)

        case "view_file":
            let path = args["AbsolutePath"] as? String ?? (args["path"] as? String ?? "")
            activePath = path.isEmpty ? nil : path
            let filename = (path as NSString).lastPathComponent
            let display = filename.isEmpty ? "Reading file..." : "Reading \(filename)"
            return ("READING FILE", display, activePath)

        case "run_command":
            let cmd = args["CommandLine"] as? String ?? (args["command"] as? String ?? "Running shell command")
            let truncated = cmd.count > 32 ? String(cmd.prefix(29)) + "..." : cmd
            return ("RUNNING COMMAND", truncated, nil)

        case "list_dir":
            let dir = args["DirectoryPath"] as? String ?? ""
            let lastDir = (dir as NSString).lastPathComponent
            return ("SCANNING DIR", lastDir.isEmpty ? "Scanning directory" : "Listing \(lastDir)", nil)

        case "grep_search":
            let query = args["Query"] as? String ?? ""
            return ("SEARCHING", query.isEmpty ? "Searching codebase" : "Searching '\(query)'", nil)

        default:
            return ("EXECUTING ACTION", formatEventName(toolName), nil)
        }
    }

    private func formatEventName(_ raw: String) -> String {
        switch raw {
        case "UserInput": return "Thinking & planning..."
        case "RUN_COMMAND", "run_command": return "Running command"
        case "VIEW_FILE", "view_file": return "Reading file"
        case "REPLACE_FILE_CONTENT", "replace_file_content", "WRITE_TO_FILE", "write_to_file": return "Editing code..."
        case "LIST_DIR", "list_dir": return "Scanning directory"
        case "tool_calls", "ToolCall": return "Executing action"
        case "ResponseGenerated": return "Response completed"
        case "WatcherStarted", "Standby": return "Antigravity Ready"
        default: return raw
        }
    }
}
