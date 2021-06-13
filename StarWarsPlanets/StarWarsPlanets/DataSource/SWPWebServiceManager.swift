//
//  SWPWebServiceManager.swift
//  StarWarsPlanets
//
//  Created by Vibin Xavier on 11/06/21.
//

import Foundation
import UIKit

// MARK: - SWPWebServiceManager implementation
class SWPWebServiceManager: NSObject {
    
    // completionClosure property to handle URLSession delegate methods
    var completionClosure: ((_ error:String?) -> Void)? = nil
    
    //Default URLSession property
    private lazy var defaultSession: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "SWPSession")
        config.isDiscretionary = true
        config.sessionSendsLaunchEvents = true
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    func invokeService(methodName:String,parameters:[String:AnyObject]? = nil, jsonDict:[String:AnyObject]? = nil, jsonArray:[[String:AnyObject]]? = nil, methodType:String? = nil, returnsDict:Bool = true, isCleanURL:Bool? = false, completionClosure: @escaping (_ error:String?, _ responseArray:[Any]?, _ responseDict:[String:AnyObject]? ) -> ()) {
    
        // Setup the request with URL
        var urlString:String? = SWPWebServiceConstants.hostUrl.baseUrl + methodName
        
        if isCleanURL != nil {
            if parameters != nil {
                let params = parameters?.cleanURLStringFromHttpParameters()
                urlString = urlString! + "/\(params ?? "")"
            }
        }else {
            if parameters != nil {
                let params = parameters?.stringFromHttpParameters()
                urlString = urlString! + "?\(params ?? "")"
            }
        }
        //Initializing the URL object
        let baseUrl:URL = URL.init(string: urlString!)!
        
        //Initializing the URLRequest object
        var urlRequest = URLRequest(url: baseUrl, cachePolicy: .reloadIgnoringCacheData)
        
        if jsonDict != nil {
            var jsonData = Data()
            // Convert POST string parameters to data using UTF8 Encoding
            do {
                jsonData = try JSONSerialization.data(withJSONObject: jsonDict as Any, options: .prettyPrinted)
                
            } catch {
                completionClosure(error.localizedDescription, nil, nil)
                return
            }
            urlRequest.httpBody = jsonData
        }
        else {
            if jsonArray != nil {
                var jsonData = Data()
                
                // Convert POST string parameters to data using UTF8 Encoding
                do {
                    jsonData = try JSONSerialization.data(withJSONObject: jsonArray as Any, options: .prettyPrinted)
                } catch {
                    completionClosure(error.localizedDescription, nil, nil)
                    return
                }
                urlRequest.httpBody = jsonData
            }
        }
        
        // Set the httpMethod and assign httpBody
        urlRequest.addValue(SWPWebServiceConstants.HTTPStrings.contentTypeJSON, forHTTPHeaderField: SWPWebServiceConstants.HTTPStrings.contentTypeHeader)
        
        urlRequest.addValue(SWPWebServiceConstants.HTTPStrings.contentTypeJSON, forHTTPHeaderField: SWPWebServiceConstants.HTTPStrings.acceptHeader)
        
        if methodType == nil {
            urlRequest.httpMethod = SWPWebServiceConstants.HTTPMethods.httpMethodPost
        }
        else {
            urlRequest.httpMethod = methodType
        }
        
        let defaultSessionConfiguration = URLSessionConfiguration.default
        defaultSessionConfiguration.requestCachePolicy = .reloadIgnoringLocalCacheData
        defaultSessionConfiguration.urlCache = nil
        defaultSessionConfiguration.timeoutIntervalForRequest = 3600
        defaultSessionConfiguration.timeoutIntervalForResource = 3600
        
        let defaultSession = URLSession(configuration: defaultSessionConfiguration, delegate: self, delegateQueue:OperationQueue.current )
        let dataTask = defaultSession.dataTask(with: urlRequest) { (data, response, error) in
            // Handle your response here
            
            if error != nil {// Error handling
                if error?._code == NSURLErrorTimedOut {
                    completionClosure(SWPLocalizer.sharedInstance.localizedStringForKey(key:"timeOut_Msg"), nil, nil)
                } else if error?._code == NSURLErrorNotConnectedToInternet {
                    completionClosure(SWPLocalizer.sharedInstance.localizedStringForKey(key:"noNetwork_Msg"), nil, nil)
                }
                else {
                    completionClosure((error?.localizedDescription)!, nil, nil)
                }
            }
            else
            {
                if let data = data {
                    do {
                        if returnsDict == false {//Json serialization as an Array of response.
                            let json = try JSONSerialization.jsonObject(with: data) as? [Any]
                            
                            if let json = json {
                                completionClosure(nil,json, nil)
                            }
                            else {
                                completionClosure(SWPLocalizer.sharedInstance.localizedStringForKey(key:"Parse Error"), nil, nil)
                            }
                        }
                        else {//Json serialization as a Dictionary of response.
                            
                            let json = try JSONSerialization.jsonObject(with: data) as? [String:AnyObject]
                            
                            if let json = json {
                                completionClosure(nil, nil, json)
                            }
                            else {
                                completionClosure(SWPLocalizer.sharedInstance.localizedStringForKey(key:"Parse Error"), nil, nil)
                            }
                        }
                        
                    } catch {
                        completionClosure((error.localizedDescription), nil, nil)
                    }
                }
                else {
                    completionClosure(SWPLocalizer.sharedInstance.localizedStringForKey(key:"Parse Error"), nil, nil)
                }
            }
        }
        
        // Fire the request
        dataTask.resume()
    }
}

extension Dictionary
{
   // Method for appending values as http parameter
   func stringFromHttpParameters() -> String {
       let parameterArray = self.map { (key, value) -> String in
           let percentEscapedKey = (key as! String).stringByAddingPercentEncodingForURLQueryValue()!
           let percentEscapedValue = (value as! String).stringByAddingPercentEncodingForURLQueryValue()!
           return "\(percentEscapedKey)=\(percentEscapedValue)"
       }
       return parameterArray.joined(separator: "&")
   }
   
   // Method for appending values as clean http parameter
   func cleanURLStringFromHttpParameters() -> String {
       let parameterArray = self.map { (key, value) -> String in
           let percentEscapedValue = (value as! String).stringByAddingPercentEncodingForURLQueryValue()!
           return "\(percentEscapedValue)"
       }
       return parameterArray.joined(separator: "/")
   }
}

extension String{
   
   // Method to add percent encoding for url query value
   
   func stringByAddingPercentEncodingForURLQueryValue() -> String? {
       let allowedCharacters = NSCharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
       
       return self.addingPercentEncoding( withAllowedCharacters: allowedCharacters as CharacterSet)
   }
}

extension SWPWebServiceManager:URLSessionDataDelegate,URLSessionDelegate,URLSessionTaskDelegate,URLSessionDownloadDelegate
{
   func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Swift.Void)
   {
        completionHandler(nil)
   }
   func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
       DispatchQueue.main.async {
           guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
               let backgroundCompletionHandler = appDelegate.backgroundCompletionHandler else {
                   return
           }
           backgroundCompletionHandler()
       }
   }
   func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {


           if let statusCode = (downloadTask.response as? HTTPURLResponse)?.statusCode {
               if (statusCode == 200)
               {
                    self.completionClosure!(nil)
               }
               else if (statusCode == 503)
               {
                   self.completionClosure!("Server is busy due to multiple requests. Please try syncing after sometime")
               }
               else
               {
                   self.completionClosure!("Server Error")
               }
       }
           
         defaultSession.finishTasksAndInvalidate()
   }
   func urlSession(_ session: URLSession,task: URLSessionTask,
                   didCompleteWithError error: Error?)
   {
   }
}
