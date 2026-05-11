import XCTest

final class ScreenshotTests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    func testTakeScreenshots() throws {
        let attachment1 = XCTAttachment(screenshot: app.screenshot())
        attachment1.name = "01_home"
        attachment1.lifetime = .keepAlways
        add(attachment1)

        sleep(2)

        // Tap first character (りりあ)
        let firstChar = app.buttons.matching(identifier: "りりあ").firstMatch
        if firstChar.waitForExistence(timeout: 5) {
            firstChar.tap()
            sleep(1)

            let attachment2 = XCTAttachment(screenshot: app.screenshot())
            attachment2.name = "02_greeting"
            attachment2.lifetime = .keepAlways
            add(attachment2)

            // Tap start button
            let startBtn = app.buttons["クイズを始める"]
            if startBtn.waitForExistence(timeout: 5) {
                startBtn.tap()
                sleep(8) // Wait for API + translation

                let attachment3 = XCTAttachment(screenshot: app.screenshot())
                attachment3.name = "03_quiz"
                attachment3.lifetime = .keepAlways
                add(attachment3)

                // Tap first answer
                sleep(2)
                let answers = app.buttons.allElementsBoundByIndex.filter {
                    $0.frame.minY > 400 && $0.frame.height > 40 && $0.frame.height < 120
                }
                if let firstAnswer = answers.first {
                    firstAnswer.tap()
                    sleep(1)

                    let attachment4 = XCTAttachment(screenshot: app.screenshot())
                    attachment4.name = "04_answered"
                    attachment4.lifetime = .keepAlways
                    add(attachment4)
                }
            }
        }
    }
}
