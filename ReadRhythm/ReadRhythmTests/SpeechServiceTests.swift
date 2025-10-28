import XCTest
@testable import ReadRhythm

@MainActor
final class SpeechServiceTests: XCTestCase {
    override func tearDownWithError() throws {
        SpeechService.shared.stop()
    }

    func testSharedInstance_WhenAccessedTwice_ThenReturnsSameObject() {
        let first = SpeechService.shared
        let second = SpeechService.shared

        XCTAssertTrue(first === second)
    }

    func testSpeak_WhenInvoked_ThenSynthesizerStartsSpeaking() {
        let service = SpeechService.shared
        service.stop()

        let speakingExpectation = expectation(description: "Synthesizer should start speaking")

        service.speak("Test text", language: "en-US")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if service.synthesizer.isSpeaking {
                speakingExpectation.fulfill()
            }
        }

        wait(for: [speakingExpectation], timeout: 2.0)
    }

    func testStop_WhenCalledAfterSpeak_ThenSynthesizerStops() {
        let service = SpeechService.shared
        service.stop()

        service.speak("Stopping soon", language: "en-US")
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
        XCTAssertTrue(service.synthesizer.isSpeaking)

        XCTAssertNoThrow(service.stop())
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
        XCTAssertFalse(service.synthesizer.isSpeaking)
    }
}
