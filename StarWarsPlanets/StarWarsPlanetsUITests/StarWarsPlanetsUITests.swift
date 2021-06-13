//
//  StarWarsPlanetsUITests.swift
//  StarWarsPlanetsUITests
//
//  Created by Vibin Xavier on 11/06/21.
//

import XCTest

class StarWarsPlanetsUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
      try super.setUpWithError()
      continueAfterFailure = false

      app = XCUIApplication()
      app.launch()
    }

}
