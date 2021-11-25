//
//  bookEUITests.swift
//  bookEUITests
//
//  Created by John on 11/10/21.
//

import XCTest

class BookEUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["enable-testing"]
        app.launch()

        }

    func testAppHasFourTabs() throws {
        app.launch()XCTAssertEqual(app.tabBars.buttons.count, 4, "There should be 4 tabs in the app.")

    }
    // swiftlint:disable function_body_length
    func testOpenTabAddsProjects() {
        app.buttons["Open"].tap()
        XCTAssertEqual(app.tables.cells.count, 0, "There should be no list rows initially.")

        for tapCount in 1...5 {
            app.buttons["add"].tap()
            XCTAssertEqual(app.tables.cells.count, tapCount, "There should be \(tapCount) rows(s) in the list.")
        }

        func testAddingItemInsertsRows() {
            app.buttons["Open"].tap()
            XCTAssertEqual(app.tables.cells.count, 0, "There should be no list rows initially.")

            app.buttons["add"].tap()
            XCTAssertEqual(app.tables.cells.count, 1, "There should be 1 list row after adding a project.")

            app.buttons["Add New Item"].tap()
            XCTAssertEqual(app.tables.cells.count, 2, "There should be 2 list rows after adding an item.")
        }

        func testEditingProjectUpdatesCorrectly() {
            app.buttons["Open"].tap()
            XCTAssertEqual(app.tables.cells.count, 0, "There should be no list rows initially.")

            app.buttons["add"].tap()
            XCTAssertEqual(app.tables.cells.count, 1, "There should be 1 list row after adding a project.")

            app.buttons["NEW PROJECT"].tap()
            app.textFields["Project name"].tap()

            app.keys["space"].tap()
            app.keys["more"].tap()
            app.keys["2"].tap()
            app.buttons["Return"].tap()

            app.buttons["Open Projects"].tap()

            XCTAssertTrue(app.buttons["NEW PROJECT 2"].exists, "The new project name should be visible in the list.")
        }

        func testEditingItemUpdatesCorrectly() {

            // Go to Open Projects and add one project and one item.
            testAddingItemInsertsRows()

            app.buttons["New Item"].tap()
            app.textFields["Item name"].tap()
            app.keys["space"].tap()
            app.keys["more"].tap()
            app.keys["2"].tap()
            app.buttons["Return"].tap()

            app.buttons["Open Projects"].tap()

            XCTAssertTrue(app.buttons["New Item 2"].exists, "The new item name should be visible in the list.")
        }

        func testAllAwardsShowLockedAlert() {
            app.buttons["Awards"].tap()

            for award in app.scrollViews.buttons.allElementsBoundByIndex {
                award.tap()
                XCTAssertTrue(app.alerts["Locked"].exists, "There should be a Locked alert showing for awards.")
                app.buttons["OK"].tap()
            }
        }
    }

//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}
