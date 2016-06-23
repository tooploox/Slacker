//
//  PPocketAuthorizationResponseService.swift
//  Slacket
//
//  Created by Jakub Tomanik on 24/05/16.
//
//

import Foundation

protocol PocketAccessTokenRequestServiceProvider {
    
    static func process(user: SlacketUserType, respond: (PocketAccessTokenResponseType?) -> Void)
}

struct PocketAccessTokenRequestService: PocketAccessTokenRequestServiceProvider {
    
    static let errorDomain = "PocketAccessTokenRequestService"
    
    static func process(user: SlacketUserType, respond: (PocketAccessTokenResponseType?) -> Void) {
        guard let user = user as? SlacketUser else {
            respond(nil)
            return
        }
        
        if let authData = PocketAuthorizationDataStore.sharedInstance.get(keyId: user.keyId) {
            PocketAuthorizeAPIConnector.requestAccessToken(data: authData) { accessTokenResponse in
                respond(accessTokenResponse)
            }
        }
    }
}