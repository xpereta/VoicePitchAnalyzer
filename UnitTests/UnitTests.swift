//
//  UnitTests.swift
//  UnitTests
//
//  Created by David Seek on 4/25/20.
//  Copyright © 2020 Carola Nitz. All rights reserved.
//

import XCTest
@testable import Voice_Pitch_Analyzer

class UnitTests: XCTestCase {

    private let databaseManager = DatabaseManager()

    override func setUpWithError() throws {

        // Configure to auth a user
        databaseManager.configure()
    }

    override func tearDownWithError() throws {
        // Put teardown code here.
    }

    func test_authID() throws {

        // Create an async expectation
        let expectation = self.expectation(description: "FIRAuth")

        var userIdentifier: String?
        databaseManager.setAuthObserver { identifier in

            userIdentifier = identifier
            // Fullfil the expectation to let the test runner
            // know that it's OK to proceed
            expectation.fulfill()
        }

        // Wait for the expectation to be fullfilled, or time out
        // after 5 seconds. This is where the test runner will pause.
        waitForExpectations(timeout: 5, handler: nil)

        var vendorID = self.databaseManager.getVendorID() ?? ""
        vendorID = vendorID.lowercased()
        XCTAssertEqual("\(vendorID)@voicepitchanalyzer.app", userIdentifier)
    }
}
