//
//  AssetTests.swift
//  bookETests
//
//  Created by John on 11/15/21.
//

import XCTest
@testable import bookE

class AssetTests: XCTestCase {

    func testColorsExist() {
        for color in Project.colors {
            XCTAssertNotNil(UIColor(named: color), "Failed to load color '\(color)' from asset catalog.")
        }
    }

    func testJSONLoadsCorrectly() {
        XCTAssertTrue(Award.allAwards.isEmpty == false, "Failed to load awards from JSON.")
    }
}
