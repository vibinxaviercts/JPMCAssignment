//
//  SWPPlanetListModel.swift
//  StarWarsPlanets
//
//  Created by Vibin Xavier on 11/06/21.
//

import Foundation

// MARK: - SWPPlanet

struct SWPPlanet : Decodable {
    let name:String?
    let terrain:String?
    let rotationPeriod:String?
    let climate:String?
    let gravity: String?
    let url:String?
    let population:String?
    let surfaceWater:String?
    let created:String?
    let edited:String?
    let orbitalPeriod:String?
    let diameter:String?
    let films:[String]?
    let residents:[String]?
    
    // Method to create the Planet Entity Object
    func createPLanetManagedObject() -> Planet {
        let planet = Planet(context: SWPCoreDataManager.sharedInstance.moContext)
        planet.name = self.name
        planet.terrain = self.terrain
        planet.rotationperiod = self.rotationPeriod
        planet.climate = self.climate
        planet.gravity = self.gravity
        planet.url = self.url
        planet.population = self.population
        planet.surfacewater = self.surfaceWater
        planet.created = self.created
        planet.edited = self.edited
        planet.orbitalperiod = self.orbitalPeriod
        planet.diameter = self.diameter
        if let films = self.films{
            for filmUrl in films{
                //Film Entity creation
                let film = Film(context: SWPCoreDataManager.sharedInstance.moContext)
                film.url = filmUrl
                // Added to the "films" relationship of the Planet object. This can be accessed as an array of "Film" entities from created Planet.
                planet.addToFilms(film)
            }
        }
        if let residents = self.residents{
            for residentUrl in residents{
                //Film Entity creation
                let resident = Resident(context: SWPCoreDataManager.sharedInstance.moContext)
                resident.url = residentUrl
                // Added to the "films" relationship of the Planet object. This can be accessed as an array of "Film" entities from created Planet.
                planet.addToResidents(resident)
            }
        }
        return planet
    }
}


// MARK: - SWPPlanetListModelDelegate

protocol SWPPlanetListModelDelegate : AnyObject{
    func didFinishOnlineDataSync(error: String?, data:[Planet]?)
    func didFinishOfflineDataSync(error: String?, data:[Planet]?)
}

// MARK: - SWPPlanetListModel Class

class SWPPlanetListModel: NSObject {
    
    // MARK: - SWPPlanetListModel properties
    
    // Model delegate to communicate back to presenter
    weak var modelDelegate : SWPPlanetListModelDelegate?
    
    // MARK: - SWPPlanetListModel private methods
    
    // Method to parse the "results" node from the API JSON response.
    private func parsePlanetListData(resultArray: AnyObject, completionClosure: @escaping (_ error:String?,_ items:[Planet]?) -> ()){
        
        //Empty array for keeping the Planet objects
        var itemArr:[Planet] = [Planet]()
        
        if let dataArray = resultArray as? Array<Dictionary<String, AnyObject>>{//Unwrapping the response array
            
            for data in dataArray{
                // Invoking the method to create the Planet coredata entity object.
                self.createPlanetDataModelWithData(data: data) { error, planet in
                    if let error = error { //In case of any error
                        completionClosure(error, nil) //returns the error
                        return
                    }else{
                        if let planet = planet{
                            itemArr.append(planet)//Created Planet objects get appended in the itemArr to return
                        }
                    }
                }
            }
            completionClosure(nil, itemArr)//returns the Planet objects in itemArr with no error.
        }
        else{//If the response array cann't unwrapped, returns the error
            completionClosure(SWPLocalizer.sharedInstance.localizedStringForKey(key: "parseErr_Msg"), nil)
        }
    }
    
    // Method to create the coredata object for Planet entity.
    private func createPlanetDataModelWithData(data:[String:AnyObject], completionClosure: @escaping (_ error:String?,_ planet:Planet?) -> ()){
        
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: data,
            options: []) {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let planetObj: SWPPlanet = try! decoder.decode(SWPPlanet.self, from: theJSONData)
            let planet = planetObj.createPLanetManagedObject()
            completionClosure(nil, planet)
        }
        else{
            //If the response array object cann't unwrapped, returns the error
            completionClosure(SWPLocalizer.sharedInstance.localizedStringForKey(key: "parseErr_Msg"), nil)
        }
    }
    
    // MARK: - SWPPlanetListModel Public methods
    
    // Method to set the  PresenterModel Delegate to communicate from model to presenter
    func setPresenterModelDelegate(delegate: SWPPlanetListModelDelegate){
        self.modelDelegate = delegate
    }
    // Method to invoking the online API call
    func syncPlanetData(completionClosure: @escaping (_ error:String?, _ responseDict:[Planet]? ) -> ()){
        // webservice manager initialization
        let serviceManager = SWPWebServiceManager()
        
        //invoking the API call
        serviceManager.invokeService(methodName: SWPWebServiceConstants.serviceName.getPlanetList,methodType: SWPWebServiceConstants.HTTPMethods.httpMethodGet) { error, jsonArray, jsonDict in
            if let error = error {//In case of any error, call back will be triggered to model delagete with error details.
                completionClosure(error,nil)            }
            else{
                if let resultDict = jsonDict?["results"]{// "results" json node will be unwrapped to get the planet data from response json dictionary.
                    //Invoking the method to parse the unwrapped response data.
                    self.parsePlanetListData(resultArray: resultDict, completionClosure:{ (error, items) in
                        if let error = error {
                            //In case of any error, call back will be triggered to model delagete with error details.
                            completionClosure(error,nil)
                        }
                        else{
                            //Clearing the whole SQLite DB, by nullifying the relations.
                            SWPCoreDataManager.sharedInstance.resetModel(model: "Planet")
                            //Saves the newly created Planet Entity objects in the coredata context.
                            SWPCoreDataManager.sharedInstance.saveContext()
                            // Sorting the created objects array to return.
                            let sortedItems = items?.sorted(by: { $0.name?.compare($1.name!) == .orderedAscending
                            })
                            //Returning the sorted object array through modelDelegate callback methods.
                            //Storing the online sync time in userdefaults
                            SWPCommon.sharedInstance.updateLastSync()
                            
                            completionClosure(nil,sortedItems)
                        }
                    })
                }
            }
        }
    }
    
    // Method to fetch the Planet entity objects from coredata
    func fetchOfflinePlanetData(completionClosure: @escaping (_ error:String?, _ responseDict:[Planet]? ) -> ()){
        do {
            if let fetchResults = try SWPCoreDataManager.sharedInstance.moContext.fetch(Planet.fetchRequest())  as? [Planet] {//Fetching and unwrapping the results set from coredata.
                
                //Sorting the fetched objects.
                let sortedItems = fetchResults.sorted(by: { $0.name?.compare($1.name!) == .orderedAscending
                })
                //returning the sorted objects.
                completionClosure(nil,sortedItems)
            }
            
        } catch{//In case of any error, call back will be triggered to model delagete with error details.
            let err = SWPLocalizer.sharedInstance.localizedStringForKey(key: "offlineErr_Msg")
            completionClosure(err,nil)
        }
    }
}
