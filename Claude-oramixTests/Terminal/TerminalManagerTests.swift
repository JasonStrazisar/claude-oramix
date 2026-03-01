import XCTest
@testable import Claude_oramix

final class TerminalManagerTests: XCTestCase {

    private var sut: TerminalManager!

    override func setUp() {
        super.setUp()
        sut = TerminalManager()
    }

    override func tearDown() {
        sut.terminate()
        sut = nil
        super.tearDown()
    }

    // MARK: - Cycle 1: État initial

    func testInitialState_isRunningFalse() {
        XCTAssertFalse(sut.isRunning)
    }

    func testInitialState_outputEmpty() {
        XCTAssertEqual(sut.output, "")
    }

    // MARK: - Cycle 2: terminate() remet isRunning à false

    func testTerminate_setsIsRunningFalse() {
        sut.isRunning = true
        sut.terminate()
        XCTAssertFalse(sut.isRunning)
    }

    // MARK: - Cycle 3: send() est no-op si isRunning == false

    func testSend_whenNotRunning_doesNotCrash() {
        XCTAssertFalse(sut.isRunning)
        sut.send("hello")
    }
}
