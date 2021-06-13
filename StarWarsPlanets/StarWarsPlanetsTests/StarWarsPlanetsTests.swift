//
//  StarWarsPlanetsTests.swift
//  StarWarsPlanetsTests
//
//  Created by Vibin Xavier on 11/06/21.
//

import XCTest
@testable import StarWarsPlanets

class StarWarsPlanetsTests: XCTestCase {
    
    var sut:SWPPlanetListViewController!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        sut = SWPPlanetListViewController()
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        try super.tearDownWithError()
    }

    func testViewDidLoad(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut =  storyboard.instantiateViewController(withIdentifier: "SWPPlanetListViewController") as? SWPPlanetListViewController
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isViewLoaded)
    }

}
