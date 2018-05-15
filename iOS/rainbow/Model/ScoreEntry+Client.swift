//
//  ScoreEntry+Client.swift
//  rainbow
//
//  Created by David Okun IBM on 5/8/18.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    var isDebugMode: Bool {
        let dictionary = ProcessInfo.processInfo.environment
        return dictionary["DEBUGMODE"] != nil
    }
    
    var rainbowServerBaseURL: String {
        var baseURL = UIApplication.shared.isDebugMode ? "http://localhost:8080" : "https://rainbow-scavenger-viz-rec.mybluemix.net" // need to update when we deploy
        baseURL = "https://rainbow-scavenger-viz-rec.mybluemix.net"
        return baseURL
    }
}

enum RainbowClientError: Error {
    case couldNotCreateClient
    case couldNotAddNewEntry
    case couldNotGetEntries
}

extension ScoreEntry {
    class ServerCalls {
        static func save(entry: ScoreEntry, completion: @escaping (_ entry: ScoreEntry?, _ error: RainbowClientError?) -> Void) {
            guard let client = KituraKit(baseURL: UIApplication.shared.rainbowServerBaseURL) else {
                return completion(nil, RainbowClientError.couldNotCreateClient)
            }
            client.post("/watsonml/entries", data: entry) { (savedEntry: ScoreEntry?, error: RequestError?) in
                if error != nil {
                    return completion(nil, RainbowClientError.couldNotAddNewEntry)
                } else {
                    return completion(savedEntry, nil)
                }
            }
        }
        
        static func getAll(completion: @escaping (_ entries: [ScoreEntry]?, _ error: RainbowClientError?) -> Void) {
            guard let client = KituraKit(baseURL: UIApplication.shared.rainbowServerBaseURL) else {
                return completion(nil, RainbowClientError.couldNotCreateClient)
            }
            client.get("/watsonml/leaderboard") { (entries: [ScoreEntry]?, error: RequestError?) in
                if error != nil {
                    return completion(nil, RainbowClientError.couldNotGetEntries)
                } else {
                    return completion(entries, nil)
                }
            }
        }
        
        static func getImage(with identifier: String, completion: @escaping (_ image: UIImage?, _ error: RestError?) -> Void) {
            let request = RestRequest(method: .post, url: "https://241de9e3-46be-4625-a256-76eab61af5da-bluemix.cloudant.com/rainbow-entries/_design/avatarImage/_search/avatarImageIdx", containsSelfSignedCert: false)
            guard let config = KituraServerCredentials.loadedCredentials() else {
                return
            }
            request.credentials = Credentials.basicAuthentication(username: config.cloudant.username, password: config.cloudant.password)
            request.messageBody = Data(base64Encoded: "{\"q\": \"_id:\(identifier)\"}")
        }
    }
}
