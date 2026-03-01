import Foundation

// MARK: - PTYProcess

private struct PTYProcess {
    let process: Process
    let inputPipe: Pipe
    let outputPipe: Pipe

    static func make(command: String) -> PTYProcess {
        let process = Process()
        let inputPipe = Pipe()
        let outputPipe = Pipe()

        process.executableURL = URL(fileURLWithPath: "/bin/sh")
        process.arguments = ["-c", command]
        process.standardInput = inputPipe
        process.standardOutput = outputPipe
        process.standardError = outputPipe

        return PTYProcess(process: process, inputPipe: inputPipe, outputPipe: outputPipe)
    }
}

// MARK: - TerminalManager

final class TerminalManager: ObservableObject {

    // MARK: - Published State

    @Published var isRunning: Bool = false
    @Published private(set) var output: String = ""

    // MARK: - Private Properties

    private var ptyProcess: PTYProcess?
    private let queue = DispatchQueue(label: "TerminalManager.io", qos: .userInitiated)

    // MARK: - Public API

    func spawn(command: String) {
        terminate()

        let pty = PTYProcess.make(command: command)
        ptyProcess = pty

        pty.outputPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            guard !data.isEmpty, let text = String(data: data, encoding: .utf8) else { return }
            DispatchQueue.main.async {
                self?.output += text
            }
        }

        pty.process.terminationHandler = { [weak self] _ in
            DispatchQueue.main.async {
                self?.isRunning = false
                self?.ptyProcess = nil
            }
        }

        do {
            try pty.process.run()
            DispatchQueue.main.async {
                self.isRunning = true
            }
        } catch {
            ptyProcess = nil
        }
    }

    func send(_ text: String) {
        guard isRunning, let pty = ptyProcess else { return }
        guard let data = text.data(using: .utf8) else { return }
        queue.async {
            pty.inputPipe.fileHandleForWriting.write(data)
        }
    }

    func terminate() {
        if let pty = ptyProcess, pty.process.isRunning {
            pty.process.terminate()
            pty.outputPipe.fileHandleForReading.readabilityHandler = nil
        }
        ptyProcess = nil
        isRunning = false
    }
}
