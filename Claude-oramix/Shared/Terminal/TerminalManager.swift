import Foundation
import Darwin

// MARK: - TerminalManager

final class TerminalManager: ObservableObject {

    // MARK: - Published State

    @Published var isRunning: Bool = false
    @Published private(set) var output: String = ""

    // MARK: - Private Properties

    private var process: Process?
    private var masterFD: Int32 = -1
    private var readSource: DispatchSourceRead?
    private let queue = DispatchQueue(label: "TerminalManager.io", qos: .userInitiated)

    // MARK: - Public API

    func spawn(command: String) {
        terminate()

        guard let (master, slave) = openPTY() else { return }
        masterFD = master

        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/bin/sh")
        p.arguments = ["-c", command]

        var env = ProcessInfo.processInfo.environment
        env["TERM"] = "xterm-256color"
        env["COLUMNS"] = "220"
        env["LINES"] = "50"
        p.environment = env

        // Give the child process the slave end as its terminal
        let slaveHandle = FileHandle(fileDescriptor: slave, closeOnDealloc: false)
        p.standardInput = slaveHandle
        p.standardOutput = slaveHandle
        p.standardError = slaveHandle

        p.terminationHandler = { [weak self] _ in
            DispatchQueue.main.async {
                self?.isRunning = false
                self?.process = nil
            }
        }

        // Read output from master end
        let src = DispatchSource.makeReadSource(fileDescriptor: master, queue: queue)
        src.setEventHandler { [weak self] in
            guard let self else { return }
            var buf = [UInt8](repeating: 0, count: 4096)
            let n = read(master, &buf, buf.count)
            guard n > 0 else { return }
            let raw = String(bytes: buf.prefix(n), encoding: .utf8) ?? ""
            let clean = stripANSI(raw)
            DispatchQueue.main.async { self.output += clean }
        }
        src.setCancelHandler { close(master) }
        src.resume()
        readSource = src

        do {
            try p.run()
            // Close slave in parent after fork — child has its own copy via dup2
            close(slave)
            process = p
            DispatchQueue.main.async { self.isRunning = true }
        } catch {
            src.cancel()
            close(slave)
            masterFD = -1
        }
    }

    func send(_ text: String) {
        guard isRunning, masterFD != -1 else { return }
        guard let data = text.data(using: .utf8) else { return }
        let fd = masterFD
        queue.async {
            data.withUnsafeBytes { ptr in
                _ = write(fd, ptr.baseAddress!, ptr.count)
            }
        }
    }

    func terminate() {
        readSource?.cancel()
        readSource = nil
        process?.terminate()
        process = nil
        masterFD = -1
        isRunning = false
    }

    // MARK: - PTY helpers

    private func openPTY() -> (master: Int32, slave: Int32)? {
        let master = posix_openpt(O_RDWR | O_NOCTTY)
        guard master != -1 else { return nil }
        guard grantpt(master) == 0, unlockpt(master) == 0 else {
            close(master)
            return nil
        }
        guard let slaveNameC = ptsname(master) else {
            close(master)
            return nil
        }
        let slave = open(slaveNameC, O_RDWR)
        guard slave != -1 else {
            close(master)
            return nil
        }
        return (master, slave)
    }

    // MARK: - ANSI stripping

    private func stripANSI(_ string: String) -> String {
        // Remove ESC sequences: ESC [ ... m  and  ESC ] ... BEL/ST and  ESC char
        var result = string
        // CSI sequences: ESC [ ... (any non-letter)* letter
        while let range = result.range(of: #"\u{1B}\[[0-9;?]*[A-Za-z]"#, options: .regularExpression) {
            result.removeSubrange(range)
        }
        // OSC sequences: ESC ] ... BEL or ESC \
        while let range = result.range(of: #"\u{1B}\].*?(?:\u{07}|\u{1B}\\)"#, options: .regularExpression) {
            result.removeSubrange(range)
        }
        // Lone ESC + single char
        while let range = result.range(of: #"\u{1B}."#, options: .regularExpression) {
            result.removeSubrange(range)
        }
        return result
    }
}
