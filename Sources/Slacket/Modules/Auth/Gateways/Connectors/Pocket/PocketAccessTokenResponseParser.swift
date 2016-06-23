//
//  PocketAuthorizationResponseParser.swift
//  Slacket
//
//  Created by Jakub Tomanik on 30/05/16.
//
//

import Foundation
import Kitura
import SwiftyJSON

struct PocketAccessTokenResponseParser: ParserDecoderType {
    
    typealias Parsable = PocketAccessTokenResponseType
    typealias ParsedType = JsonType
    
    static func decode(raw: ParsedType) -> Parsable? {
        if let accessToken = raw["access_token"].string,
            let username = raw["username"].string {
            return PocketAccessTokenResponse(pocketAccessToken: accessToken, pocketUsername: username)
        } else {
            return nil
        }
    }
}