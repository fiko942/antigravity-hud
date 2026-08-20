import Cocoa

// MARK: - Single Instance Kernel Mutex
public func ensureSingleInstance() -> Bool {
    let lockPath = "/tmp/antigravity-hud.lock"
    let fd = open(lockPath, O_CREAT | O_WRONLY, 0o644)
    if fd < 0 { return false }
    if flock(fd, LOCK_EX | LOCK_NB) != 0 {
        return false // Another instance is already running
    }
    return true
}
