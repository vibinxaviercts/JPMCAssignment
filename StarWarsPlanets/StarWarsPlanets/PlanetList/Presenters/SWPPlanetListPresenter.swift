//
//  SWPPlanetListPresenter.swift
//  StarWarsPlanets
//
//  Created by Vibin Xavier on 11/06/21.
//

import Foundation
import UIKit

// MARK: - SWPPlanetListPresenterDelegate declaration

protocol SWPPlanetListPresenterDelegate: AnyObject {
    func didFinishPlanetDataFetch(data:[Planet]?)
}

// MARK: - planetListViewPresenterDelegate type declaration
typealias  planetListViewPresenterDelegate = SWPPlanetListPresenterDelegate & UIViewController

// MARK: - SWPPlanetListPresenter Class
class SWPPlanetListPresenter {

// MARK: - SWPPlanetListPresenter properties
    
    //ViewPresenter delgate property to communicate from presenter to view
    weak var viewDelegate : planetListViewPresenterDelegate?
    //Model object to access model methods
    private var model : SWPPlanetListModel?
    
    private let networkMonitor:NetworkMonitor = NetworkMonitor.shared
    
// MARK: - SWPPlanetListPresenter Method implementations
    
    // Method to set the ViewPresenter delegate
    public func setViewDelegate(delegate:planetListViewPresenterDelegate) {
        self.viewDelegate = delegate
        // Model object creation
        model = SWPPlanetListModel()
        // Setting up the PresenterModel delegate for the Model class
        model?.setPresenterModelDelegate(delegate: self)
        
    }
    
    // Method to feth the online Planet data through API
    public func fetchOnlinePlanetData(completionClosure: @escaping (_ responseDict:[Planet]? ) -> ()){
        //syncPlanetData model method invocation to trigger the API call
        model?.syncPlanetData(completionClosure: { error, planetData in
            if let view = self.viewDelegate {//Unwraping the viewdelegate
                //Dismissing the processing alert
                SWPCommon.sharedInstance.processingAlert?.dismiss(animated: true, completion: {
                    if let err = error{
                        //Displaying the error message
                        SWPCommon.sharedInstance.displayAlert(message: err, controller: view) {
                            completionClosure(nil)
                        }
                    }
                    else{
                        if let data = planetData {//Unwraping the fetched data
                            // Fetched data send to viewdelegate through call back method.
                            completionClosure(data)
                        }
                    }
                })
            }
        })
    }
    
    // Method to feth the offline Planet data from coredata
    func fetchOfflinePlanetData(completionClosure: @escaping (_ responseDict:[Planet]? ) -> ()){
        //fetchOfflinePlanetData model method invocation to trigger the coredata fetch request
        model?.fetchOfflinePlanetData(completionClosure: { error, data in
            if let view = self.viewDelegate {//Unwraping the viewdelegate
                //Dismissing the processing alert
                SWPCommon.sharedInstance.processingAlert?.dismiss(animated: true, completion: {
                    if let err = error{
                        //Displaying the error message
                        SWPCommon.sharedInstance.displayAlert(message: err, controller: view) {
                            completionClosure(nil)
                        }
                    }
                    else{
                        if let data = data {//Unwraping the fetched data
                            if data.count == 0{
                                let err = SWPLocalizer.sharedInstance.localizedStringForKey(key: "offlineErr_Msg")
                                SWPCommon.sharedInstance.displayAlert(message: err, controller: view) {
                                    completionClosure(nil)
                                }
                            }else{
                                // Fetched data send to viewdelegate through call back method.
                                completionClosure(data)
                            }
                        }
                    }
                })
            }
        })
    }
    
    // Generic method for the view controller to feth the Planet data
    public func fetchPlanetData(completionClosure: @escaping (_ responseDict:[Planet]? ) -> ()){
        if let view = self.viewDelegate { //unwraping the viewdelegate
            // Invoking the showProcessingAlert for showing the UIactivityIndicator on screen
            SWPCommon.sharedInstance.showProcessingAlert(view)
            //Checks whether the device is connected to the network to trigger the API. If network is not available offline fetch from coredata will be initiated.
            
            if(networkMonitor.isReachable){
                //Online API fetch
                self.fetchOnlinePlanetData { data in
                    completionClosure(data)
                }
            }
            else{
                //Offline API fetch
                self.fetchOfflinePlanetData { data in
                    completionClosure(data)
                }
            }
        }
    }
    
    // Method for triggering the API call from View controller.
    public func reloadPlanetData(completionClosure: @escaping (_ responseDict:[Planet]? ) -> ()){
        if let view = self.viewDelegate {//Unwraping the viewdelegate
            //Checks whether the device is connected to the network to trigger the API.
            if(NetworkMonitor.shared.isReachable){
                // Invoking the showProcessingAlert for showing the UIactivityIndicator on screen
                SWPCommon.sharedInstance.showProcessingAlert(view)
                //Online API fetch
                self.fetchOnlinePlanetData { data in
                    completionClosure(data)
                }
            }else{
                // Displays the network not available message.
                SWPCommon.sharedInstance.displayAlert(message: SWPLocalizer.sharedInstance.localizedStringForKey(key: "noNetwork_Msg"), controller: view) {
                    completionClosure(nil)
                }
                }
        } 
    }
    
    // Method for searching the entered search text from the serach data source.
    public func searchPlanetFromDataSource(source:[Planet], with searchText:String)->[Planet]{
        //If nothing is entered as search text, actual search source will be returned
        guard searchText.trimmingCharacters(in: .whitespaces).count > 0 else{
            return source
        }
        
            //Filtering the search source based on the search text.
        let filteredArray:[Planet] = source.filter { planet in
                if planet.name?.lowercased().range(of:searchText.lowercased()) != nil {
                    return true
                }
                return false
            }
        
        //returning the filtered array.
        return filteredArray
    }
}

// MARK: - SWPPlanetListModelDelegate Method implementations

extension SWPPlanetListPresenter: SWPPlanetListModelDelegate{
    // Delegate call back method for online call from model method.
    func didFinishOnlineDataSync(error: String?, data: [Planet]?) {

    }
    // Delegate call back method for offline call from model method.
    func didFinishOfflineDataSync(error: String?, data: [Planet]?) {

    }
}
