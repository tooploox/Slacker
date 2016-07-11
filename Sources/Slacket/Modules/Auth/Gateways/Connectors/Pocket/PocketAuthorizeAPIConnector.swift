//
//  PocketAuthorizeAPIConnector.swift
//  Slacket
//
//  Created by Jakub Tomanik on 03/06/16.
//
//

import Foundation
import Kitura
import HeliumLogger
import LoggerAPI
import SimpleHttpClient

protocol PocketAuthorizeAPIConnectorType {
    
    static func requestAuthorization(redirectUrl url: RedirectUrl, completion: ((PocketAuthorizationResponseType, RedirectUrl)?) -> Void )
    static func requestAccessToken(data: PocketAuthorizationData, completion: (PocketAccessTokenResponseType?) -> Void )
}

struct PocketAuthorizeAPIConnector: PocketAuthorizeAPIConnectorType {
    
    static func requestAuthorization(redirectUrl url: RedirectUrl, completion: ((PocketAuthorizationResponseType, RedirectUrl)?) -> Void ) {
        
        let requestData = PocketAuthorizationRequest(pocketRedirectUri: url)
        let authorizeEndpoint = PocketAuthorizeAPI.requestAuthorization(requestData)
        
        authorizeEndpoint.request() { error, status, headers, data in
            guard let status = status else {
                Log.error(ApiConnectorError.missingStatus(for: .Pocket).description)
                fatalError()
            }
            Log.debug("pocketEndpoint.request() returned status \(status)")
            Log.debug("pocketEndpoint.request() returned headers\n\(headers)")
            
            if let data = data where 200...299 ~= status,
                let parsedBody = ParsedBody.init(data: data, contentType: authorizeEndpoint.acceptContentType),
                let authorizationResponse = PocketAuthorizationResponseParser.parse(body: parsedBody),
                let redirectUrl = authorizeEndpoint.redirectUrl(for: authorizationResponse) {
                completion((authorizationResponse, redirectUrl))
            } else {
                Log.debug(ApiConnectorError.nilDataParsedBodyOrAccessTokenResponse.description)
                completion(nil)
            }
        }
    }
    
    static func requestAccessToken(data: PocketAuthorizationData, completion: (PocketAccessTokenResponseType?) -> Void ) {
        
        let requestData = PocketAccessTokenRequest(pocketRequestToken: data.requestToken)
        let accessTokenEndpoint = PocketAuthorizeAPI.requestAccessToken(requestData)
        
        accessTokenEndpoint.request() { error, status, headers, data in
            guard let status = status else {
                Log.error(ApiConnectorError.missingStatus(for: .Pocket).description)
                fatalError()
            }
            Log.debug("pocketEndpoint.request() returned status \(status)")
            Log.debug("pocketEndpoint.request() returned headers\n\(headers)")
            
            if let data = data where 200...299 ~= status,
                let parsedBody = ParsedBody.init(data: data, contentType: accessTokenEndpoint.acceptContentType),
                let accessTokenResponse = PocketAccessTokenResponseParser.parse(body: parsedBody) {
                let accessTokenResponse = accessTokenResponse as PocketAccessTokenResponseType
                completion(accessTokenResponse)
            } else {
                Log.debug(ApiConnectorError.nilDataParsedBodyOrAccessTokenResponse.description)
                completion(nil)
            }
        }
    }
}
