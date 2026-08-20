import Foundation

// MARK: - Agent Activity Model
public struct AgentActivity {
    public var state: String         // "idle", "thinking", "working", "done"
    public var header: String        // "ANTIGRAVITY • STEP #4 • EDITING CODE"
    public var detail: String        // "src/main.swift"
    public var activePath: String?   // Full path for quick file opening
    public var isAnimated: Bool

    public init(state: String, header: String, detail: String, activePath: String? = nil, isAnimated: Bool = false) {
        self.state = state
        self.header = header
        self.detail = detail
        self.activePath = activePath
        self.isAnimated = isAnimated
    }
}
