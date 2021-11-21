//
//  PerformanceTests.swift
//  bookETests
//
//  Created by John on 11/21/21.
//

import XCTest
@testable import bookE

class PerformanceTests: BaseTestCase {
    
    func testAwardCalculationPerformance() throws {
        for _ in 1...100 {
            try dataController.createSampleData()
        }
        
        let awards = Array(repeating: Award.allAwards, count: 25).joined()
        XCTAssertEqual(awards.count, 500, "This checks the awards count is constant. Change this if you add awards.")
        
        measure {
            _ = awards.filter(dataController.hasEarned).count
        }
    }
}
