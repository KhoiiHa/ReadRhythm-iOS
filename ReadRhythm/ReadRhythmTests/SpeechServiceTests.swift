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

    func testSpeak_WhenInvoked_ThenCanBeStoppedSafely() {
        let service = SpeechService.shared
        service.stop()

        service.speak("Test text", language: "en-US")
        service.stop()
        service.stop()

        XCTAssertNotNil(service.synthesizer)
    }

    func testStop_WhenCalledAfterSpeak_ThenSynthesizerStops() {
        let service = SpeechService.shared
        service.stop()

        let speakingExpectation = expectation(description: "Synthesizer started")
        service.speak("Stopping soon", language: "en-US")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            speakingExpectation.fulfill()
        }

        wait(for: [speakingExpectation], timeout: 2.0)

        service.stop()

        waitUntilSynthesizerStops(service)
    }

    private func waitUntilSynthesizerStops(
        _ service: SpeechService,
        timeout: TimeInterval = 2.0,
        pollInterval: TimeInterval = 0.05
    ) {
        let stoppedExpectation = expectation(description: "Synthesizer stopped")
        var isFulfilled = false

        func poll() {
            guard isFulfilled == false else { return }

            if service.synthesizer.isSpeaking == false {
                isFulfilled = true
                stoppedExpectation.fulfill()
                return
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + pollInterval) {
                poll()
            }
        }

        poll()
        wait(for: [stoppedExpectation], timeout: timeout)
    }
}
