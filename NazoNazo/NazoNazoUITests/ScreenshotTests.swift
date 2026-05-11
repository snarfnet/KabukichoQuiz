import XCTest

final class ScreenshotTests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    func testTakeScreenshots() throws {
        sleep(3)

        let attachment1 = XCTAttachment(screenshot: app.screenshot())
        attachment1.name = "01_home"
        attachment1.lifetime = .keepAlways
        add(attachment1)

        // Tap first character (りりあ) - try multiple methods
        let firstChar = app.buttons["りりあ"]
        if firstChar.waitForExistence(timeout: 5) {
            firstChar.tap()
        } else {
            // Fallback: tap first enabled button in the character area
            let buttons = app.buttons.allElementsBoundByIndex
            for button in buttons {
                if button.isEnabled && button.frame.minY > 200 {
                    button.tap()
                    break
                }
            }
        }
        sleep(2)

        let attachment2 = XCTAttachment(screenshot: app.screenshot())
        attachment2.name = "02_greeting"
        attachment2.lifetime = .keepAlways
        add(attachment2)

        // Tap start button
        let startBtn = app.buttons["クイズを始める"]
        if startBtn.waitForExistence(timeout: 5) {
            startBtn.tap()
            sleep(10) // Wait for API + translation

            let attachment3 = XCTAttachment(screenshot: app.screenshot())
            attachment3.name = "03_quiz"
            attachment3.lifetime = .keepAlways
            add(attachment3)

            // Try tapping any answer button
            sleep(2)
            let allButtons = app.buttons.allElementsBoundByIndex
            for button in allButtons {
                let frame = button.frame
                if frame.minY > 400 && frame.height > 30 && frame.width > 200 {
                    button.tap()
                    sleep(1)
                    break
                }
            }

            let attachment4 = XCTAttachment(screenshot: app.screenshot())
            attachment4.name = "04_answered"
            attachment4.lifetime = .keepAlways
            add(attachment4)
        }
    }
}
