//
//  SWPWebServiceConstants.swift
//  StarWarsPlanets
//
//  Created by Vibin Xavier on 11/06/21.
//

import Foundation

struct SWPWebServiceConstants {
    // Web Service - Host Base URLs
    struct hostUrl {
        static let baseUrl = "https://swapi.dev/api/"
    }
    // Web Service - URIs
    struct serviceName {
        static let getPlanetList = "planets/"
    }
    // Web Service - Request Parameters
    struct requestParameters {

    }
    // Web Service - Generic HTTP Parameters
    struct HTTPStrings {
        static let contentTypeHeader = "Content-Type"
        static let contentTypeJSON = "application/json;charset=UTF-8"
        static let acceptHeader = "Accept"
        static let authorizationHeader = "Authorization"
        static let authorizationHeaderValue = "Basic "
    }
    
    // Web Service - Generic HTTP Methods
    struct HTTPMethods {
        static let httpMethodPost = "POST"
        static let httpMethodGet = "GET"
        static let httpMethodDelete = "DELETE"
        static let httpMethodPut = "PUT"
    }
}
