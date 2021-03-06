//
//  bookEUnitTests.swift
//  bookEUnitTests
//
//  Created by John on 11/20/21.
//

import CoreData

import XCTest
@testable import bookE

class BaseTestCase: XCTestCase {
    var dataController: DataController!
    var managedObjectContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        dataController = DataController(inMemory: true)
        managedObjectContext = dataController.container.viewContext
    }
}
