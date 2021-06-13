//
//  SWPPlanetListPresenterTest.swift
//  StarWarsPlanetsTests
//
//  Created by Vibin Xavier on 13/06/21.
//

import XCTest
@testable import StarWarsPlanets

class SWPPlanetListPresenterTest: XCTestCase {
    
    var sut:SWPPlanetListPresenter!
    var networkManager:NetworkMonitor!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        sut = SWPPlanetListPresenter()
        networkManager = NetworkMonitor.shared
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        try super.tearDownWithError()
    }

    func testViewPresenterDelegateIsSet(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController =  storyboard.instantiateViewController(withIdentifier: "SWPPlanetListViewController") as? SWPPlanetListViewController
        viewController?.loadViewIfNeeded()
        sut.setViewDelegate(delegate: viewController!)
        XCTAssertNotNil(sut.viewDelegate)
    }
    
    func testOfflinePlanetDataFetch(){
        let promise = expectation(description: "Succeessfully fetched the online data")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController =  storyboard.instantiateViewController(withIdentifier: "SWPPlanetListViewController") as? SWPPlanetListViewController
        viewController?.loadViewIfNeeded()
        sut.setViewDelegate(delegate: viewController!)
        sut.fetchOfflinePlanetData(completionClosure: { data in
            XCTAssertTrue(data!.count > 0)
            promise.fulfill()
        })
        wait(for: [promise], timeout: 1)

    }
    
    func testOnlinePlanetDataFetch() throws {
        try XCTSkipUnless(networkManager.isReachable,
          "Network connectivity is required for this test.")
        let promise1 = expectation(description: "Succeessfully fetched the online data")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController =  storyboard.instantiateViewController(withIdentifier: "SWPPlanetListViewController") as? SWPPlanetListViewController
        viewController?.loadViewIfNeeded()
        sut.setViewDelegate(delegate: viewController!)
        sut.fetchOnlinePlanetData(completionClosure: { data in
            XCTAssertTrue(data!.count > 0)
            promise1.fulfill()
        })
        wait(for: [promise1], timeout: 15)
    }
    
    func testSearchTextFromDataSource(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController =  storyboard.instantiateViewController(withIdentifier: "SWPPlanetListViewController") as? SWPPlanetListViewController
        viewController?.loadViewIfNeeded()
        sut.setViewDelegate(delegate: viewController!)
        let filteredArr = sut.searchPlanetFromDataSource(source: viewController!.searchSource, with: "Al")
        XCTAssertTrue(filteredArr.count >= 0)
    }
    
    func testReloadOnlinePlanetDataFetch() throws {
        try XCTSkipUnless(networkManager.isReachable,
          "Network connectivity is required for this test.")
        let promise2 = expectation(description: "Succeessfully fetched the online data")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController =  storyboard.instantiateViewController(withIdentifier: "SWPPlanetListViewController") as? SWPPlanetListViewController
        viewController?.loadViewIfNeeded()
        sut.setViewDelegate(delegate: viewController!)
        sut.reloadPlanetData(completionClosure: { data in
            XCTAssertTrue(data!.count > 0)
            promise2.fulfill()
        })
        wait(for: [promise2], timeout: 15)
    }
    
    
}
