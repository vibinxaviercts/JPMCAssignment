//
//  SWPCommon.swift
//  StarWarsPlanets
//
//  Created by Vibin Xavier on 11/06/21.
//

import Foundation
import UIKit

// MARK: - SWPCommon implementation
class SWPCommon: NSObject {
    
    // Sigleton shared instance propert.
    static let sharedInstance:SWPCommon = {
        let instance = SWPCommon()
        return instance
    }()
    // processingAlert declaration.
    var processingAlert:UIAlertController? = nil
    
    // showProcessingAlert Implemetation.
    func showProcessingAlert(_ controller:UIViewController) {
        
        //create an alert controller
        let anAlert = UIAlertController(title: SWPLocalizer.sharedInstance.localizedStringForKey(key: "App Name"), message: "\n\n\n", preferredStyle: .alert)
        
        //create an activity indicator
        let indicator = UIActivityIndicatorView(frame: anAlert.view.frame)
        indicator.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        indicator.color = UIColor.gray
        //add the activity indicator as a subview of the alert controller's view
        
        indicator.isUserInteractionEnabled = false // required otherwise if there buttons in the UIAlertController you will not be able to press them
        indicator.startAnimating()
        anAlert.view.addSubview(indicator)
        controller.present(anAlert, animated: true, completion: nil)
        
        self.processingAlert = anAlert
    }
    
    // dismissAlert Implemetation.
    func dismissAlert() {
        self.processingAlert?.dismiss(animated: true, completion: nil)
        self.processingAlert = nil
    }
    
    // displayAlert Implemetation.
    func displayAlert(message:String, controller:UIViewController, completionClosure: @escaping () -> ()?) {
        
        let alert = UIAlertController(title: SWPLocalizer.sharedInstance.localizedStringForKey(key: "App Name"), message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: SWPLocalizer.sharedInstance.localizedStringForKey(key: "Ok"), style: .default, handler: { (action) in
            completionClosure()
        }))
        
        controller.present(alert, animated: true, completion: nil)
    }
    
    func updateLastSync() {
        let timeInterval = NSDate().timeIntervalSince1970
        UserDefaults.standard.set(timeInterval, forKey: "syncTime")
    }
    
    // checkLastSync Implemetation.
    func checkLastSync()->Bool {
        var result:Bool = false
        if let _ = UserDefaults.standard.value(forKey: "syncTime") {
            result = true
        }
        return result
    }
}
// MARK: - SWPLocalizer implementation
class SWPLocalizer{
    
    var mainBundle:Bundle = Bundle()
    
    // Sigleton shared instance propert.
    static let sharedInstance:SWPLocalizer = {
        let instance = SWPLocalizer()
        return instance
    }()
    
    init() {
        mainBundle = Bundle.main
    }
    
    // Method to localize string
    func localizedStringForKey(key:String) -> String {
        return mainBundle.localizedString(forKey: key as String, value: "", table: "StarWarsPlanets")
    }
}
