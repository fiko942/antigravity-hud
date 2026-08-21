import Foundation

// MARK: - Global Brain Transcript & Status Watcher
public class BrainWatcher {
    public var onActivityChanged: ((AgentActivity) -> Void)?

    private let brainCandidatePaths: [String] = [
        ("~/.gemini/antigravity-ide/brain" as NSString).expandingTildeInPath,
        ("~/.gemini/antigravity/brain" as NSString).expandingTildeInPath,
        ("~/.gemini/antigravity-cli/brain" as NSString).expandingTildeInPath,
        ("~/.gemini/brain" as NSString).expandingTildeInPath,
        ("~/.antigravity/brain" as NSString).expandingTildeInPath,
        ("~/.config/antigravity/brain" as NSString).expandingTildeInPath
    ]
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
        // Priority 1: Direct status file for manual/fast injection (CLI, Scripts, Hooks)
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

        // Priority 2: Multi-Surface Transcript JSONL Scanning (IDE, 2.0, CLI, Subagents)
        scanLatestTranscriptAcrossAllSurfaces()
    }

    private func updateActivity(state: String, header: String, detail: String, activePath: String?, isAnimated: Bool) {
        if currentActivity.state == state &&
           currentActivity.header == header &&
           currentActivity.detail == detail &&
           currentActivity.activePath == activePath &&
           currentActivity.isAnimated == isAnimated {
            return
        }

        currentActivity = AgentActivity(
            state: state,
            header: header,
            detail: detail,
            activePath: activePath,
            isAnimated: isAnimated
        )
        onActivityChanged?(currentActivity)
    }

    private func scanLatestTranscriptAcrossAllSurfaces() {
        let fileManager = FileManager.default
        var latestFile: String? = nil
        var latestDate: Date = Date.distantPast

        for basePath in brainCandidatePaths {
            guard let entries = try? fileManager.contentsOfDirectory(atPath: basePath) else { continue }
            for entry in entries where !entry.hasPrefix(".") && entry != "tempmediaStorage" {
                let logPath = (basePath as NSString).appendingPathComponent("\(entry)/.system_generated/logs/transcript.jsonl")
                if let attrs = try? fileManager.attributesOfItem(atPath: logPath),
                   let modDate = attrs[.modificationDate] as? Date,
                   modDate > latestDate {
                    latestDate = modDate
                    latestFile = logPath
                }
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
                // Read up to 32KB tail so initial state is instantly captured on launch or session switch
                let readStart: UInt64 = size > 32768 ? size - 32768 : 0
                handle.seek(toFileOffset: readStart)
                let initialData = handle.readDataToEndOfFile()
                currentFileOffset = size
                parseTranscriptData(initialData)
            }
            return
        }

        guard let handle = currentFileHandle,
              let attrs = try? fileManager.attributesOfItem(atPath: logFile),
              let currentSize = attrs[.size] as? UInt64 else { return }

        if currentSize < currentFileOffset {
            // File was truncated or rewritten
            currentFileOffset = 0
        }

        guard currentSize > currentFileOffset else { return }

        handle.seek(toFileOffset: currentFileOffset)
        let data = handle.readDataToEndOfFile()
        currentFileOffset = currentSize
        parseTranscriptData(data)
    }

    private func parseTranscriptData(_ data: Data) {
        guard let content = String(data: data, encoding: .utf8) else { return }
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
                } else if isActionExecutionType(type) {
                    idleTimer?.invalidate()
                    let (actionTitle, defaultDetail) = actionHeaderAndDetail(for: type)
                    let toolSummary = json["tool_summary"] as? String ?? (json["tool_action"] as? String ?? defaultDetail)

                    updateActivity(
                        state: "working",
                        header: "ANTIGRAVITY • \(stepPrefix)\(actionTitle)",
                        detail: toolSummary,
                        activePath: nil,
                        isAnimated: true
                    )
                }
            }
        }
    }

    private func isActionExecutionType(_ type: String) -> Bool {
        let t = type.uppercased()
        return t == "RUN_COMMAND" ||
               t == "GREP_SEARCH" ||
               t == "VIEW_FILE" ||
               t == "REPLACE_FILE_CONTENT" ||
               t == "MULTI_REPLACE_FILE_CONTENT" ||
               t == "WRITE_TO_FILE" ||
               t == "LIST_DIR" ||
               t == "LIST_DIRECTORY" ||
               t == "ASK_QUESTION" ||
               t == "BROWSER_SUBAGENT" ||
               t == "MANAGE_TASK" ||
               t == "READ_URL_CONTENT" ||
               t == "GENERATE_IMAGE" ||
               t == "SCHEDULE" ||
               t == "CODE_ACTION"
    }

    private func actionHeaderAndDetail(for type: String) -> (String, String) {
        switch type.uppercased() {
        case "GREP_SEARCH":
            return ("SEARCHING CODE", "Searching codebase...")
        case "MULTI_REPLACE_FILE_CONTENT", "REPLACE_FILE_CONTENT", "WRITE_TO_FILE", "CODE_ACTION":
            return ("EDITING FILE", "Editing code...")
        case "VIEW_FILE":
            return ("READING FILE", "Reading file...")
        case "RUN_COMMAND":
            return ("RUNNING COMMAND", "Running command...")
        case "LIST_DIR", "LIST_DIRECTORY":
            return ("SCANNING DIR", "Scanning directory...")
        case "ASK_QUESTION":
            return ("ASKING QUESTION", "Waiting for input...")
        case "BROWSER_SUBAGENT":
            return ("BROWSER AGENT", "Automating browser...")
        case "MANAGE_TASK":
            return ("MANAGING TASK", "Managing task...")
        case "READ_URL_CONTENT":
            return ("FETCHING URL", "Fetching web content...")
        case "GENERATE_IMAGE":
            return ("GENERATING IMAGE", "Creating asset...")
        case "SCHEDULE":
            return ("SCHEDULING TIMER", "Timer scheduled...")
        default:
            return ("EXECUTING", formatEventName(type))
        }
    }

    private func parseToolDetails(toolName: String, args: [String: Any]) -> (String, String, String?) {
        var activePath: String? = nil
        let toolAction = args["toolAction"] as? String ?? (args["tool_action"] as? String ?? "")

        switch toolName.lowercased() {
        case "multi_replace_file_content", "replace_file_content", "write_to_file":
            let path = args["TargetFile"] as? String ?? (args["target_file"] as? String ?? "")
            activePath = path.isEmpty ? nil : path
            let filename = (path as NSString).lastPathComponent
            let display = !toolAction.isEmpty ? toolAction : (filename.isEmpty ? "Editing code..." : "Editing \(filename)")
            return ("EDITING FILE", display, activePath)

        case "view_file":
            let path = args["AbsolutePath"] as? String ?? (args["path"] as? String ?? "")
            activePath = path.isEmpty ? nil : path
            let filename = (path as NSString).lastPathComponent
            let display = !toolAction.isEmpty ? toolAction : (filename.isEmpty ? "Reading file..." : "Reading \(filename)")
            return ("READING FILE", display, activePath)

        case "grep_search":
            let query = args["Query"] as? String ?? (args["query"] as? String ?? "")
            let display = !toolAction.isEmpty ? toolAction : (query.isEmpty ? "Searching codebase..." : "Searching '\(query)'")
            return ("SEARCHING CODE", display, nil)

        case "run_command":
            let cmd = args["CommandLine"] as? String ?? (args["command"] as? String ?? "Running shell command")
            let truncated = cmd.count > 32 ? String(cmd.prefix(29)) + "..." : cmd
            let display = !toolAction.isEmpty ? toolAction : truncated
            return ("RUNNING COMMAND", display, nil)

        case "list_dir", "list_directory":
            let dir = args["DirectoryPath"] as? String ?? (args["directory_path"] as? String ?? "")
            let lastDir = (dir as NSString).lastPathComponent
            let display = !toolAction.isEmpty ? toolAction : (lastDir.isEmpty ? "Scanning directory..." : "Listing \(lastDir)")
            return ("SCANNING DIR", display, nil)

        case "ask_question":
            return ("ASKING QUESTION", !toolAction.isEmpty ? toolAction : "Waiting for input...", nil)

        case "browser_subagent":
            return ("BROWSER AGENT", !toolAction.isEmpty ? toolAction : "Automating browser...", nil)

        case "manage_task":
            return ("MANAGING TASK", !toolAction.isEmpty ? toolAction : "Managing background task...", nil)

        case "read_url_content":
            return ("FETCHING URL", !toolAction.isEmpty ? toolAction : "Fetching web content...", nil)

        case "generate_image":
            return ("GENERATING IMAGE", !toolAction.isEmpty ? toolAction : "Creating graphic asset...", nil)

        case "schedule":
            return ("SCHEDULING TIMER", !toolAction.isEmpty ? toolAction : "Setting timer schedule...", nil)

        default:
            let display = !toolAction.isEmpty ? toolAction : formatEventName(toolName)
            return ("EXECUTING ACTION", display, nil)
        }
    }

    private func formatEventName(_ raw: String) -> String {
        switch raw.uppercased() {
        case "USER_INPUT", "USERINPUT":
            return "Thinking & planning..."
        case "RUN_COMMAND":
            return "Running command"
        case "VIEW_FILE":
            return "Reading file"
        case "REPLACE_FILE_CONTENT", "MULTI_REPLACE_FILE_CONTENT", "WRITE_TO_FILE", "CODE_ACTION":
            return "Editing code"
        case "GREP_SEARCH":
            return "Searching codebase"
        case "LIST_DIR", "LIST_DIRECTORY":
            return "Scanning directory"
        case "ASK_QUESTION":
            return "Asking question"
        case "BROWSER_SUBAGENT":
            return "Browser automation"
        case "MANAGE_TASK":
            return "Managing task"
        case "READ_URL_CONTENT":
            return "Fetching web content"
        case "GENERATE_IMAGE":
            return "Generating image"
        case "SCHEDULE":
            return "Timer scheduled"
        case "CHECKPOINT", "CONVERSATION_HISTORY", "KNOWLEDGE_ARTIFACTS", "SYSTEM_MESSAGE":
            return "Processing context"
        case "RESPONSEGENERATED":
            return "Response completed"
        case "WATCHERSTARTED", "STANDBY":
            return "Antigravity Ready"
        default:
            return raw.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }
}
