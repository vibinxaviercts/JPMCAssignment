//
//  SWPPlanetListModelTest.swift
//  StarWarsPlanetsTests
//
//  Created by Vibin Xavier on 12/06/21.
//

import XCTest
@testable import StarWarsPlanets

class SWPPlanetListModelTest: XCTestCase {
    
    var sut:SWPPlanetListModel!
    var networkManager:NetworkMonitor!
    

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        sut = SWPPlanetListModel()
        networkManager = NetworkMonitor.shared
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        networkManager = nil
        try super.tearDownWithError()
    }
    
    func testPresenterModelDelegateIsSet(){
        let presenter = SWPPlanetListPresenter()
        sut.setPresenterModelDelegate(delegate: presenter)
        XCTAssertNotNil(sut.modelDelegate)
    }
    
    func testOfflineDatafetch() throws{
        try XCTSkipUnless(SWPCommon.sharedInstance.checkLastSync(),
          "No offline data available for this test.")
        let presenter = SWPPlanetListPresenter()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view  = storyboard.instantiateViewController(withIdentifier: "SWPPlanetListViewController") as? SWPPlanetListViewController
                view?.loadViewIfNeeded()
        let promise = expectation(description: "Succeessfully fetched the online data")
        presenter.setViewDelegate(delegate: view! as planetListViewPresenterDelegate)
        sut.setPresenterModelDelegate(delegate: presenter)
        sut.fetchOfflinePlanetData { err, data in
            XCTAssertTrue(data!.count > 0)
            promise.fulfill()
        }
        wait(for: [promise], timeout: 1)
    }
    
    func testOnlineDataFetch() throws{
        try XCTSkipUnless(networkManager.isReachable,
          "Network connectivity is required for this test.")
        let presenter = SWPPlanetListPresenter()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view  = storyboard.instantiateViewController(withIdentifier: "SWPPlanetListViewController") as? SWPPlanetListViewController
                view?.loadViewIfNeeded()
        let promise1 = expectation(description: "Succeessfully fetched the online planet data")
        presenter.setViewDelegate(delegate: view! as planetListViewPresenterDelegate)
        sut.setPresenterModelDelegate(delegate: presenter)
        sut.syncPlanetData { error, data in
            XCTAssertTrue(data!.count > 0)
            promise1.fulfill()
        }
        wait(for: [promise1], timeout: 15)
    }
}
